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
        let sut = makeSut()

        expectLoad(sut, toCompleteWithResult: .failure(.connectivity), when: {
            let clientError = NSError(domain: "TestError", code: 0)
            httpClientSpy.complete(with: clientError)
        })
    }

    func test_load_deliversErrorOnNon220HTTPResponse() {
        let statusCodeSamples = [199, 201, 300, 400, 500]

        let sut = makeSut()

        statusCodeSamples.enumerated().forEach { index, code in
            expectLoad(sut, toCompleteWithResult: .failure(.invalidData), when:  {
                let itemsJSON = makeItemsJSON([])
                httpClientSpy.complete(withStatusCode: code, data: itemsJSON, at: index)
            })
        }
    }

    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let sut = makeSut()

        expectLoad(sut, toCompleteWithResult: .failure(.invalidData), when: {
            let invalidJSON = Data("invalid json".utf8)
            httpClientSpy.complete(withStatusCode: 200, data: invalidJSON)
        })
    }

    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let sut = makeSut()

        expectLoad(sut, toCompleteWithResult: .success([]), when: {
            let json = makeItemsJSON([])
            httpClientSpy.complete(withStatusCode: 200, data: json)
        })
    }

    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        let sut = makeSut()
        let feedItem = makeFeedItem(
            id: UUID(),
            description: "description",
            location: "location",
            imageURL: URL(string: "http://a-url.com")!
        )

        expectLoad(sut, toCompleteWithResult: .success([feedItem.model]), when: {
            let json = makeItemsJSON([feedItem.json])
            httpClientSpy.complete(withStatusCode: 200, data: json)
        })
    }
}

// MARK: - Helpers
private extension RemoteFeedLoaderTests {
    func expectLoad(
        _ sut: RemoteFeedLoader,
        toCompleteWithResult result: RemoteFeedLoader.Result,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        var capturedResults = [RemoteFeedLoader.Result]()
        sut.load { capturedResults.append($0) }

        action()

        XCTAssertEqual(capturedResults, [result], file: file, line: line)
    }

    // MARK: - Factories
    @discardableResult
    func makeSut(url: URL = URL(string: "test-url.com")!) -> RemoteFeedLoader {
        RemoteFeedLoader(client: httpClientSpy, url: url)
    }

    func makeFeedItem(
        id: UUID,
        description: String? = nil,
        location: String? = nil,
        imageURL: URL
    ) -> (model: FeedItem, json: [String: Any]) {
        let item = FeedItem(id: id, description: description, location: location, imageURL: imageURL)

        let json = [
            "id": id.uuidString,
            "description": description as Any,
            "location": location as Any,
            "image": imageURL.absoluteString
        ].compactMapValues { $0 }

        return (item, json)
    }

    func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
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

        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            messages[index].completion(.success(data, response))
        }
    }
}
