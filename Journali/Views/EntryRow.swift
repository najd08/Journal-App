//
//  EntryRow.swift
//  Journali
//
//  Created by Najd Alsabi on 28/04/1447 AH.
//

import SwiftUI
import SwiftData

struct EntryRow: View {
    @Bindable var entry: Entry
    var onToggleBookmark: (() -> Void)?   // ✅ callback to toggle from RootView

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    // Title
                    Text(entry.title)
                        .font(.headline.weight(.semibold))
                        .foregroundColor(Color("Purple"))

                    // Date (formatted as 21/10/2025)
                    Text(entry.updatedAt.formatted(
                        Date.FormatStyle()
                            .day(.twoDigits)
                            .month(.twoDigits)
                            .year(.defaultDigits)
                            .locale(Locale(identifier: "en_GB"))
                    ))
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, -2)

                    // Body preview
                    Text(entry.body)
                        .font(.body)
                        .foregroundColor(Color("white"))
                        .padding(.top, 4)
                }

                Spacer()

                // ✅ Make bookmark icon tappable
                Button {
                    onToggleBookmark?()
                } label: {
                    Image(systemName: entry.isBookmarked ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color("Purple"))
                        .padding(.top, 4)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.05))
        )
        .padding(.horizontal, 4)
    }
}

#Preview {
    EntryRow(entry: Entry(title: "My Birthday", body: "Lorem ipsum dolor sit amet.")) { }
        .preferredColorScheme(.dark)
}
