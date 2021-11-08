//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Anne Kariny Silva Freitas on 06/11/21.
//

@testable import EssentialFeed
import XCTest

final class RemoteFeedLoaderTests: XCTestCase {
    private let httpClientSpy = HTTPClientSpy()

    func test_init_doesNotRequestDataFromURL() {
        makeSut(url: URL(string: "test-url.com")!)
        XCTAssertNil(httpClientSpy.getURLRequested)
    }

    func test_load_requestDataFromURL() {
        let url = URL(string: "test-url.com")!
        let sut = makeSut(url: url)

        sut.load()

        XCTAssertTrue(httpClientSpy.getCalled)
        XCTAssertNotNil(httpClientSpy.getURLRequested)
        XCTAssertEqual(url, httpClientSpy.getURLRequested)
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

        private(set) var getCalled = false
        var getURLRequested: URL?

        func get(from url: URL) {
            getCalled = true
            getURLRequested = url
        }
    }
}
