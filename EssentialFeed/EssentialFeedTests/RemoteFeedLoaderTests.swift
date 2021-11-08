//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Anne Kariny Silva Freitas on 06/11/21.
//

import EssentialFeed
import XCTest

final class RemoteFeedLoaderTests: XCTestCase {
    private let httpClientSpy = HTTPClientSpy()

    func test_init_doesNotRequestDataFromURL() {
        makeSut(url: URL(string: "test-url.com")!)

        XCTAssertTrue(httpClientSpy.requestedURLs.isEmpty)
    }

    func test_load_requestsDataFromURL() {
        let url = URL(string: "test-url.com")!
        let sut = makeSut(url: url)

        sut.load()

        XCTAssertEqual(httpClientSpy.requestURLCallCount, 1)

        XCTAssertFalse(httpClientSpy.requestedURLs.isEmpty)
        XCTAssertEqual([url], httpClientSpy.requestedURLs)
    }

    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "test-url.com")!
        let sut = makeSut(url: url)

        sut.load()
        sut.load()

        XCTAssertEqual(httpClientSpy.requestURLCallCount, 2)

        XCTAssertFalse(httpClientSpy.requestedURLs.isEmpty)
        XCTAssertEqual([url, url], httpClientSpy.requestedURLs)
    }
}

// MARK: - Helpers
private extension RemoteFeedLoaderTests {
    @discardableResult
    private func makeSut(url: URL) -> RemoteFeedLoader {
        RemoteFeedLoader(client: httpClientSpy, url: url)
    }

    // MARK: - Doubles/Spies/Mocks
    final class HTTPClientSpy: HTTPClient {

        private(set) var requestURLCallCount = 0
        var requestedURLs = [URL]()

        func get(from url: URL) {
            requestURLCallCount += 1
            requestedURLs.append(url)
        }
    }
}
