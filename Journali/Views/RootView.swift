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
    @StateObject private var viewModel = RootViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack {
                    headerView
                    contentView
                    searchBar
                }

                if let entry = viewModel.entryToDelete, viewModel.showDeleteAlert {
                    deleteOverlay(for: entry)
                }
            }
            .animation(.spring(), value: viewModel.showDeleteAlert)

            // Create sheet
            .sheet(isPresented: $viewModel.showComposer) {
                EditorView(mode: .create) { title, body in
                    viewModel.createEntry(title: title, body: body)
                }
            }

            // Edit sheet
            .sheet(item: $viewModel.entryToEdit) { entry in
                EditorView(mode: .edit(entry)) { title, body in
                    viewModel.updateEntry(entry, title: title, body: body)
                }
            }
        }
        .onAppear {
            viewModel.setContext(context)   // inject ModelContext once the view appears
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
                FilterToggle(filter: $viewModel.filter)     // uses VM.Filter now

                Rectangle()
                    .fill(Color.white.opacity(0.25))
                    .frame(width: 1, height: 20)

                Button { viewModel.showComposer = true } label: {
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
            if viewModel.filteredEntries.isEmpty {
                EmptyState(startAction: { viewModel.showComposer = true })
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 20) {
                        ForEach(viewModel.filteredEntries) { entry in
                            SwipeToDeleteRow(
                                entry: entry,
                                onToggleBookmark: { viewModel.toggleBookmark(entry) },
                                onDelete: {
                                    viewModel.entryToDelete = entry
                                    withAnimation(.spring()) {
                                        viewModel.showDeleteAlert = true
                                    }
                                },
                                onTap: {
                                    viewModel.entryToEdit = entry
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

            TextField("Search", text: $viewModel.query)
                .foregroundStyle(.white)
                .accentColor(.white.opacity(0.9))
                .textInputAutocapitalization(.never)
                .placeholder(when: viewModel.query.isEmpty) {
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
                    withAnimation { viewModel.showDeleteAlert = false }
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
                        withAnimation { viewModel.showDeleteAlert = false }
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
                        withAnimation { viewModel.showDeleteAlert = false }
                        viewModel.deleteEntry(entry)
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

// MARK: - Preview
#Preview {
    RootView()
        .modelContainer(for: Entry.self, inMemory: true)
        .preferredColorScheme(.dark)
}
