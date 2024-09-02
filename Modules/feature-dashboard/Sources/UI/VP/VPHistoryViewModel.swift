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
import logic_business
import logic_core
import feature_common

struct VPHistoryState: ViewState {
  let isLoading: Bool
  let documents: [VPHistoryUIModel]
  let bearer: BearerVPUIModel
  let phase: ScenePhase
  let pendingBleModalAction: Bool
  let appVersion: String
  let config: IssuanceFlowUiConfig
    
    var isFlowCancellable: Bool {
      return config.isExtraDocumentFlow
    }
}

final class VPHistoryViewModel<Router: RouterHost>: BaseViewModel<Router, VPHistoryState> {

  private let interactor: VPHistoryInteractor
  private let deepLinkController: DeepLinkController
  private let walletKitController: WalletKitController

  @Published var isMoreModalShowing: Bool = false
  @Published var isBleModalShowing: Bool = false

  var bearerName: String {
    viewState.bearer.value.name
  }

  init(
    router: Router,
    interactor: VPHistoryInteractor,
    deepLinkController: DeepLinkController,
    walletKit: WalletKitController,
    config: any UIConfigType
  ) {
      guard let config = config as? IssuanceFlowUiConfig else {
        fatalError("AddDocumentViewModel:: Invalid configuraton")
      }
    self.interactor = interactor
    self.deepLinkController = deepLinkController
    self.walletKitController = walletKit
    super.init(
      router: router,
      initialState: .init(
        isLoading: true,
        documents: VPHistoryUIModel.mocks(),
        bearer: BearerVPUIModel.mock(),
        phase: .active,
        pendingBleModalAction: false,
        appVersion: interactor.getAppVersion(),
        config:config
        
      )
    )
  }

  func fetch() async {
    switch await interactor.fetchVP() {
    case .success(let bearer, let documents):
      setNewState(
        documents: documents,
        bearer: bearer
      )
    case .failure:
      setNewState(
        documents: []
      )
    }
  }

  func setPhase(with phase: ScenePhase) {
    setNewState(phase: phase)
    if phase == .active && viewState.pendingBleModalAction {
      DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
        self.setNewState(pendingBleModalAction: false)
        self.toggleBleModal()
      }
    }
  }

  func onDocumentDetails(documentId: String) {
    router.push(
      with: .issuanceVPDocumentDetails(
        config: IssuanceDetailUiConfig(flow: .extraDocument(documentId))
      )
    )
  }

  func toggleBleModal() {
    guard viewState.phase == .active else {
      setNewState(pendingBleModalAction: true)
      return
    }
    isBleModalShowing = !isBleModalShowing
  }

  func onBleSettings() {
    toggleBleModal()
    interactor.openBleSettings()
  }

  func onMore() {
    isMoreModalShowing = !isMoreModalShowing
  }

    func pop() {
      router.pop(animated: true)
    }

  private func setNewState(
    isLoading: Bool = false,
    documents: [VPHistoryUIModel]? = nil,
    bearer: BearerVPUIModel? = nil,
    phase: ScenePhase? = nil,
    pendingBleModalAction: Bool? = nil
  ) {
    setState { previousSate in
        .init(
          isLoading: isLoading,
          documents: documents ?? previousSate.documents,
          bearer: bearer ?? previousSate.bearer,
          phase: phase ?? previousSate.phase,
          pendingBleModalAction: pendingBleModalAction ?? previousSate.pendingBleModalAction,
          appVersion: previousSate.appVersion,
          config: previousSate.config
        )
    }
  }
}
