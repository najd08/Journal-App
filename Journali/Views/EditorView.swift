//
//  EditorView.swift
//  Journali
//
//  Created by Najd Alsabi on 29/04/1447 AH.
//

import SwiftUI
import SwiftData

struct EditorView: View {
    enum Mode { case create, edit(Entry) }

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    let mode: Mode
    var onSave: (String, String) -> Void

    @State private var title: String = ""
    @State private var bodyText: String = ""
    @State private var isBookmarked: Bool = false
    @State private var showDiscardConfirm = false

    init(mode: Mode, onSave: @escaping (String, String) -> Void) {
        self.mode = mode
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                TextField("Title", text: $title)
                    .font(.title2).bold()
                    .padding(.horizontal)
                TextEditor(text: $bodyText)
                    .padding(.horizontal)
                    .scrollContentBackground(.hidden)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .background(Color.black.opacity(0.96).ignoresSafeArea())
            .toolbar { editorToolbar }
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear { loadIfNeeded() }
        .confirmationDialog("Are you sure you want to discard changes?", isPresented: $showDiscardConfirm, titleVisibility: .visible) {
            Button("Discard Changes", role: .destructive) { dismiss() }
            Button("Keep Editing", role: .cancel) { }
        }
    }

    private func loadIfNeeded() {
        if case let .edit(entry) = mode {
            title = entry.title
            bodyText = entry.body
            isBookmarked = entry.isBookmarked
        }
    }

    @ToolbarContentBuilder
    private var editorToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button { if hasUnsavedChanges { showDiscardConfirm = true } else { dismiss() } } label: {
                Image(systemName: "xmark")
            }
        }
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                onSave(title.trimmed(), bodyText.trimmed())
                dismiss()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 12).fill(Color("Purple")).frame(width: 74, height: 34)
                    HStack(spacing: 6) {
                        Image("Button").resizable().scaledToFit().frame(width: 16, height: 16)
                        Text("Save").font(.subheadline).fontWeight(.semibold)
                    }
                }
            }
            .disabled(title.trimmed().isEmpty && bodyText.trimmed().isEmpty)
        }
        ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            Button("Done") { hideKeyboard() }
        }
    }

    private var hasUnsavedChanges: Bool {
        switch mode {
        case .create:
            return !(title.isEmpty && bodyText.isEmpty)
        case .edit(let entry):
            return title != entry.title || bodyText != entry.body || isBookmarked != entry.isBookmarked
        }
    }
}
