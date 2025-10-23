//
//  EditorView.swift
//  Journali
//
//  Created by Najd Alsabi on 29/04/1447 AH.
//

import SwiftUI

// MARK: - Glass building blocks
private struct GlassContainer: ViewModifier {
    var corner: CGFloat = 22
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .fill(.ultraThinMaterial)
                    // faint top-left sheen
                    .overlay(
                        RoundedRectangle(cornerRadius: corner)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.28), Color.white.opacity(0.08)],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.6
                            )
                    )
                    // soft inner shadow to give “depth”
                    .overlay(
                        RoundedRectangle(cornerRadius: corner)
                            .stroke(Color.black.opacity(0.45), lineWidth: 1.2)
                            .blur(radius: 2.5)
                            .mask(
                                RoundedRectangle(cornerRadius: corner)
                                    .fill(
                                        LinearGradient(colors: [.black, .clear], startPoint: .top, endPoint: .bottom)
                                    )
                            )
                    )
            )
            // floating shadow
            .shadow(color: .black.opacity(0.55), radius: 14, x: 0, y: 8)
    }
}

private struct GlassPill: ViewModifier {
    var corner: CGFloat = 20
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: corner)
                            .stroke(Color.white.opacity(0.18), lineWidth: 0.8)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: corner)
                            .stroke(Color.black.opacity(0.45), lineWidth: 1.0)
                            .blur(radius: 2)
                            .mask(
                                RoundedRectangle(cornerRadius: corner)
                                    .fill(LinearGradient(colors: [.black, .clear], startPoint: .top, endPoint: .bottom))
                            )
                    )
            )
    }
}

// MARK: - EditorView
struct EditorView: View {
    enum Mode { case create, edit(Entry) }

    var mode: Mode
    var onSave: (String, String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var bodyText: String = ""
    @State private var showDiscardAlert = false
    @State private var hasEdited = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {

                // MARK: - Top Bar
                HStack {
                    Button {
                        if hasEdited {
                            withAnimation(.spring(response: 0.42, dampingFraction: 0.88)) {
                                showDiscardAlert = true
                            }
                        } else {
                            dismiss()
                        }
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

                // MARK: - Title
                VStack(alignment: .leading, spacing: 8) {
                    TextField("Title", text: $title)
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .onChange(of: title) { _ in hasEdited = true }

                    Text(Date.now.formatted(date: .numeric, time: .omitted))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                }

                // MARK: - Body
                TextEditor(text: $bodyText)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .foregroundColor(.white)
                    .font(.body)
                    .frame(maxHeight: .infinity)
                    .padding(.horizontal)
                    .onChange(of: bodyText) { _ in hasEdited = true }
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

            // MARK: - Discard Glass Alert
            if showDiscardAlert {
                ZStack {
                    Color.black.opacity(0.2)
                        .ignoresSafeArea()
                        .onTapGesture { withAnimation { showDiscardAlert = false } }

                    VStack(spacing: 18) {
                        Text("Are you sure you want to discard changes on this journal?")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(Color("Gray"))
                            .multilineTextAlignment(.leading)
                            .lineSpacing(2)
                            .padding(.horizontal, 10)
                            .padding(.bottom, 8)

                        VStack(spacing: 10) {
                            Button {
                                dismiss()
                            } label: {
                                Text("Discard Changes")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.red)
                                    .modifier(GlassPill())
                            }

                            Button {
                                withAnimation(.spring(response: 0.42, dampingFraction: 0.88)) {
                                    showDiscardAlert = false
                                }
                            } label: {
                                Text("Keep Editing")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.white)
                                    .modifier(GlassPill())
                            }
                        }
                        .padding(.horizontal, 6)
                    }
                    .padding(16)
                    .frame(maxWidth: 312)
                    .modifier(GlassContainer(corner: 35))
                    .transition(.scale.combined(with: .opacity))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .offset(x: 10, y: 19) // Adjust to match the exact placement you want
                }
            }

        }
        .onAppear {
            if case .edit(let entry) = mode {
                title = entry.title
                bodyText = entry.body
            }
        }
        .animation(.spring(response: 0.42, dampingFraction: 0.88), value: showDiscardAlert)
    }
}

// MARK: - Preview
#Preview {
    EditorView(mode: .edit(Entry(title: "New", body: "New tw"))) { _, _ in }
        .preferredColorScheme(.dark)
}
