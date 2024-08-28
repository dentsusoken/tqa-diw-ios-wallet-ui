/*
 * Copyright (c) 2023 European Commission
 *
 * Licensed under the EUPL, Version 1.2 or - as soon they will be approved by the European
 * Commission - subsequent versions of the EUPL (the "Licence"); You may not use this work
 * except in compliance with the Licence.
 *
 * You may obtain a copy of the Licence at:
 * https://joinup.ec.europa.eu/software/page/eupl
 *
 * Unless required by applicable law or agreed to in writing, software distributed under
 * the Licence is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF
 * ANY KIND, either express or implied. See the Licence for the specific language
 * governing permissions and limitations under the Licence.
 */
import SwiftUI
import logic_ui
import feature_common
import logic_resources

public struct VPHistoryDetailsView<Router: RouterHost>: View {

  @ObservedObject var viewModel: VPHistoryDetailsViewModel<Router>

  public init(
    with router: Router,
    and interactor: VPHistoryDetailsInteractor,
    config: any UIConfigType
  ) {
    self.viewModel = VPHistoryDetailsViewModel(
      router: router,
      interactor: interactor,
      config: config
    )
  }

  @ViewBuilder
  func content() -> some View {
    ScrollView {
      VStack(spacing: .zero) {

        VSpacer.medium()

        ForEach(viewModel.viewState.document.documentFields) { documentFieldContent in

          switch documentFieldContent.value {
          case .string(let value):
            KeyValueView(
              title: .custom(documentFieldContent.title),
              subTitle: .custom(value),
              isLoading: viewModel.viewState.isLoading
            )
          case .image(let data):
            KeyValueView(
              title: .custom(documentFieldContent.title),
              image: Image(data: data),
              isLoading: viewModel.viewState.isLoading
            )
          }

          VSpacer.medium()
        }
      }
      .padding(.horizontal, Theme.shared.dimension.padding)
    }
    .if(viewModel.viewState.hasContinueButton) {
      $0.bottomFade()
    }

    if viewModel.viewState.hasContinueButton {
      WrapButtonView(
        style: .primary,
        title: .issuanceDetailsContinueButton,
        isLoading: viewModel.viewState.isLoading,
        onAction: viewModel.onContinue()
      )
      .padding([.horizontal, .bottom])
    }
  }

  public var body: some View {
    ContentScreenView(
      padding: .zero,
      canScroll: !viewModel.viewState.hasContinueButton,
      errorConfig: viewModel.viewState.error
    ) {

      VPHistoryDetailsHeaderView(
        verifierName: viewModel.viewState.document.verifierName!,
        verifierURL: viewModel.viewState.document.verifierURL!,
        isLoading: viewModel.viewState.isLoading,
        actions: viewModel.viewState.toolBarActions,
        onBack: viewModel.viewState.isCancellable ? { viewModel.pop() } : nil
      )

      content()
    }
    .sheetDialog(isPresented: $viewModel.isDeletionModalShowing) {
      SheetContentView {
        VStack(spacing: SPACING_MEDIUM) {

          ContentTitleView(
            title: .issuanceDetailsDeletionTitle([viewModel.viewState.document.verifierName ?? ""]),
            caption: .issuanceDetailsDeletionCaption([viewModel.viewState.document.verifierName ?? ""])
          )

          WrapButtonView(
            style: .primary,
            title: .yes,
            onAction: viewModel.onDeleteDocument()
          )
          WrapButtonView(
            style: .secondary,
            title: .no,
            onAction: viewModel.onShowDeleteModal()
          )
        }
      }
    }
    .task {
      await self.viewModel.fetchDocumentDetails()
    }
  }
}