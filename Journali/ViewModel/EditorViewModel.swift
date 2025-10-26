//
//  EditorViewModel.swift
//  Journali
//
//  Created by Najd Alsabi on 29/04/1447 AH.
//

import SwiftUI

@MainActor
final class EditorViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var bodyText: String = ""
    @Published var showDiscardAlert = false
    @Published var hasEdited = false

    private var mode: EditorView.Mode
    private var onSave: (String, String) -> Void
    private var dismissAction: (() -> Void)?

    init(mode: EditorView.Mode, onSave: @escaping (String, String) -> Void) {
        self.mode = mode
        self.onSave = onSave

        if case .edit(let entry) = mode {
            title = entry.title
            bodyText = entry.body
        }
    }

    func setDismiss(_ action: @escaping () -> Void) {
        self.dismissAction = action
    }

    func handleDismiss() {
        if hasEdited {
            withAnimation(.spring(response: 0.42, dampingFraction: 0.88)) {
                showDiscardAlert = true
            }
        } else {
            dismissAction?()
        }
    }

    func saveIfValid() {
        guard !title.isEmpty else { return }
        onSave(title, bodyText)
        dismissAction?()
    }

    func discardChanges() {
        dismissAction?()
    }

    func keepEditing() {
        withAnimation(.spring(response: 0.42, dampingFraction: 0.88)) {
            showDiscardAlert = false
        }
    }
}
