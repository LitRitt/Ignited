//
//  UIColor+Battery.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 3/5/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import UIKit

import Features

extension UIColor
{
    static var batteryColor: UIColor
    {
        let batteryLevel = UIDevice.current.batteryLevel
        
        let relativeBatteryLevel: CGFloat
        let maxColorComponents: [CGFloat]
        let minColorComponents: [CGFloat]
        
        switch batteryLevel
        {
        case 0..<0.5:
            relativeBatteryLevel = CGFloat(batteryLevel * 2)
            maxColorComponents = UIColor.yellow.cgColor.components ?? []
            minColorComponents = UIColor.red.cgColor.components ?? []
            
        default:
            relativeBatteryLevel = CGFloat((batteryLevel - 0.5) * 2)
            maxColorComponents = UIColor.green.cgColor.components ?? []
            minColorComponents = UIColor.yellow.cgColor.components ?? []
        }
        
        let redComponent = minColorComponents[0] + ((maxColorComponents[0] - minColorComponents[0])  * relativeBatteryLevel) ?? 0
        let greenComponent = minColorComponents[1] + ((maxColorComponents[1] - minColorComponents[1])  * relativeBatteryLevel) ?? 0
        let blueComponent = minColorComponents[2] + ((maxColorComponents[2] - minColorComponents[2])  * relativeBatteryLevel) ?? 0
        
        return UIColor(red: redComponent, green: greenComponent, blue: blueComponent, alpha: 1)
    }
}
