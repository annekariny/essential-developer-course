//
//  FeedRefrestViewController.swift
//  EssentialFeediOS
//
//  Created by Anne on 31/10/22.
//

import UIKit
import EssentialFeed

final class FeedRefreshViewController: NSObject {
    private(set) lazy var view = binded(UIRefreshControl())
    private let viewModel: FeedRefreshViewModel
    
    var onRefresh: (([FeedImage]) -> Void)?

    init(viewModel: FeedRefreshViewModel) {
        self.viewModel = viewModel
    }

    @objc func refresh() {
        viewModel.loadFeed()
    }
    
    private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
        // Binds the view with the viewModel
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        // Bind the viewModel with the view
        viewModel.onChange = { [weak self] viewModel in
            if viewModel.isLoading {
                self?.view.beginRefreshing()
            } else {
                self?.view.endRefreshing()
            }
            
            if let feed = viewModel.feed {
                self?.onRefresh?(feed)
            }
        }
        return view
    }
}
