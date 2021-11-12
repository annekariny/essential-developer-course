//
//  HttpClient.swift
//  EssentialFeed
//
//  Created by Anne Kariny Silva Freitas on 12/11/21.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
