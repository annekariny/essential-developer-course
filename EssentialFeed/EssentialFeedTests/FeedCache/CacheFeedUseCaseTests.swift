//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Anne on 29/11/21.
//

import XCTest
import EssentialFeed

class LocalFeedLoader {
    private let store: FeedStore
    
    init(store: FeedStore) {
        self.store = store
    }
}

class FeedStore {
    enum ReceivedMessage: Equatable {
        case deletion
        case insertion(items: [FeedItem])
    }
    
    var receivedMessages = [ReceivedMessage]()
}

class CacheFeedUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
}

private extension CacheFeedUseCaseTests {
    func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (localFeedLoader: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let localFeedLoader = LocalFeedLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(localFeedLoader, file: file, line: line)
        return (localFeedLoader, store)
    }
}
