//
//  RootView.swift
//  Journali
//
//  Created by Najd Alsabi on 28/04/1447 AH.
//

import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor<Entry>(\.updatedAt, order: .reverse)]) private var entries: [Entry]
    @State private var query: String = ""
    @State private var filter: Filter = .all
    @State private var showComposer = false

    enum Filter: String, CaseIterable, Identifiable { case all, bookmarked; var id: Self { self } }

    private var filtered: [Entry] {
        var base = entries
        if filter == .bookmarked { base = base.filter { $0.isBookmarked } }
        if !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let q = query.lowercased()
            base = base.filter { $0.title.lowercased().contains(q) || $0.body.lowercased().contains(q) }
        }
        return base
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.opacity(0.96).ignoresSafeArea()

                VStack(spacing: 0) {
                    header

                    if entries.isEmpty {
                        EmptyState(startAction: { showComposer = true })
                    } else {
                        listView
                    }

                    customSearchBar
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showComposer) {
            EditorView(mode: .create) { title, body in
                let e = Entry(title: title, body: body)
                context.insert(e)
                try? context.save()
            }
        }
    }

    // MARK: - Header with Title and Buttons
    private var header: some View {
        HStack {
            Text("Journal")
                .font(.largeTitle)
                .bold()
                .foregroundStyle(.white)

            Spacer()

            HStack(spacing: 8) {
                Button {
                    toggleFilter()
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .font(.system(size: 16, weight: .medium))
                }

                Divider()
                    .frame(height: 18)
                    .background(Color.white.opacity(0.3))

                Button {
                    showComposer = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                }
            }
            .foregroundColor(.white)
            .padding(.vertical, 8)
            .padding(.horizontal, 14)
            .background(.ultraThinMaterial.opacity(0.3))
            .clipShape(Capsule())
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }

    // MARK: - Custom Search Bar
    private var customSearchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)

            TextField("Search", text: $query)
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundColor(.white)

            if !query.isEmpty {
                Button(action: { query = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }

            Image(systemName: "mic.fill")
                .foregroundColor(.gray)
        }
        .padding(10)
        .background(Color(.systemGray6).opacity(0.15))
        .clipShape(Capsule())
    }

    // MARK: - Entries List
    private var listView: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(filtered) { entry in
                    EntryRow(entry: entry)
                        .contextMenu {
                            Button(role: .destructive) { delete(entry) } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            Button {
                                toggleBookmark(entry)
                            } label: {
                                Label(entry.isBookmarked ? "Remove Bookmark" : "Add Bookmark",
                                      systemImage: entry.isBookmarked ? "bookmark.slash" : "bookmark")
                            }
                        }
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)
        }
    }

    // MARK: - Helpers
    private func delete(_ entry: Entry) {
        withAnimation { context.delete(entry) }
        try? context.save()
    }

    private func toggleBookmark(_ entry: Entry) {
        entry.isBookmarked.toggle()
        entry.updatedAt = .now
        try? context.save()
    }

    private func toggleFilter() {
        filter = (filter == .all) ? .bookmarked : .all
    }
}

#Preview {
    RootView()
        .modelContainer(for: Entry.self, inMemory: true)
        .preferredColorScheme(.dark)
}
