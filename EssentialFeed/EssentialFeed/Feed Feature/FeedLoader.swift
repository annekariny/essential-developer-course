//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Anne Kariny Silva Freitas on 06/11/21.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedImage])
    case failure(Error)
}

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
