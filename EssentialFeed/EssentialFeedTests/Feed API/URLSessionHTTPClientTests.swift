//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Anne on 17/11/21.
//

import EssentialFeed
import XCTest

class URLSessionHTTPClientTests: XCTestCase {
    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequests()
    }

    override func tearDown() {
        URLProtocolStub.stopInterceptingRequests()
    }

    func test_getFromURL_failsOnRequestError() {
        let requestError = anyNSError
        let receivedError = resultErrorFor(data: nil, response: nil, error: requestError) as NSError?

        XCTAssertEqual(requestError.domain, receivedError?.domain)
        XCTAssertEqual(requestError.code, receivedError?.code)
    }

    func test_getFromURL_failsOnAllInvalidRepresentationCases() {
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: nil, error: anyNSError))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse, error: anyNSError))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse, error: anyNSError))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: nonHTTPURLResponse, error: anyNSError))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: anyHTTPURLResponse, error: anyNSError))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: nonHTTPURLResponse, error: nil))
    }

    func test_getFromURL_succeedsOnHTTPURLRespnseWithData() {
        let data = anyData
        let response = anyHTTPURLResponse

        let receivedDataResponse = resultDataResponseFor(data: data, response: response, error: nil)

        XCTAssertEqual(receivedDataResponse?.data, data)
        XCTAssertEqual(receivedDataResponse?.response.url, response.url)
        XCTAssertEqual(receivedDataResponse?.response.statusCode, response.statusCode)
    }

    func test_getFromURL_succeedsWithEmptyDataOnHTTPURLResponseWithNilData() {
        let response = anyHTTPURLResponse

        let receivedDataResponse = resultDataResponseFor(data: nil, response: response, error: nil)

        let emptyData = Data()
        XCTAssertEqual(receivedDataResponse?.data, emptyData)
        XCTAssertEqual(receivedDataResponse?.response.url, response.url)
        XCTAssertEqual(receivedDataResponse?.response.statusCode, response.statusCode)
    }
}

// MARK: - Helpers, Doubles, Stubs and Spies
private extension URLSessionHTTPClientTests {
    // MARK: Helper Variables
    var anyURL: URL {
        URL(string: "http://any-url.com")!
    }

    var anyData: Data {
        Data("any data".utf8)
    }

    var anyNSError: NSError {
        NSError(domain: "any error", code: 0)
    }

    var anyHTTPURLResponse: HTTPURLResponse {
        HTTPURLResponse(url: anyURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
    }

    var nonHTTPURLResponse: URLResponse {
        URLResponse(url: anyURL, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }

    // MARK: Helper Methods
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    func resultFor(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        file: StaticString = #file,
        line: UInt = #line
    ) -> HTTPClientResult {
        URLProtocolStub.stub(url: anyURL, data: data, response: response, error: error)

        let sut = makeSUT(file: file, line: line)
        let exp = expectation(description: "Wait for completion")

        var receivedResult: HTTPClientResult!

        sut.get(from: anyURL) { result in
            receivedResult = result
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
        return receivedResult
    }

    private func resultDataResponseFor(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        data: Data,
        response: HTTPURLResponse
    )? {
            let result = resultFor(data: data, response: response, error: error, file: file, line: line)

            switch result {
            case let .success(data, response):
                return (data, response)
            default:
                XCTFail("Expected success, got \(result) instead", file: file, line: line)
                return nil
            }
        }

    private func resultErrorFor(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Error? {
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)

        switch result {
        case let .failure(error):
            return error
        default:
            XCTFail("Expected failure, got \(result) instead", file: file, line: line)
            return nil
        }
    }
}

private extension URLSessionHTTPClientTests {
    private class URLProtocolStub: URLProtocol {
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?

        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }

        static func stub(url: URL, data: Data?, response: URLResponse?, error: Error?) {
            stub = Stub(data: data, response: response, error: error)
        }

        static func observeRequests(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }

        static func startInterceptingRequests() {
            URLProtocol.registerClass(Self.self)
        }

        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(Self.self)
            stub = nil
            requestObserver = nil
        }


        // MARK: Abstract class methods
        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
            return true
        }

        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            request
        }

        override func startLoading() {
            if let data = Self.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }

            if let response = Self.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }

            if let error = Self.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }

            client?.urlProtocolDidFinishLoading(self)
        }

        override func stopLoading() { }
    }
}
