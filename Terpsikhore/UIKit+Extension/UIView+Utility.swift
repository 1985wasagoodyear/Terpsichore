//
//  UIView+Utility.swift
//  Terpsikhore
//
//  Created by K Y on 1/9/20.
//  Copyright © 2020 Yu. All rights reserved.
//

import UIKit

extension UIView {
    func fillIn(_ view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self)
        let constraints = [
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topAnchor.constraint(equalTo: view.topAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
