//
//  FastForwardOptions.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 4/30/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import SwiftUI

import Features

struct FastForwardOptions
{
    @Option(name: "Custom Speed", description: "Set your prefferred fast forward speed.", detailView: { value in
        VStack {
            HStack {
                Text("Custom Speed: \(value.wrappedValue * 100, specifier: "%.f")%")
                Spacer()
            }
            HStack {
                Text("50%")
                Slider(value: value, in: 0.5...4.0, step: 0.05)
                Text("400%")
            }
        }.displayInline()
    })
    var speed: Double = 3.0
    
    @Option(name: "Toggle Fast Forward",
            description: "When enabled, fast forward buttons will act as a toggle. When disabled, fast forward buttons only activate when held down.")
    var toggle: Bool = true
    
    @Option(name: "Choose Speed Each Activation",
            description: "Enable to choose a speed each time you activate fast forward, instead of using the set speed above.")
    var prompt: Bool = false
    
    @Option(name: "Show Slowmo Speeds",
            description: "Enable to show speed choices that slow down gameplay instead of speeding it up.")
    var slowmo: Bool = false
    
    @Option(name: "Show Unsafe Speeds",
            description: "Enable to show speed choices that are above those determined to be safe.")
    var unsafe: Bool = false
    
    @Option(name: "Restore Defaults",
            description: "Reset all options to their default values.",
            detailView: { _ in
        Button("Restore Defaults") {
            PowerUserOptions.resetFeature(.fastForward)
        }
        .font(.system(size: 17, weight: .bold, design: .default))
        .foregroundColor(.red)
        .displayInline()
    })
    var reset: Bool = false
}
