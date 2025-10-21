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
            Picker("Filter", selection: $filter) {
                Label("All", systemImage: "line.3.horizontal").tag(RootView.Filter.all)
                Label("Bookmarked", systemImage: "bookmark.fill").tag(RootView.Filter.bookmarked)
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: filter == .all ? "line.3.horizontal" : "bookmark.fill")
                Text(filter == .all ? "Sort by: All" : "Sort by: Bookmarks")
            }
            .font(.subheadline)
            .padding(.horizontal, 12).padding(.vertical, 8)
            .background(Capsule().fill(Color(uiColor: .tertiarySystemFill)))
        }
    }
}
