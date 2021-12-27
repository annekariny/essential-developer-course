//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by Anne on 17/12/21.
//

import Foundation

final class FeedCachePolicy {
    private static let calendar = Calendar.init(identifier: .gregorian)
    private init() { }
    
    private static var maxCacheAgeInDays: Int {
        7
    }
    
    static func validade(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {
            return false
        }
        return date < maxCacheAge
    }
}
