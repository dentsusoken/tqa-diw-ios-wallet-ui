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
import logic_core
import logic_resources
import logic_business
import PresentationExchange
import SiopOpenID4VP
import MdocDataModel18013
import SwiftCBOR

public struct VPHistoryUIModel: Identifiable {

  public var id: String = UUID().uuidString
  public var verifierName:String?
  public var verifierURL:String?
  public var submitAt:Date
  public var isSuccess:Bool
  public var idToken:String?
  public var vpToken:String?
  public var presentationSubmission:PresentationSubmission?
  public var message:String?

  public init(id: String = UUID().uuidString, verifierName: String?, verifierURL: String?, submitAt: Date, isSuccess: Bool, consent: ClientConsent,idToken:String? = nil,vpToken:String? = nil,presentationSubmission:PresentationSubmission? = nil,message:String? = nil) {
    self.id = id
    self.verifierName = verifierName
    self.verifierURL = verifierURL
    self.submitAt = submitAt
    self.isSuccess = isSuccess
    self.vpToken = vpToken
    self.presentationSubmission =  presentationSubmission
    self.message = message
  }

  public static func mocks() -> [VPHistoryUIModel] {
    [
      .init(
        id: UUID().uuidString,
        verifierName: "Digital ID",
        verifierURL: "Digital ID URL",
        submitAt: Date(),
        isSuccess: false,
        consent: .idToken(idToken: "1234567890")
      ),
      .init(
        id: UUID().uuidString,
        verifierName: "EUDI Conference",
        verifierURL: "EUDI Conference URL",
        submitAt: Date(),
        isSuccess: false,
        consent: .idToken(idToken: "1234567890")
      )
    ]
  }
}

extension Array where Element == PresentationLog {
  func transformToVPDocumentUi() -> [VPHistoryUIModel] {
    self.map { item in
      let consent: ClientConsent
      if let idToken = item.idToken, let vpToken = item.vpToken, let presentationSubmission = item.presentationSubmission {
        consent = .idAndVPToken(idToken: idToken, vpToken: .generic(vpToken), presentationSubmission: presentationSubmission)
      } else if let vpToken = item.vpToken, let presentationSubmission = item.presentationSubmission {
        consent = .vpToken(vpToken: .generic(vpToken), presentationSubmission: presentationSubmission)
      } else if let idToken = item.idToken {
        consent = .idToken(idToken: idToken)
      } else {
        consent = .negative(message: item.message ?? "No consent provided")
      }

      return VPHistoryUIModel(
          id: item.id,
          verifierName: item.verifierName,
          verifierURL: item.verifierURL,
          submitAt: item.submitAt,
          isSuccess: item.isSuccess,
          consent: consent
      )
    }
  }
}
