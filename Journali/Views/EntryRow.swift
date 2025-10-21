//
//  EntryRow.swift
//  Journali
//
//  Created by Najd Alsabi on 29/04/1447 AH.
//

import SwiftUI

struct EntryRow: View {
    let entry: Entry
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(entry.title.isEmpty ? "Untitled" : entry.title)
                    .font(.headline)
                Spacer()
                Image(systemName: entry.isBookmarked ? "bookmark.fill" : "bookmark")
                    .foregroundStyle(entry.isBookmarked ? Color("Purple") : .secondary)
            }
            Text(entry.body.isEmpty ? "No content" : entry.body)
                .lineLimit(3)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            HStack(spacing: 6) {
                Text(entry.updatedAt, style: .date)
                Text("·")
                Text(entry.updatedAt, style: .time)
            }
            .font(.caption)
            .foregroundStyle(.tertiary)
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 20).fill(Color(uiColor: .secondarySystemBackground)))
    }
}
