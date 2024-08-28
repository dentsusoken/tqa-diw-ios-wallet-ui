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

extension VPHistoryListView {
  struct VPHistoryCellView: View {

    let item: VPHistoryUIModel
    let action: (VPHistoryUIModel) -> Void
    let isLoading: Bool

    init(
      item: VPHistoryUIModel,
      isLoading: Bool,
      action: @escaping (VPHistoryUIModel) -> Void
    ) {
      self.item = item
      self.isLoading = isLoading
      self.action = action
    }

    var body: some View {
      Button(
        action: {
          action(item)
        },
        label: {
          VStack(spacing: .zero) {
            Text(item.verifierURL!)
              .typography(Theme.shared.font.titleMedium)
              .foregroundColor(Theme.shared.color.textPrimaryDark)
              .minimumScaleFactor(0.5)
              .lineLimit(1)

            Spacer()

            ZStack {
              Text(formatDate(item.submitAt))
                .typography(Theme.shared.font.bodyMedium)
                .foregroundColor(Theme.shared.color.warning)
              + Text(.space)
            }
            .lineLimit(2)
            .minimumScaleFactor(0.5)
          }
        }
      )
      .frame(maxWidth: .infinity, alignment: .center)
      .padding()
      .background(Theme.shared.color.backgroundDefault)
      .clipShape(.rect(cornerRadius: 16))
      .shimmer(isLoading: isLoading)
    }
    private func formatDate(_ date: Date) -> String {
      let formatter = DateFormatter()
      formatter.dateStyle = .medium
      formatter.timeStyle = .none
      return formatter.string(from: date)
    }
  }
}
