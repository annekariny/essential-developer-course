//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Anne on 07/12/21.
//

import Foundation

struct RemoteFeedItem: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}
