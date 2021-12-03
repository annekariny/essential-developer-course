//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Anne on 29/11/21.
//

import XCTest
import EssentialFeed

final class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void) {
        store.deleteCacheFeed { [unowned self] error in
            if error == nil {
                store.insert(items, timestamp: self.currentDate(), completion: completion)
            } else {
                completion(error)
            }
        }
    }
}

protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    func deleteCacheFeed(completion: @escaping DeletionCompletion)
    func insert(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion)
}

final class FeedStoreSpy: FeedStore {
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
    
    func completeDeletionSuccessfuly(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func insert(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion) {
        insertionCompletions.append(completion)
        receivedMessages.append(.insert(items, timestamp))
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
         insertionCompletions[index](error)
     }

     func completeInsertionSuccessfully(at index: Int = 0) {
         insertionCompletions[index](nil)
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
        
        localFeedLoader.save(items) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (localFeedLoader, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        
        localFeedLoader.save(items) { _ in }
        store.completeDeletion(with: anyNSError)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_request_newCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let items = [uniqueItem(), uniqueItem()]
        let (localFeedLoader, store) = makeSUT(currentDate: { timestamp })
        
        localFeedLoader.save(items) { _ in }
        store.completeDeletionSuccessfuly()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert(items, timestamp)])
    }
    
    func test_save_failsOnDeletionError() {
        let (localFeedLoader, store) = makeSUT()
        let deletionError = anyNSError
        
        expectSave(localFeedLoader, toCompleteWithError: deletionError) {
            store.completeDeletion(with: deletionError)
        }
    }
    
    func test_save_failsOnInsertionError() {
        let (localFeedLoader, store) = makeSUT()
        let insertionError = anyNSError
        
        expectSave(localFeedLoader, toCompleteWithError: insertionError) {
            store.completeDeletionSuccessfuly()
            store.completeInsertion(with: insertionError)
        }
    }
    
    func test_save_succeedsOnSuccessfulCacheInsertion() {
        let (localFeedLoader, store) = makeSUT()
        
        expectSave(localFeedLoader, toCompleteWithError: nil) {
            store.completeDeletionSuccessfuly()
            store.completeInsertionSuccessfully()
        }
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
        currentDate: @escaping () -> Date = Date.init,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (
        localFeedLoader: LocalFeedLoader,
        store: FeedStoreSpy
    ) {
        let store = FeedStoreSpy()
        let localFeedLoader = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(localFeedLoader, file: file, line: line)
        return (localFeedLoader, store)
    }
    
    func expectSave(
        _ sut: LocalFeedLoader,
        toCompleteWithError expectedError: NSError?,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for save completion")
        var receivedError: Error?
        
        sut.save([uniqueItem()]) { error in
            receivedError = error
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as NSError?, expectedError, file: file, line: line)
    }
}
