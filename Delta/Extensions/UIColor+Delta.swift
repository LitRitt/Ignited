//
//  UIColor+Delta.swift
//  Delta
//
//  Created by Riley Testut on 12/26/15.
//  Copyright © 2015 Riley Testut. All rights reserved.
//

import UIKit

extension UIColor
{
    static let ignitedOrange = UIColor(named: "Orange")!
    static let deltaPurple = UIColor(named: "Purple")!
    static let ignitedDarkGray = UIColor(named: "DarkGray")!
    static let ignitedLightGray = UIColor(named: "LightGray")!
    
    static var themeColor: UIColor
    {
        switch Settings.themeColor
        {
        case .orange:
            return UIColor.ignitedOrange
        case .purple:
            return UIColor.deltaPurple
        }
    }
}
