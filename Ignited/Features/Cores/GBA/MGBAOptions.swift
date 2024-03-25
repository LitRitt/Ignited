//
//  MGBAOptions.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 3/22/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import SwiftUI

import Features

enum GBAIdleOptimization: String, CaseIterable, CustomStringConvertible, LocalizedOptionValue
{
    case remove = "Remove Known"
    case detect = "Detect and Remove"
    case none = "Don't Remove"
    
    var description: String {
        return self.rawValue
    }
    
    var localizedDescription: Text {
        return Text(description)
    }
}

struct MGBAOptions
{
    @Option(name: "Frameskip",
            description: "Choose how much frames should be skipped to improve performance at the expense of visual smoothness.",
            values: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
    var frameskip: Int32 = 0
    
    @Option(name: "Light Level",
            description: "Choose the light level for games that use a light sensor.",
            values: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
    var lightLevel: Int32 = 0
    
    @Option(name: "Accelerometer Sensitivity",
            description: "Adjust the sensitivity of the accelerometer used in some GBA games.",
            range: 0.80...1.50,
            step: 0.05,
            unit: "%",
            isPercentage: true)
    var accelerometerSensitivity: Double = 1.0
    
    @Option(name: "Rumble Intensity",
            description: "Adjust the intensity of the rumble used in some GBA games.",
            range: 0.0...1.0,
            step: 0.05,
            unit: "%",
            isPercentage: true)
    var rumbleIntensity: Double = 1.0
    
    @Option(name: "Game Boy Player",
            description: "Enable Game Boy Player support. This will add rumble to certain games at the cost of causing performance issues.")
    var forceGBP: Bool = false
    
    @Option(name: "Idle Loop Removal",
            description: "Optimizes game performance by driving the GBA's CPU less hard. Use this on low-powered hardware if its struggling with game performance.",
            values: GBAIdleOptimization.allCases)
    var idleOptimization: GBAIdleOptimization = .remove
}
