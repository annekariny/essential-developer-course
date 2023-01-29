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
    
    private enum State {
        case pending
        case loading
        case loaded([FeedImage])
        case failed
    }
    
    private var state = State.pending {
        didSet {
            onChange?(self)
        }
    }
    
    var isLoading: Bool {
        switch state {
        case .loading:
            return true
        default:
            return false
        }
    }
    
    var feed: [FeedImage]? {
        switch state {
        case .loaded(let feed):
            return feed
        default:
            return nil
        }
    }

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    func loadFeed() {
        state = .loading
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.state = .loaded(feed)
            } else {
                self?.state = .failed
            }
        }
    }
}
