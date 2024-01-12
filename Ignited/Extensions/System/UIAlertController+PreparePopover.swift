//
//  UIAlertController+PreparePopover.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 1/11/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import UIKit

extension UIAlertController
{
    func preparePopoverPresentationController(_ view: UIView)
    {
        self.popoverPresentationController?.sourceView = view
        self.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.maxY, width: 0, height: 0)
        self.popoverPresentationController?.permittedArrowDirections = []
    }
}
