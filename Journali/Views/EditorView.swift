//
//  EditorView.swift
//  Journali
//
//  Created by Najd Alsabi on 29/04/1447 AH.
//

import SwiftUI

struct EditorView: View {
    enum Mode {
        case create, edit(Entry)
    }

    var mode: Mode
    var onSave: (String, String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var bodyText: String = ""

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {

                // MARK: - Top bar
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }

                    Spacer()

                    Button {
                        if !title.isEmpty {
                            onSave(title, bodyText)
                            dismiss()
                        }
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color("Button"))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)

                // MARK: - Title field
                VStack(alignment: .leading, spacing: 8) {
                    TextField("Title", text: $title)
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .overlay(
                            Rectangle()
                                .fill(Color.clear)
                                .frame(height: 2)
                                .padding(.horizontal),
                            alignment: .bottom
                        )

                    Text(Date.now.formatted(date: .numeric, time: .omitted))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                }

                // MARK: - Body text
                TextEditor(text: $bodyText)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .foregroundColor(.white)
                    .font(.body)
                    .frame(maxHeight: .infinity)
                    .padding(.horizontal)
                    .overlay(
                        Group {
                            if bodyText.isEmpty {
                                Text("Type your Journal...")
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 20)
                                    .padding(.top, 12)
                                    .allowsHitTesting(false)
                            }
                        },
                        alignment: .topLeading
                    )

                Spacer()
            }
        }
        .onAppear {
            if case .edit(let entry) = mode {
                title = entry.title
                bodyText = entry.body
            }
        }
    }
}

#Preview {
    EditorView(mode: .create) { _, _ in }
        .preferredColorScheme(.dark)
}
