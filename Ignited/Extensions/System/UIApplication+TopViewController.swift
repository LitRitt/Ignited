//
//  UIApplication+TopViewController.swift
//  Delta
//
//  Created by Chris Rittenhouse on 8/5/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import UIKit

extension UIApplication
{
    func topViewController() -> UIViewController?
    {
        var topViewController: UIViewController? = nil
        
        for scene in connectedScenes
        {
            if let windowScene = scene as? UIWindowScene
            {
                for window in windowScene.windows
                {
                    if window.isKeyWindow
                    {
                        topViewController = window.rootViewController
                    }
                }
            }
        }
        
        while true
        {
            if let presented = topViewController?.presentedViewController
            {
                topViewController = presented
            }
            else if let navController = topViewController as? UINavigationController
            {
                topViewController = navController.topViewController
            }
            else if let tabBarController = topViewController as? UITabBarController
            {
                topViewController = tabBarController.selectedViewController
            }
            else
            {
                // Handle any other third party container in `else if` if required
                break
            }
        }
        return topViewController
    }
}
