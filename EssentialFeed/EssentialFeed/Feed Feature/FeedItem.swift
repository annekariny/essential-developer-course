//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Anne Kariny Silva Freitas on 06/11/21.
//

import Foundation

public struct FeedItem {
    let id: UUID
    let description: String?
    let location: String?
    let imageURL: URL

    public init(
        id: UUID,
        description: String?,
        location: String?,
        imageURL: URL
    ) {
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = imageURL
    }
}
