//
//  FastForward.swift
//  Delta
//
//  Created by Chris Rittenhouse on 4/30/23.
//  Copyright © 2023 Lit Development. All rights reserved.
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
    
    @Option(name: "Choose Speed Each Activation",
            description: "Enable to choose a speed each time you activate fast forward, instead of using the set speed above.")
    var prompt: Bool = true
    
    @Option(name: "Show Slowmo Speeds",
            description: "Enable to show speed choices that slow down gameplay instead of speeding it up.")
    var slowmo: Bool = true
    
    @Option(name: "Show Unsafe Speeds",
            description: "Enable to show speed choices that are above those determined to be safe.")
    var unsafe: Bool = true
}
