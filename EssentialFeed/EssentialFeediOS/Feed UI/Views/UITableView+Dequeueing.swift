//
//  UITableView+Dequeueing.swift
//  EssentialFeediOS
//
//  Created by Anne Kariny Silva Freitas on 29/01/23.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
