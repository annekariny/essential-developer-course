//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Anne Kariny Silva Freitas on 29/01/23.
//

import Foundation

struct FeedImageViewModel<Image> {
    let description: String?
    let location: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool

    var hasLocation: Bool {
        return location != nil
    }
}
