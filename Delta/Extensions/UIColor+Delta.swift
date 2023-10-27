//
//  UIColor+Delta.swift
//  Delta
//
//  Created by Riley Testut on 12/26/15.
//  Copyright © 2015 Riley Testut. All rights reserved.
//

import UIKit
import SwiftUI

import Features

extension UIColor
{
    static let ignitedOrange = UIColor(named: "Orange")!
    static let deltaPurple = UIColor(named: "Purple")!
    static let ignitedMint = UIColor(named: "Mint")!
    static let ignitedDarkGray = UIColor(named: "DarkGray")!
    static let ignitedLightGray = UIColor(named: "LightGray")!
    
    static var themeColor: UIColor
    {
        if Settings.userInterfaceFeatures.theme.isEnabled
        {
            if Settings.userInterfaceFeatures.theme.useCustom
            {
                guard let color = Settings.userInterfaceFeatures.theme.customColor.cgColor else { return .ignitedOrange }
                
                return UIColor(cgColor: color)
            }
            else
            {
                switch Settings.userInterfaceFeatures.theme.accentColor
                {
                case .orange:
                    return ignitedOrange
                case .purple:
                    return deltaPurple
                case .blue:
                    return UIColor.systemBlue
                case .red:
                    return UIColor.systemRed
                case .green:
                    return UIColor.systemGreen
                case .teal:
                    return UIColor.systemTeal
                case .pink:
                    return UIColor.systemPink
                case .yellow:
                    return UIColor.systemYellow
                case .mint:
                    return ignitedMint
                }
            }
        }
        else
        {
            return ignitedOrange
        }
    }
}
