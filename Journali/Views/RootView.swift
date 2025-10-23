//
//  RootView.swift
//  Journali
//
//  Created by Najd Alsabi on 28/04/1447 AH.
//

import SwiftUI
import SwiftData

// MARK: - Main View
struct RootView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor<Entry>(\.updatedAt, order: .reverse)]) private var entries: [Entry]
    @State private var query: String = ""
    @State private var filter: Filter = .all
    @State private var showComposer = false
    @State private var showDeleteAlert = false
    @State private var entryToDelete: Entry?
    @State private var entryToEdit: Entry?          // ✅ used by .sheet(item:)
    @State private var showEditor = false           // kept for your state

    enum Filter: String, CaseIterable, Identifiable {
        case all, bookmarked
        var id: Self { self }
    }

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
                Color.black.ignoresSafeArea()

                VStack {
                    headerView
                    contentView
                    searchBar
                }

                if let entry = entryToDelete, showDeleteAlert {
                    deleteOverlay(for: entry)
                }
            }
            .animation(.spring(), value: showDeleteAlert)

            // Create sheet
            .sheet(isPresented: $showComposer) {
                EditorView(mode: .create) { title, body in
                    let e = Entry(title: title, body: body)
                    context.insert(e)
                    try? context.save()
                }
            }

            // Edit sheet (reliable)
            .sheet(item: $entryToEdit) { entry in
                EditorView(mode: .edit(entry)) { title, body in
                    entry.title = title
                    entry.body = body
                    entry.updatedAt = .now
                    try? context.save()
                }
            }
        }
    }
}

// MARK: - Header
private extension RootView {
    var headerView: some View {
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
            .modifier(GlassCapsuleModifier())
        }
        .padding(.horizontal)
        .padding(.top, 16)
    }
}

// MARK: - Content
private extension RootView {
    var contentView: some View {
        Group {
            if filtered.isEmpty {
                EmptyState(startAction: { showComposer = true })
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 20) {
                        ForEach(filtered) { entry in
                            SwipeToDeleteRow(
                                entry: entry,
                                onToggleBookmark: { toggleBookmark(entry) },
                                onDelete: {
                                    entryToDelete = entry
                                    withAnimation(.spring()) {
                                        showDeleteAlert = true
                                    }
                                },
                                onTap: {                      // ✅ tap comes from inside the row
                                    entryToEdit = entry
                                    showEditor = true        // kept for your state; not required
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
            }
        }
    }
}

// MARK: - Search Bar
private extension RootView {
    var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 18, weight: .regular))
                .foregroundStyle(.white.opacity(0.65))

            TextField("Search", text: $query)
                .foregroundStyle(.white)
                .accentColor(.white.opacity(0.9))
                .textInputAutocapitalization(.never)
                .placeholder(when: query.isEmpty) {
                    Text("Search").foregroundStyle(.white.opacity(0.55))
                }

            Image(systemName: "mic.fill")
                .font(.system(size: 18, weight: .regular))
                .foregroundStyle(.white.opacity(0.65))
        }
        .padding(.horizontal, 14)
        .frame(height: 44)
        .modifier(GlassSearchBarModifier())
        .padding(.horizontal)
        .padding(.bottom, 12)
    }
}

// MARK: - Delete Overlay
private extension RootView {
    func deleteOverlay(for entry: Entry) -> some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation { showDeleteAlert = false }
                }

            VStack(alignment: .leading, spacing: 18) {
                Text("Delete Journal?")
                    .font(.headline.bold())
                    .foregroundColor(.white)

                Text("Are you sure you want to delete this journal?")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)

                HStack(spacing: 14) {
                    Button {
                        withAnimation { showDeleteAlert = false }
                    } label: {
                        Text("Cancel")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(14)
                    }

                    Button {
                        withAnimation { showDeleteAlert = false }
                        delete(entry)
                    } label: {
                        Text("Delete")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.red)
                            .cornerRadius(14)
                    }
                }
            }
            .padding(20)
            .frame(maxWidth: 320)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.08),
                                Color.white.opacity(0.02)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .background(Color.black.opacity(0.4).blur(radius: 8))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.4),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.8
                    )
            )
            .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 3)
            .transition(.scale)
        }
    }
}

// MARK: - Helper functions
private extension RootView {
    func delete(_ entry: Entry) {
        withAnimation { context.delete(entry) }
        try? context.save()
    }

    func toggleBookmark(_ entry: Entry) {
        entry.isBookmarked.toggle()
        entry.updatedAt = .now
        try? context.save()
    }
}

// MARK: - Preview
#Preview {
    RootView()
        .modelContainer(for: Entry.self, inMemory: true)
        .preferredColorScheme(.dark)
}

// MARK: - Glass Capsule Modifier
struct GlassCapsuleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.08),
                                Color.white.opacity(0.02)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .background(
                        Color.black.opacity(0.4)
                            .blur(radius: 8)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.4),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.8
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.25),
                                .clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.2
                    )
                    .blur(radius: 0.5)
            )
            .shadow(color: .black.opacity(0.6), radius: 10, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .stroke(Color.white.opacity(0.05), lineWidth: 0.5)
                    .blur(radius: 0.8)
            )
    }
}

// MARK: - Glass Search Bar Modifier (Same as Capsule)
struct GlassSearchBarModifier: ViewModifier {
    private let r: CGFloat = 22

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: r, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.08),
                                Color.white.opacity(0.02)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .background(
                        Color.black.opacity(0.4)
                            .blur(radius: 8)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: r, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.4),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.8
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: r, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.25),
                                .clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.2
                    )
                    .blur(radius: 0.5)
            )
            .shadow(color: .black.opacity(0.6), radius: 10, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: r, style: .continuous)
                    .stroke(Color.white.opacity(0.05), lineWidth: 0.5)
                    .blur(radius: 0.8)
            )
    }
}

// MARK: - Placeholder Helper
extension View {
    @ViewBuilder func placeholder<Content: View>(
        when shouldShow: Bool,
        @ViewBuilder _ placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: .leading) {
            if shouldShow { placeholder() }
            self
        }
    }
}

// MARK: - SwipeToDeleteRow
struct SwipeToDeleteRow: View {
    @State private var offsetX: CGFloat = 0
    @GestureState private var dragOffset: CGFloat = 0

    var entry: Entry
    var onToggleBookmark: () -> Void
    var onDelete: () -> Void
    var onTap: () -> Void                 // ✅ NEW

    var body: some View {
        ZStack {
            // Background delete button
            HStack {
                Spacer()
                Button(action: onDelete) {
                    ZStack {
                        Circle()
                            .fill(Color(.systemRed))
                            .frame(width: 55, height: 55)
                            .shadow(color: Color(.systemRed).opacity(0.4), radius: 6, x: 0, y: 3)
                        Image(systemName: "trash.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .bold))
                    }
                }
                .offset(x: offsetX < 0 ? 0 : 80)
                .opacity(offsetX < 0 ? 1 : 0)
                .animation(.easeInOut(duration: 0.2), value: offsetX)
            }

            // Foreground row
            EntryRow(entry: entry, onToggleBookmark: onToggleBookmark)
                .contentShape(Rectangle()) // full area tappable
                .offset(x: offsetX + dragOffset)
                .gesture(
                    DragGesture()
                        .updating($dragOffset) { value, state, _ in
                            if value.translation.width < 0 {
                                state = value.translation.width
                            }
                        }
                        .onEnded { value in
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                offsetX = value.translation.width < -80 ? -80 : 0
                            }
                        }
                )
                .onTapGesture {
                    withAnimation { offsetX = 0 }
                    onTap()               
                }
        }
    }
}
