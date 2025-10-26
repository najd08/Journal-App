//
//  EntryRow.swift
//  Journali
//
//  Created by Najd Alsabi on 28/04/1447 AH.
//

import SwiftUI
import SwiftData

struct EntryRow: View {
    @StateObject private var viewModel: EntryRowViewModel
    var onToggleBookmark: (() -> Void)?   // Optional callback from RootView

    // MARK: - Init
    init(entry: Entry, onToggleBookmark: (() -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: EntryRowViewModel(entry: entry))
        self.onToggleBookmark = onToggleBookmark
    }

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    // Title
                    Text(viewModel.title)
                        .font(.headline.weight(.semibold))
                        .foregroundColor(Color("Purple"))

                    // Date
                    Text(viewModel.formattedDate)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, -2)

                    // Body preview
                    Text(viewModel.bodyPreview)
                        .font(.body)
                        .foregroundColor(Color("white"))
                        .padding(.top, 4)
                }

                Spacer()

                // Bookmark button
                Button {
                    if let onToggleBookmark = onToggleBookmark {
                        onToggleBookmark()
                    } else {
                        viewModel.toggleBookmark()
                    }
                } label: {
                    Image(systemName: viewModel.isBookmarked ? "bookmark.fill" : "bookmark")
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

// MARK: - Preview
#Preview {
    EntryRow(entry: Entry(title: "My Birthday", body: "Lorem ipsum dolor sit amet.")) { }
        .preferredColorScheme(.dark)
}
