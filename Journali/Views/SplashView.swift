//
//  SplashView.swift
//  Journali
//
//  Created by Najd Alsabi on 29/04/1447 AH.
//

import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var scale: CGFloat = 0.8
    @State private var opacity = 0.5

    var body: some View {
        if isActive {
            // ✅ When splash ends, show main journal view
            RootView()
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.5), value: isActive)
        } else {
            ZStack {
                LinearGradient(
                    colors: [Color("BG2"), Color("BG1")],
                    startPoint: .topLeading,
                    endPoint: .bottomLeading
                )
                .ignoresSafeArea()

                VStack(spacing: 10) {
                    Image("Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 90, height: 111)
                        .shadow(radius: 10)
                        .padding(.bottom, 10)
                        .scaleEffect(scale)
                        .opacity(opacity)
                        .onAppear {
                            // animate logo appearance
                            withAnimation(.easeIn(duration: 1.0)) {
                                scale = 1.05
                                opacity = 1.0
                            }
                        }

                    Text("Journali")
                        .font(.system(size: 42, weight: .black))
                        .foregroundColor(Color("white"))

                    Text("Your thoughts, your story")
                        .font(.system(size: 18, weight: .light))
                        .foregroundColor(Color("white"))
                }
            }
            .onAppear {
                // wait 2 seconds, then transition
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashView()
}
