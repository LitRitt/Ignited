//
//  TouchFeedbackVibrationOptions.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 4/29/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import SwiftUI

import Features

struct TouchFeedbackVibrationOptions
{
    @Option(name: "Strength", description: "The strength of vibrations.", detailView: { value in
        VStack {
            HStack {
                Text("Strength: \(value.wrappedValue * 100, specifier: "%.f")%")
                Spacer()
            }
            HStack {
                Text("0%")
                Slider(value: value, in: 0.0...1.0, step: 0.05)
                Text("100%")
            }
        }.displayInline()
    })
    var strength: Double = 1.0
    
    @Option(name: "Buttons",
            description: "Vibrate on button press.")
    var buttonsEnabled: Bool = true
    
    @Option(name: "Control Sticks",
            description: "Vibrate on control stick motion.")
    var sticksEnabled: Bool = true
    
    @Option(name: "Release",
            description: "Vibrate on input release.")
    var releaseEnabled: Bool = true
    
    @Option(name: "Restore Defaults",
            description: "Reset all options to their default values.",
            detailView: { _ in
        Button("Restore Defaults") {
            PowerUserOptions.resetFeature(.touchVibration)
        }
        .font(.system(size: 17, weight: .bold, design: .default))
        .foregroundColor(.red)
        .displayInline()
    })
    var reset: Bool = false
}
