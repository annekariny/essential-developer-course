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
        let presenter = FeedPresenter()
        let presentationAdapter = FeedLoaderPresentationAdapter(
            feedLoader: feedLoader,
            feedPresenter: presenter
        )
        let refreshController = FeedRefreshViewController(
            loadFeed: presentationAdapter.loadFeed
        )
        let feedController = FeedViewController(
            refreshController: refreshController
        )
        presenter.loadingView = WeakRefVirtualProxy(
            refreshController
        )
        presenter.feedView = FeedViewAdapter(
            controller: feedController,
            imageLoader: imageLoader
        )
        return feedController
    }
}

private final class WeakRefVirtualProxy<T:AnyObject> {
    private weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel) {
        object?.display(viewModel)
    }
}

private final class FeedViewAdapter: FeedView {
    private weak var controller: FeedViewController?
    private let imageLoader: FeedImageDataLoader
    
    init(controller: FeedViewController, imageLoader: FeedImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.tableModel = viewModel.feed.map { model in
            FeedImageCellController(
                viewModel: FeedImageCellViewModel(
                    model: model,
                    imageLoader: imageLoader,
                    imageTransformer: UIImage.init
                )
            )
        }
    }
}

private final class FeedLoaderPresentationAdapter {
    private let feedLoader: FeedLoader
    private let feedPresenter: FeedPresenter
    
    init(feedLoader: FeedLoader, feedPresenter: FeedPresenter) {
        self.feedLoader = feedLoader
        self.feedPresenter = feedPresenter
    }
    
    func loadFeed() {
        feedPresenter.didStartLoadingFeed()
        
        feedLoader.load { [weak self] result in
            switch result {
            case let .success(feed):
                self?.feedPresenter.didFinishLoadingFeed(with: feed)
                
            case let .failure(error):
                self?.feedPresenter.didFinishLoadingFeed(with: error)
            }
        }
    }
}
