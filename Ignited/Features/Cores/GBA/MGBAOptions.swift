//
//  MGBAOptions.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 3/22/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import SwiftUI

import Features

struct MGBAOptions
{
    @Option(name: "Game Boy Player",
            description: "Forces the core to use the Game Boy Player.",
            attributes: [.hidden(when: {true})])
    var forceGBP: Bool = false
    
    @Option(name: "Frameskip",
            description: "Choose how much frames should be skipped to improve performance at the expense of visual smoothness.",
            values: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
    var frameskip: Int32 = 0
    
    @Option(name: "Idle Loop Removal",
            description: "Optimizes game performance by driving the GBA's CPU less hard. Use this on low-powered hardware if its struggling with game performance.",
            values: GBIdleOptimization.allCases)
    var idleOptimization: GBIdleOptimization = .remove
}
