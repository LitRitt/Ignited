//
//  UIColor+Theme.swift
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
    static var themeColor: UIColor
    {
        let baseColor: UIColor
        
        if Settings.userInterfaceFeatures.theme.isEnabled
        {
            return Settings.userInterfaceFeatures.theme.color.uiColor
        }
        else
        {
            return ThemeColor.orange.uiColor
        }
    }
}
