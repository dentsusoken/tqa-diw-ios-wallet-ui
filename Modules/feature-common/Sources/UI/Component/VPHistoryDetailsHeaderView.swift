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
import logic_ui

public struct VPHistoryDetailsHeaderView: View {

  let submitAt: Date
  let verifierURL: String
  let isLoading: Bool
  let actions: [ContentHeaderView.Action]?
  let onBack: (() -> Void)?

  public init(
    submitAt: Date,
    verifierURL: String,
    isLoading: Bool,
    actions: [ContentHeaderView.Action]?,
    onBack: (() -> Void)?
  ) {
    self.submitAt = submitAt
    self.verifierURL = verifierURL
    self.isLoading = isLoading
    self.actions = actions
    self.onBack = onBack
  }

  public var body: some View {
    VStack {
      VPHistoryDetailsHeaderViewCellView(
        submitAt: submitAt,
        verifierURL: verifierURL,
        isLoading: isLoading,
        actions: actions,
        onBack: onBack
      )
    }
  }
}

extension VPHistoryDetailsHeaderView {

  struct VPHistoryDetailsHeaderViewCellView: View {

    let submitAt: Date
    let verifierURL: String
    let isLoading: Bool
    let actions: [ContentHeaderView.Action]?
    let onBack: (() -> Void)?

    public init(
      submitAt: Date,
      verifierURL: String,
      isLoading: Bool,
      actions: [ContentHeaderView.Action]?,
      onBack: (() -> Void)?
    ) {
      self.submitAt = submitAt
      self.verifierURL = verifierURL
      self.isLoading = isLoading
      self.actions = actions
      self.onBack = onBack
    }
    private var formattedSubmitAt: String {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd"
      return dateFormatter.string(from: submitAt)
    }

    public var body: some View {
      VStack(alignment: .leading, spacing: SPACING_SMALL) {

        if let onBack {
          ContentHeaderView(
            dismissIcon: Theme.shared.image.xmark,
            foregroundColor: Theme.shared.color.primary,
            actions: actions
          ) {
            onBack()
          }
        }

        Text(formattedSubmitAt)
          .typography(Theme.shared.font.headlineSmall)
          .foregroundColor(Theme.shared.color.black)
          .shimmer(isLoading: isLoading)

        Text(verifierURL)
          .typography(Theme.shared.font.bodyLarge)
          .foregroundColor(Theme.shared.color.black)
          .padding(.bottom)
          .shimmer(isLoading: isLoading)

        HStack {
          if !isLoading {
            ZStack(alignment: .topTrailing) {
              Theme.shared.image.idStroke
                .roundedCorner(Theme.shared.shape.small, corners: .allCorners)
            }
            .padding(.leading, -40)
          }
          Spacer()
        }
        .shimmer(isLoading: isLoading)
      }
      .padding(SPACING_MEDIUM)
      .frame(maxWidth: .infinity)
      .background(Theme.shared.color.secondary)
      .roundedCorner(Theme.shared.shape.small, corners: [.bottomLeft, .bottomRight])
    }
  }
}
