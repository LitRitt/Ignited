//
//  UIApplication+Webpage.swift
//  Delta
//
//  Created by Chris Rittenhouse on 11/8/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import UIKit
import SafariServices

extension UIApplication
{
    func openWebpage(site: String)
    {
        let safariURL = URL(string: site)!
        let safariViewController = SFSafariViewController(url: safariURL)
        safariViewController.preferredControlTintColor = UIColor.themeColor
        self.topViewController()?.present(safariViewController, animated: true, completion: nil)
    }
    
    func openAppOrWebpage(site: String)
    {
        let appURL = URL(string: site)!
        
        UIApplication.shared.open(appURL, options: [:]) { (success) in
            guard !success else { return }
            
            let safariURL = URL(string: site)!
            let safariViewController = SFSafariViewController(url: safariURL)
            safariViewController.preferredControlTintColor = UIColor.themeColor
            self.topViewController()?.present(safariViewController, animated: true, completion: nil)
        }
    }
}
