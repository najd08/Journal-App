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

    // Alert handling
    @State private var showDeleteAlert = false
    @State private var entryToDelete: Entry?

    enum Filter: String, CaseIterable, Identifiable {
        case all, bookmarked
        var id: Self { self }
    }

    // MARK: - Filtered entries
    private var filtered: [Entry] {
        var base = entries
        if filter == .bookmarked { base = base.filter { $0.isBookmarked } }
        if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
            let q = query.lowercased()
            base = base.filter { $0.title.lowercased().contains(q) || $0.body.lowercased().contains(q) }
        }
        return base
    }

    // MARK: - Body
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
                            LazyVStack(spacing: 20) {
                                ForEach(filtered) { entry in
                                    SwipeToDeleteRow(entry: entry) {
                                        toggleBookmark(entry)
                                    } onDelete: {
                                        entryToDelete = entry
                                        withAnimation(.spring()) {
                                            showDeleteAlert = true
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

                // MARK: - Custom Delete Confirmation Overlay
                if let entry = entryToDelete, showDeleteAlert {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .transition(.opacity)
                        .onTapGesture {
                            withAnimation {
                                showDeleteAlert = false
                            }
                        }

                    VStack(spacing: 16) {
                        Text("Delete Journal?")
                            .font(.headline.bold())
                            .foregroundColor(.white)

                        Text("Are you sure you want to delete this journal?")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal)

                        HStack(spacing: 16) {
                            Button {
                                withAnimation {
                                    showDeleteAlert = false
                                }
                            } label: {
                                Text("Cancel")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(minWidth: 132)
                                    .padding(.vertical, 14)
                                    .padding(.horizontal,6)
                                    .background(Color.gray.opacity(0.3))
                                    .cornerRadius(120)
                            }

                            Button {
                                withAnimation {
                                    showDeleteAlert = false
                                }
                                delete(entry)
                            } label: {
                                Text("Delete")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(minWidth: 132)
                                    .padding(.vertical, 14)
                                    .padding(.horizontal,6)
                                    .background(Color.red)
                                    .cornerRadius(120)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                    .background(Color(.systemGray6).opacity(0.15))
                    .cornerRadius(20)
                    .shadow(radius: 20)
                    .padding(.horizontal, 40)
                    .transition(.scale)
                }
            }
            .animation(.spring(), value: showDeleteAlert)
            // MARK: - Composer Sheet
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
        withAnimation {
            context.delete(entry)
        }
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

// MARK: - SwipeToDeleteRow (Hidden red circle until swipe)
struct SwipeToDeleteRow: View {
    @State private var offsetX: CGFloat = 0
    @GestureState private var dragOffset: CGFloat = 0

    var entry: Entry
    var onToggleBookmark: () -> Void
    var onDelete: () -> Void

    var body: some View {
        ZStack {
            // Background delete button (hidden until swipe)
            HStack {
                Spacer()
                Button(action: onDelete) {
                    ZStack {
                        Circle()
                            .fill(Color(.systemRed))
                            .frame(width: 55, height: 55)
                            .shadow(color: Color(.systemRed).opacity(0.4),
                                    radius: 6, x: 0, y: 3)
                        Image(systemName: "trash.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .bold))
                    }
                }
                .offset(x: offsetX < 0 ? 0 : 80)
                .opacity(offsetX < 0 ? 1 : 0)
                .animation(.easeInOut(duration: 0.2), value: offsetX)
            }

            // Foreground journal card
            EntryRow(entry: entry, onToggleBookmark: onToggleBookmark)
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
                                if value.translation.width < -80 {
                                    offsetX = -80
                                } else {
                                    offsetX = 0
                                }
                            }
                        }
                )
                .onTapGesture {
                    withAnimation {
                        offsetX = 0
                    }
                }
        }
    }
}
