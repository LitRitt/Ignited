//
//  GameAudioOptions.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 4/30/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import SwiftUI

import Features

struct GameAudioOptions
{
    @Option(name: "Game Volume", description: "Change how loud the game volume should be.", detailView: { value in
        VStack {
            HStack {
                Text("Volume: \(value.wrappedValue * 100, specifier: "%.f")%")
                Spacer()
            }
            HStack {
                Text("0%")
                Slider(value: value, in: 0.0...1.0, step: 0.05)
                Text("100%")
            }
        }.displayInline()
    })
    var volume: Double = 1.0
    
    @Option(name: "Respect Silent Mode",
            description: "Enable to silence game audio when the device is in silent mode.")
    var respectSilent: Bool = true
    
    @Option(name: "Play Over Other Media",
            description: "Enable to play game audio over other media, such as voice chat or videos.")
    var playOver: Bool = true
    
    @Option(name: "Restore Defaults",
            description: "Reset all options to their default values.",
            detailView: { _ in
        Button("Restore Defaults") {
            PowerUserOptions.resetFeature(.gameAudio)
        }
        .font(.system(size: 17, weight: .bold, design: .default))
        .foregroundColor(.red)
        .displayInline()
    })
    var resetGameAudio: Bool = false
}
