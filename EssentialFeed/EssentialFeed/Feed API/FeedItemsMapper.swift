//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Anne Kariny Silva Freitas on 12/11/21.
//

import Foundation

final class FeedItemsMapper {
    private struct Root: Decodable {
        let items: [Item]
    }

    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL

        var feedItem: FeedItem {
            FeedItem(
                id: id,
                description: description,
                location: location,
                imageURL: image
            )
        }
    }

    private static var STATUS_OK = 200

    static func map(_ data: Data, _ response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard
            response.statusCode == STATUS_OK,
            let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        let feedItems = root.items.map { $0.feedItem }
        return .success(feedItems)
    }
}
