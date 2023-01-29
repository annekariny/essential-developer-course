//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Anne on 31/10/22.
//

import UIKit
import EssentialFeed

public final class FeedUIComposer {
    private init() {}

    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let refreshViewModel = FeedRefreshViewModel(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(viewModel: refreshViewModel)
        let feedController = FeedViewController(refreshController: refreshController)
        refreshViewModel.onFeedLoad = adaptFeedToCellControllers(forwardingTo: feedController, loader: imageLoader)
        return feedController
    }

    private static func adaptFeedToCellControllers(forwardingTo controller: FeedViewController, loader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
        return { [weak controller] feed in
            controller?.tableModel = feed.map { model in
                FeedImageCellController(viewModel:
                                    FeedImageCellViewModel(model: model, imageLoader: loader))
            }
        }
    }
}
