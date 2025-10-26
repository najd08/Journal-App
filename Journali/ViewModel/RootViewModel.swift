//
//  RootViewModel.swift
//  Journali
//
//  Created by Najd Alsabi on 28/04/1447 AH.
//

import SwiftUI
import SwiftData

@MainActor
final class RootViewModel: ObservableObject {
    // UI state
    @Published var query: String = ""
    @Published var filter: Filter = .all
    @Published var showComposer = false
    @Published var showDeleteAlert = false
    @Published var entryToDelete: Entry?
    @Published var entryToEdit: Entry?

    // Data
    @Published private(set) var entries: [Entry] = []

    // SwiftData context (injected from the View)
    private var context: ModelContext?

    enum Filter: String, CaseIterable, Identifiable {
        case all, bookmarked
        var id: Self { self }
    }

    init() {}

    // Call this once the View has an Environment context
    func setContext(_ context: ModelContext) {
        self.context = context
        fetchEntries()
    }

    // MARK: - CRUD
    func fetchEntries() {
        guard let context else { return }
        let descriptor = FetchDescriptor<Entry>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        entries = (try? context.fetch(descriptor)) ?? []
    }

    func createEntry(title: String, body: String) {
        guard let context else { return }
        let newEntry = Entry(title: title, body: body)
        context.insert(newEntry)
        try? context.save()
        fetchEntries()
    }

    func updateEntry(_ entry: Entry, title: String, body: String) {
        guard let context else { return }
        entry.title = title
        entry.body = body
        entry.updatedAt = .now
        try? context.save()
        fetchEntries()
    }

    func deleteEntry(_ entry: Entry) {
        guard let context else { return }
        context.delete(entry)
        try? context.save()
        fetchEntries()
    }

    func toggleBookmark(_ entry: Entry) {
        guard let context else { return }
        entry.isBookmarked.toggle()
        entry.updatedAt = .now
        try? context.save()
        fetchEntries()
    }

    // MARK: - Filtering
    var filteredEntries: [Entry] {
        var base = entries
        if filter == .bookmarked { base = base.filter { $0.isBookmarked } }
        if !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let q = query.lowercased()
            base = base.filter {
                $0.title.lowercased().contains(q) || $0.body.lowercased().contains(q)
            }
        }
        return base
    }
}
