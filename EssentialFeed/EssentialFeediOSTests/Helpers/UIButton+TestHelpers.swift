//
//  UIButton+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Anne on 31/10/22.
//

import UIKit

extension UIButton {
    func simulateTap() {
        simulate(event: .touchUpInside)
    }
}
