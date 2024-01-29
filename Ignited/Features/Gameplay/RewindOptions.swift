//
//  RewindOptions.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 4/30/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import SwiftUI

import Features

struct RewindOptions
{
    @Option(name: "Keep Save States",
            description: "Enable to keep save states even after quitting a game. This let's you use rewind as a secondary auto-save method. Disable to use rewind purely as a convenience feature. States will be deleted when quitting a game.")
    var keepStates: Bool = true
    
    @Option(name: "Interval",
            description: "Change how often the game state should be saved.",
            range: 3...15,
            step: 1,
            unit: "s")
    var interval: Double = 15
    
    @Option(name: "Maximum States",
            description: "The maximum number of states to save before the oldest state gets deleted. Increasing this will allow you to rewind further back in time, at the cost of larger device storage usage.",
            range: 10...50,
            step: 1)
    var maxStates: Double = 30
    
    @Option(name: "Restore Defaults",
            description: "Reset all options to their default values.",
            detailView: { _ in
        Button("Restore Defaults") {
            PowerUserOptions.resetFeature(.saveStateRewind)
        }
        .font(.system(size: 17, weight: .bold, design: .default))
        .foregroundColor(.red)
        .displayInline()
    })
    var reset: Bool = false
}
