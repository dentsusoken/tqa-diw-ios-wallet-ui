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
import logic_resources
import logic_business
import logic_core
import PresentationExchange

public struct VPHistoryDetailsUIModel {

  public let id: String
  public var verifierName:String?
  public var verifierURL:String?
  public var submitAt:Date
  public var isSuccess:Bool
  public var idToken:String?
  public var vpToken:String?
  public var presentationSubmission:PresentationSubmission?
  public var message:String?
}

public extension VPHistoryDetailsUIModel {

  struct DocumentField: Identifiable {
    public indirect enum Value {
      case string(String)
    }

    public let id: String
    public let title: String
    public let value: Value
  }

  static func mock() -> VPHistoryDetailsUIModel {
    VPHistoryDetailsUIModel(
      id: UUID().uuidString,
      verifierName: "Digital ID",
      verifierURL: "http://example.com",
      submitAt: Date(),
      isSuccess: false,
      idToken: "12345678",
      vpToken: "9876543210",
      presentationSubmission: PresentationSubmission(
        id: UUID().uuidString,
        definitionID: "exampleDefinitionID",
        descriptorMap: []
        ),
      message: ""
    )
  }

  public func decodeVPToken() -> [IssuerNameSpaces]?{
      guard let vpToken = self.vpToken  else{ return nil }
      guard let data = Data(base64URLEncoded: vpToken) else { return nil }
      let deviceResponse = DeviceResponse(data: [UInt8](data))

      guard let documents = deviceResponse?.documents else { return nil }

      let nameSpacesList =  documents.compactMap {document in
          return document.issuerSigned.issuerNameSpaces
      }
      return nameSpacesList
  }
}

extension PresentationLog {
    func transformToVPHistoryDetailsUi() -> VPHistoryDetailsUIModel {
    return .init(
      id: id,
      verifierName: self.verifierName,
      verifierURL: self.verifierURL,
      submitAt: self.submitAt,
      isSuccess: self.isSuccess,
      idToken: self.idToken,
      vpToken: self.vpToken,
      presentationSubmission: PresentationSubmission(
        id: self.presentationSubmission!.id,
        definitionID: self.presentationSubmission!.definitionID,
        descriptorMap: []
        ),
      message: self.message
    )
  }
}
