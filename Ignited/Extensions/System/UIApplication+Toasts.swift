//
//  UIApplication+Toasts.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 1/9/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import UIKit

import Roxas

extension UIApplication
{
    func showToastNotification(text: String, detailText: String? = nil, duration: Double = 2.0)
    {
        guard let topViewController = UIApplication.shared.topViewController() else { return }
        
        let toast = RSTToastView(text: text, detailText: detailText)
        toast.show(in: topViewController.view, duration: duration)
    }
}
