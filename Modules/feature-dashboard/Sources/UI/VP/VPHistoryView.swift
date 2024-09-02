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
import logic_resources
import logic_business
import feature_common
import logic_core
import WalletStorage

public struct VPHistoryView<Router: RouterHost>: View {

  @ObservedObject private var viewModel: VPHistoryViewModel<Router>
  @Environment(\.scenePhase) var scenePhase

  public init(
    with router: Router,
    and interactor: VPHistoryInteractor,
    deeplinkController: DeepLinkController,
    walletKit: WalletKitController,
    config: any UIConfigType
  ) {
    self.viewModel = .init(
      router: router,
      interactor: interactor,
      deepLinkController: deeplinkController,
      walletKit: walletKit,
      config: config
    )
  }

  @ViewBuilder
  func content() -> some View {
    VStack(spacing: .zero) {

      VPHistoryListView(
        items: viewModel.viewState.documents,
        isLoading: viewModel.viewState.isLoading
      ) { document in
        viewModel.onDocumentDetails(documentId: document.id)
      }
      .bottomFade()
      VSpacer.small()
    }
    .background(Theme.shared.color.backgroundPaper)
  }

  public var body: some View {
    ContentScreenView(
      padding: .zero,
      canScroll: false,
      background: Theme.shared.color.secondary
    ) {
        if viewModel.viewState.isFlowCancellable {
          ContentHeaderView(dismissIcon: Theme.shared.image.xmark) {
            viewModel.pop()
          }
          .padding([.top, .horizontal], Theme.shared.dimension.padding)
        }
        
      BearerVPHeaderView(
        item: viewModel.viewState.bearer,
        isLoading: viewModel.viewState.isLoading,
        onMoreClicked: viewModel.onMore()
      )
      content()
    }
    .task {
      await viewModel.fetch()
    }
  }
}
