//
//  UIColor+AdjustHSBA.swift
//  Delta
//
//  Created by Chris Rittenhouse on 3/23/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import UIKit

extension UIColor
{
    // Component add function that clamps between 0 and 1.
    private func add(_ value: CGFloat, toComponent: CGFloat) -> CGFloat {
        return max(0, min(1, toComponent + value))
    }
    
    // General purpose HSBA adjustment function used by public functions.
    func adjustHSBA(hueDelta: CGFloat, saturationDelta: CGFloat, brightnessDelta: CGFloat, alphaDelta: CGFloat) -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        return UIColor(
            hue: add(hueDelta, toComponent: hue),
            saturation: add(saturationDelta, toComponent: saturation),
            brightness: add(brightnessDelta, toComponent: brightness),
            alpha: add(alphaDelta, toComponent: alpha)
        )
    }
    
    // HSBA adjustment functions.
    func adjustHue(_ hueDelta: CGFloat) -> UIColor {
        return adjustHSBA(hueDelta: hueDelta, saturationDelta: 0, brightnessDelta: 0, alphaDelta: 0)
    }
    
    func adjustSaturation(_ saturationDelta: CGFloat) -> UIColor {
        return adjustHSBA(hueDelta: 0, saturationDelta: saturationDelta, brightnessDelta: 0, alphaDelta: 0)
    }
    
    func adjustBrightness(_ brightnessDelta: CGFloat) -> UIColor {
        return adjustHSBA(hueDelta: 0, saturationDelta: 0, brightnessDelta: brightnessDelta, alphaDelta: 0)
    }
    
    func adjustAlpha(_ alphaDelta: CGFloat) -> UIColor {
        return adjustHSBA(hueDelta: 0, saturationDelta: 0, brightnessDelta: 0, alphaDelta: alphaDelta)
    }
    
    // HSBA change functions.
    func changeHue(_ newHue: CGFloat) -> UIColor {
        guard 0 <= newHue && newHue <= 1 else { return self }
        
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        return UIColor(hue: newHue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
    
    func changeSaturation(_ newSaturation: CGFloat) -> UIColor {
        guard 0 <= newSaturation && newSaturation <= 1 else { return self }
        
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        return UIColor(hue: hue, saturation: newSaturation, brightness: brightness, alpha: alpha)
    }
    
    func changeBrightness(_ newBrightness: CGFloat) -> UIColor {
        guard 0 <= newBrightness && newBrightness <= 1 else { return self }
        
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        return UIColor(hue: hue, saturation: saturation, brightness: newBrightness, alpha: alpha)
    }
    
    func changeAlpha(_ newAlpha: CGFloat) -> UIColor {
        guard 0 <= newAlpha && newAlpha <= 1 else { return self }
        
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: newAlpha)
    }
    
    // Changes brightness based on device dark mode setting. Brighter in dark mode, darker in light mode.
    func dynamicBrightness(_ brightnessDelta: CGFloat = 0.05, offset: CGFloat = 0) -> UIColor {
        switch UITraitCollection.current.userInterfaceStyle
        {
        case .light:
            return adjustBrightness(-1 * brightnessDelta + offset)
        case .dark, .unspecified:
            return adjustBrightness(brightnessDelta + offset)
        @unknown default:
            return adjustBrightness(brightnessDelta + offset)
        }
    }
}
