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

    enum Filter: String, CaseIterable, Identifiable {
        case all, bookmarked
        var id: Self { self }
    }

    // Filtered entries based on search and bookmark status
    private var filtered: [Entry] {
        var base = entries
        if filter == .bookmarked { base = base.filter { $0.isBookmarked } }
        if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
            let q = query.lowercased()
            base = base.filter { $0.title.lowercased().contains(q) || $0.body.lowercased().contains(q) }
        }
        return base
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack {
                    // MARK: - Header
                    HStack {
                        Text("Journal")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)

                        Spacer()

                        HStack(spacing: 18) {
                            FilterToggle(filter: $filter)

                            Rectangle()
                                .fill(Color.white.opacity(0.25))
                                .frame(width: 1, height: 20)

                            Button {
                                showComposer = true
                            } label: {
                                Image(systemName: "plus")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal, 18)
                        .frame(height: 44)
                        .background(
                            LinearGradient(
                                colors: [Color.white.opacity(0.08), Color.white.opacity(0.03)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 25, style: .continuous)
                                .stroke(Color.white.opacity(0.1), lineWidth: 0.8)
                        )
                        .shadow(color: .black.opacity(0.6), radius: 4, x: 0, y: 2)
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)

                    // MARK: - Content
                    if filtered.isEmpty {
                        EmptyState(startAction: { showComposer = true })
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            VStack(spacing: 20) {
                                ForEach(filtered) { entry in
                                    EntryRow(entry: entry) {
                                        toggleBookmark(entry) // ✅ tap-to-bookmark
                                    }
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            delete(entry)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }

                                        Button {
                                            toggleBookmark(entry)
                                        } label: {
                                            Label(
                                                entry.isBookmarked ? "Unbookmark" : "Bookmark",
                                                systemImage: entry.isBookmarked ? "bookmark.slash" : "bookmark"
                                            )
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 8)
                        }
                    }

                    // MARK: - Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search", text: $query)
                            .foregroundColor(.white)
                            .textInputAutocapitalization(.never)
                        Image(systemName: "mic.fill")
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 44)
                    .background(Color(.systemGray6).opacity(0.15))
                    .cornerRadius(22)
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                }
            }
            .sheet(isPresented: $showComposer) {
                EditorView(mode: .create) { title, body in
                    let e = Entry(title: title, body: body)
                    context.insert(e)
                    try? context.save()
                }
            }
        }
    }

    // MARK: - Helper functions

    private func delete(_ entry: Entry) {
        withAnimation { context.delete(entry) }
        try? context.save()
    }

    private func toggleBookmark(_ entry: Entry) {
        entry.isBookmarked.toggle()
        entry.updatedAt = .now
        try? context.save()
    }
}

#Preview {
    RootView()
        .modelContainer(for: Entry.self, inMemory: true)
        .preferredColorScheme(.dark)
}
