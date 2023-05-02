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
        if UserInterfaceFeatures.shared.theme.isEnabled
        {
            if UserInterfaceFeatures.shared.theme.useCustom
            {
                guard let color = UserInterfaceFeatures.shared.theme.customColor.cgColor else { return .ignitedOrange }
                
                return UIColor(cgColor: color)
            }
            else
            {
                switch UserInterfaceFeatures.shared.theme.accentColor
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
