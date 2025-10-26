//
//  UIHelpers.swift
//  Journali
//
//  Created by Najd Alsabi on 04/05/1447 AH.
//

import SwiftUI

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

// MARK: - Glass Search Bar Modifier
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
    var onTap: () -> Void

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
                .contentShape(Rectangle())
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
