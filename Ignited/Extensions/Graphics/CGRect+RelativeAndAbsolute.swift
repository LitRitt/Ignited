//
//  CGRect+RelativeAndAbsolute.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 3/1/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import CoreGraphics
import UIKit

import DeltaCore

public extension CGRect
{
    func getAbsolute(for traits: DeltaCore.ControllerSkin.Traits, inputMappingMode: Bool = false) -> CGRect
    {
        guard !inputMappingMode else {
            return self.applying(CGAffineTransform(scaleX: 414, y: 736))
        }
        
        switch (traits.displayType, traits.orientation)
        {
        case (.splitView, .portrait): return self.applying(CGAffineTransform(scaleX: UIScreen.main.bounds.width, y: UIScreen.main.bounds.height * Settings.standardSkinFeatures.inputsAndLayout.splitViewPortraitSize))
        case (.splitView, .landscape): return self.applying(CGAffineTransform(scaleX: UIScreen.main.bounds.width, y: UIScreen.main.bounds.height * Settings.standardSkinFeatures.inputsAndLayout.splitViewLandscapeSize))
        default: return self.applying(CGAffineTransform(scaleX: UIScreen.main.bounds.width, y: UIScreen.main.bounds.height))
        }
    }
    
    func getRelative(for traits: DeltaCore.ControllerSkin.Traits, inputMappingMode: Bool = false) -> CGRect
    {
        guard !inputMappingMode else {
            return self.applying(CGAffineTransform(scaleX: 1 / 414, y: 1 / 736))
        }
        
        switch (traits.displayType, traits.orientation)
        {
        case (.splitView, .portrait): return self.applying(CGAffineTransform(scaleX: 1 / UIScreen.main.bounds.width, y: 1 / (UIScreen.main.bounds.height * Settings.standardSkinFeatures.inputsAndLayout.splitViewPortraitSize)))
        case (.splitView, .landscape): return self.applying(CGAffineTransform(scaleX: 1 / UIScreen.main.bounds.width, y: 1 / (UIScreen.main.bounds.height * Settings.standardSkinFeatures.inputsAndLayout.splitViewLandscapeSize)))
        default: return self.applying(CGAffineTransform(scaleX: 1 / UIScreen.main.bounds.width, y: 1 / UIScreen.main.bounds.height))
        }
    }
}
