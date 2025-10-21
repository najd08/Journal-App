//
//  FilterToggle.swift
//  Journali
//
//  Created by Najd Alsabi on 29/04/1447 AH.
//

import SwiftUI

struct FilterToggle: View {
    @Binding var filter: RootView.Filter

    var body: some View {
        Menu {
            Button {
                filter = .bookmarked
            } label: {
                HStack {
                    Text("Sort by Bookmark")
                    if filter == .bookmarked {
                        Image(systemName: "checkmark")
                    }
                }
            }

            Divider()

            Button {
                filter = .all
            } label: {
                HStack {
                    Text("Sort by Entry Date")
                    if filter == .all {
                        Image(systemName: "checkmark")
                    }
                }
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
        }
    }
}
