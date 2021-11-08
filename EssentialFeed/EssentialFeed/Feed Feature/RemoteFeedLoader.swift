//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Anne Kariny Silva Freitas on 06/11/21.
//

import Foundation

final class RemoteFeedLoader {
    let client: HTTPClient
    let url: URL

    init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }

    func load() {
        client.get(from: url)
    }
}

protocol HTTPClient {
    func get(from url: URL)
}
