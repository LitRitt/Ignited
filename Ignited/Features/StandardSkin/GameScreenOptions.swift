//
//  GameScreenOptions.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 3/1/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import DeltaCore
import Features

import SwiftUI

extension DeltaCore.GameViewStyle: CustomStringConvertible, LocalizedOptionValue
{
    public var description: String {
        return self.rawValue
    }
    
    public var localizedDescription: Text {
        return Text(description)
    }
}

struct GameScreenOptions
{
    @Option(name: "Screen Style",
            description: "Choose the style to use for game screens.",
            values: DeltaCore.GameViewStyle.allCases)
    var style: DeltaCore.GameViewStyle = .floating
    
    @Option(name: "Fullscreen Landscape",
            description: "Enable to maximize the screen size in landscape. This may cause inputs to cover parts of the screen. Disable to fit the screen between the left and right side input areas.")
    var fullscreenLandscape: Bool = false
    
    @Option(name: "DS Top Screen Size",
            description: "Change the size of the top screen on DS. A higher percentage makes the top screen bigger and the bottom screen smaller.",
            range: 0.2...0.8,
            step: 0.05,
            unit: "%",
            isPercentage: true)
    var dsTopScreenSize: Double = 0.5
    
    @Option(name: "Notch/Island Unsafe Area",
            description: "Adjust the unsafe area to avoid screens being drawn underneath an iPhone's notch or dynamic island.",
            range: 0...60,
            step: 1,
            unit: "pt")
    var unsafeArea: Double = 40
    
    @Option(name: "Restore Defaults",
            description: "Reset all options to their default values.",
            detailView: { _ in
        Button("Restore Defaults") {
            PowerUserOptions.resetFeature(.gameScreen)
        }
        .font(.system(size: 17, weight: .bold, design: .default))
        .foregroundColor(.red)
        .displayInline()
    })
    var reset: Bool = false
}
