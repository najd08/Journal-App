//
//  Entry.swift
//  Journali
//
//  Created by Najd Alsabi on 29/04/1447 AH.
//

import Foundation
import SwiftData

@Model
final class Entry: Identifiable {
    @Attribute(.unique) var id: UUID
    var title: String
    var body: String
    var createdAt: Date
    var updatedAt: Date
    var isBookmarked: Bool

    init(id: UUID = UUID(), title: String, body: String, createdAt: Date = .now, updatedAt: Date = .now, isBookmarked: Bool = false) {
        self.id = id
        self.title = title
        self.body = body
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isBookmarked = isBookmarked
    }
}
