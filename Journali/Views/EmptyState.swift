//
//  EmptyState.swift
//  Journali
//
//  Created by Najd Alsabi on 29/04/1447 AH.
//


import SwiftUI

struct EmptyState: View {
    var startAction: () -> Void

    var body: some View {
        VStack {
            Spacer()

            // Illustration
            Image("Book")
                .resizable()
                .scaledToFit()
                .frame(width: 160, height: 160)
                .padding(.bottom, 20)

            // Title
            Text("Begin Your Journal")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(Color("Purple"))
                .padding(.bottom, 8)

            // Subtitle
            Text("Craft your personal diary, tap the plus icon to begin")
                .font(.system(size: 16))
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal, 30)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
    }
}

#Preview {
    EmptyState(startAction: {})
        .preferredColorScheme(.dark)
}
