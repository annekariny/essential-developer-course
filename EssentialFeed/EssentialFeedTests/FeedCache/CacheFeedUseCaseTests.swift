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
    
    func save(_ items: [FeedItem]) {
        store.deleteCacheFeed { error in
            if error == nil {
                
            } else {
                
            }
        }
    }
}

class FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    enum ReceivedMessage: Equatable {
        case deleteCachedFeed
        case insert([FeedItem], Date)
    }
    
    private(set) var receivedMessages = [ReceivedMessage]()
    
    private var deletionCompletions = [DeletionCompletion]()
    private var insertionCompletions = [InsertionCompletion]()
    
    func deleteCacheFeed(completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        receivedMessages.append(.deleteCachedFeed)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
}

class CacheFeedUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_requestsCacheDeletion() {
        let (localFeedLoader, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        
        localFeedLoader.save(items)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (localFeedLoader, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        
        localFeedLoader.save(items)
        store.completeDeletion(with: anyNSError)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
}

private extension CacheFeedUseCaseTests {
    var anyURL: URL {
        URL(string: "http://any-url.com")!
    }
    
    var anyNSError: NSError {
        NSError(domain: "any error", code: 0)
    }
    
    func uniqueItem() -> FeedItem {
        FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL)
    }
    
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
