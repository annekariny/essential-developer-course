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

        sut.load { _ in }

        XCTAssertEqual(httpClientSpy.requestedURLs, [url])
    }

    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "test-url.com")!
        let sut = makeSut(url: url)

        sut.load { _ in }
        sut.load { _ in }

        XCTAssertEqual(httpClientSpy.requestedURLs, [url, url])
    }

    func test_load_deliversErrorOnClientError() {
        let url = URL(string: "test-url.com")!
        let sut = makeSut(url: url)

        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load { capturedErrors.append($0) }

        let clientError = NSError(domain: "TestError", code: 0)
        httpClientSpy.complete(with: clientError)

        XCTAssertEqual(capturedErrors, [.connectivity])
    }

    func test_load_deliversErrorOnNon220HTTPResponse() {
        let statusCodeSamples = [199, 201, 300, 400, 500]

        let url = URL(string: "test-url.com")!
        let sut = makeSut(url: url)

        statusCodeSamples.enumerated().forEach { index, code in
            var capturedErrors = [RemoteFeedLoader.Error]()
            sut.load { capturedErrors.append($0) }

            httpClientSpy.complete(withStatusCode: code, at: index)

            XCTAssertEqual(capturedErrors, [.invalidData])
        }
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
        private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()

        var requestedURLs: [URL] {
            messages.map { $0.url }
        }

        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }

        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }

        func complete(withStatusCode code: Int, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            messages[index].completion(.success(response))
        }
    }
}
