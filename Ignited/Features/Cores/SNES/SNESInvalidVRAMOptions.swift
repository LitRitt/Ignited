//
//  SNESInvalidVRAMOptions.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 1/9/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import SwiftUI

import Features

struct SNESInvalidVRAMOptions
{
    @Option
    var enabledGames: [String] = []
    
    @Option(name: "Reset Enabled Games",
            description: "Disable Invalid VRAM Access for all games.",
            detailView: { _ in
        Button("Reset Enabled Games") {
            PowerUserOptions.resetFeature(.snesInvalidVRAM)
        }
        .font(.system(size: 17, weight: .bold, design: .default))
        .foregroundColor(.red)
        .displayInline()
    })
    var reset: Bool = false
}
