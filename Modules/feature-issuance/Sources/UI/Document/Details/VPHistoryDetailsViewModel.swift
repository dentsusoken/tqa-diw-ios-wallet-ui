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
import Foundation
import logic_ui
import logic_resources
import feature_common
import logic_core

struct VPHistoryDetailsViewState: ViewState {
  let document: VPHistoryDetailsUIModel
  let isLoading: Bool
  let error: ContentErrorView.Config?
  let config: IssuanceDetailUiConfig
  let toolBarActions: [ContentHeaderView.Action]?
  var data: [DataItem] = []

  var isCancellable: Bool {
    return config.isExtraDocument
  }

  var hasContinueButton: Bool {
    return !config.isExtraDocument
  }
  struct DataItem: Identifiable {
    let id = UUID()
    let number: String
    let email: String
  }
}

final class VPHistoryDetailsViewModel<Router: RouterHost>: BaseViewModel<Router, VPHistoryDetailsViewState> {

  @Published var isDeletionModalShowing: Bool = false
  @Published var issuerNameSpaces: [IssuerNameSpaces]?

  private let interactor: VPHistoryDetailsInteractor

  init(
    router: Router,
    interactor: VPHistoryDetailsInteractor,
    config: any UIConfigType
  ) {
    guard let config = config as? IssuanceDetailUiConfig else {
      fatalError("DocumentDetailsViewModel:: Invalid configuraton")
    }
    self.interactor = interactor
    super.init(
      router: router,
      initialState: .init(
        document: VPHistoryDetailsUIModel.mock(),
        isLoading: true,
        error: nil,
        config: config,
        toolBarActions: nil
      )
    )
  }

  func fetchDocumentDetails() async {

    switch await self.interactor.fetchStoredDocument(documentId: viewState.config.documentId) {

    case .success(let document):
      var actions: [ContentHeaderView.Action]? {
        switch viewState.config.flow {
        case .extraDocument:
          return []
        case .noDocument:
          return nil
        }
      }
      guard let (issuerNameSpaces) = document.decodeVPToken() else {
        return
      }

      var data : [VPHistoryDetailsViewState.DataItem] = []
      for issuerNameSpace in issuerNameSpaces {
        if let nameSpaces = issuerNameSpace.nameSpaces["org.iso.18013.5.1"] {
          var number = ""
          var email = ""
          if nameSpaces[0].elementIdentifier != "given_name" {
             number = nameSpaces[0].description
             email = nameSpaces[1].description
          } else {
            number = nameSpaces[1].description
             email = nameSpaces[0].description
          }
          data.append(VPHistoryDetailsViewState.DataItem(
            number: number,
            email: email))
        }
      }
      self.setNewState(
        isLoading: false,
        document: document,
        toolBarActions: actions,
        data: data
      )
      DispatchQueue.main.async {
        self.issuerNameSpaces = issuerNameSpaces
      }

    case .failure(let error):
      self.setNewState(
        isLoading: true,
        error: ContentErrorView.Config(
          description: .custom(error.localizedDescription),
          cancelAction: self.pop()
        )
      )
    }
  }

  func pop() {
    isDeletionModalShowing = false
    router.popTo(with: .vphistory(config: IssuanceFlowUiConfig(flow: .extraDocument)))
  }

  func onContinue() {
    router.push(with: .dashboard)
  }

  func onShowDeleteModal() {
    isDeletionModalShowing = !isDeletionModalShowing
  }

  private func onReboot() {
    isDeletionModalShowing = false
    router.popTo(with: .dashboard)
  }

  private func setNewState(
    isLoading: Bool = false,
    document: VPHistoryDetailsUIModel? = nil,
    error: ContentErrorView.Config? = nil,
    toolBarActions: [ContentHeaderView.Action]? = nil,
    data: [VPHistoryDetailsViewState.DataItem]? = nil
  ) {
    setState { previous in
        .init(
          document: document ?? previous.document,
          isLoading: isLoading,
          error: error,
          config: previous.config,
          toolBarActions: toolBarActions ?? previous.toolBarActions,
          data: data ?? previous.data
        )
    }
  }
}
