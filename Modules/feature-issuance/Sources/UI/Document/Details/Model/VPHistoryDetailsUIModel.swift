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
//  public let type: DocumentTypeIdentifier
  public var verifierName:String?
  public var verifierURL:String?
  public var submitAt:Date
  public var isSuccess:Bool
  public var idToken:String?
  public var vpToken:String?
  public var presentationSubmission:PresentationSubmission?
  public var message:String?
//  public let documentFields: [DocumentField]
}

public extension VPHistoryDetailsUIModel {

  struct DocumentField: Identifiable {
    public indirect enum Value {
      case string(String)
      case image(Data)
    }

    public let id: String
    public let title: String
    public let value: Value
  }

  static func mock() -> VPHistoryDetailsUIModel {
    VPHistoryDetailsUIModel(
      id: UUID().uuidString,
//      type: DocumentTypeIdentifier.MDL,
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
//      documentFields:
//       [
//         .init(
//           id: UUID().uuidString,
//           title: "ID no",
//           value: .string("AB12356")),
//         .init(
//           id: UUID().uuidString,
//           title: "Nationality",
//           value: .string("Hellenic")),
//         .init(
//           id: UUID().uuidString,
//           title: "Place of birth",
//           value: .string("21 Oct 1994")),
//         .init(
//           id: UUID().uuidString,
//           title: "Height",
//           value: .string("1,82"))
//       ]
      
//      Array(
//        count: 6,
//        createElement: DocumentField(
//          id: UUID().uuidString,
//          title: "Placeholder Field Title".padded(padLength: 5),
//          value: .string("Placeholder Field Value".padded(padLength: 10))
//        )
//      )
    )
  }
}

extension PresentationLog {
    func transformToVPHistoryDetailsUi() -> VPHistoryDetailsUIModel {

//    let documentFields: [VPHistoryDetailsUIModel.DocumentField] =
//    flattenValues(
//      input: displayStrings
//        .compactMap({$0})
//        .sorted(by: {$0.order < $1.order})
//        .decodeGender()
//        .mapTrueFalseToLocalizable()
//        .parseDates(
//          parser: {
//            Locale.current.localizedDateTime(
//              date: $0,
//              uiFormatter: "dd MMM yyyy"
//            )
//          }
//        ),
//      images: displayImages
//    )

//    var bearerName: String {
//      guard let fullName = getBearersName() else {
//        return ""
//      }
//      return "\(fullName.first) \(fullName.last)"
//    }

//    let identifier = DocumentTypeIdentifier(rawValue: docType)

//    return .init(
//      id: id,
//      type: identifier,
//      documentName: identifier.isSupported
//      ? identifier.localizedTitle
//      : title,
//      holdersName: bearerName,
//      holdersImage: getPortrait() ?? Theme.shared.image.user,
//      createdAt: createdAt,
//      hasExpired: hasExpired(
//        parser: {
//          Locale.current.parseDate(
//            date: $0
//          )
//        }
//      ),
//      documentFields: documentFields
//    )
    return .init(
      id: id,
//      type: identifier,
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
//      documentFields: [documentFields
    )
  }

  private func flattenValues(input: [NameValue], images: [NameImage]) -> [VPHistoryDetailsUIModel.DocumentField] {
    input.reduce(into: []) { partialResult, nameValue in
      let uuid = UUID().uuidString
      let title: String = LocalizableString.shared.get(with: .dynamic(key: nameValue.name))
      if let image = images.first(where: {$0.name == nameValue.name})?.image {

        guard nameValue.name != "portrait" else {
          partialResult.append(
            .init(
              id: uuid,
              title: title,
              value: .string(LocalizableString.shared.get(with: .shownAbove))
            )
          )
          return
        }

        partialResult.append(
          .init(
            id: uuid,
            title: title,
            value: .image(image)
          )
        )
      } else if let nested = nameValue.children {
        partialResult.append(
          .init(
            id: uuid,
            title: title,
            value: .string(flattenNested(parent: nameValue, nested: nested).value)
          )
        )
      } else {
        partialResult.append(
          .init(
            id: uuid,
            title: title,
            value: .string(nameValue.value)
          )
        )
      }
    }
  }

  private func flattenNested(parent: NameValue, nested: [NameValue]) -> NameValue {
    let flat = nested
      .decodeGender()
      .mapTrueFalseToLocalizable()
      .parseDates(
        parser: {
          Locale.current.localizedDateTime(
            date: $0,
            uiFormatter: "dd MMM yyyy"
          )
        }
      )
      .reduce(into: "") { partialResult, nameValue in
        if let nestedChildren = nameValue.children {
          let deepNested = flattenNested(parent: nameValue, nested: nestedChildren.sorted(by: {$0.order < $1.order}))
          partialResult += "\(deepNested.value)\n"
        } else {
          partialResult += "\(LocalizableString.shared.get(with: .dynamic(key: nameValue.name))): \(nameValue.value)\n"
        }
      }
      .dropLast()

    return .init(
      name: parent.name,
      value: String(flat),
      ns: parent.ns,
      order: parent.order,
      children: nil
    )
  }
}
