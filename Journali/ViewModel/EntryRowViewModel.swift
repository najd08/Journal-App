//
//  EntryRowViewModel.swift
//  Journali
//
//  Created by Najd Alsabi on 28/04/1447 AH.
//

import SwiftUI
import SwiftData

@MainActor
final class EntryRowViewModel: ObservableObject {
    @Published var entry: Entry

    init(entry: Entry) {
        self.entry = entry
    }

    // MARK: - Computed Properties
    var title: String { entry.title }
    var bodyPreview: String { entry.body }

    /// Returns formatted date like "21/10/2025"
    var formattedDate: String {
        entry.updatedAt.formatted(
            Date.FormatStyle()
                .day(.twoDigits)
                .month(.twoDigits)
                .year(.defaultDigits)
                .locale(Locale(identifier: "en_GB"))
        )
    }

    var isBookmarked: Bool { entry.isBookmarked }

    // MARK: - Actions
    func toggleBookmark() {
        entry.isBookmarked.toggle()
    }
}
