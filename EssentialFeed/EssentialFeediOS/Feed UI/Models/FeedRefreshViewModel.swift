//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by Anne Kariny Silva Freitas on 29/01/23.
//

import Foundation
import EssentialFeed

final class FeedRefreshViewModel {
    private let feedLoader: FeedLoader
    
    var onChange: ((FeedRefreshViewModel) -> Void)?
    var onFeedLoad: (([FeedImage]) -> Void)?
    
    private(set) var isLoading: Bool = false {
        didSet {
            onChange?(self)
        }
    }

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    func loadFeed() {
        isLoading = true
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.onFeedLoad?(feed)
            }
            self?.isLoading = false
        }
    }
}
