//
//  BackgroundBlurOptions.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 6/28/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import SwiftUI

import Features

struct BackgroundBlurOptions
{
    @Option(name: "Blur Strength",
            description: "Change the strength of the blur applied to the background.",
            range: 0.5...2.0,
            step: 0.1,
            unit: "%",
            isPercentage: true)
    var strength: Double = 1
    
    @Option(name: "Tint Intensity",
            description: "Change the intensity of the light/dark mode tint. Negative values invert the tint between light and dark.",
            range: -0.5...0.5,
            step: 0.05,
            unit: "%",
            isPercentage: true)
    var tintIntensity: Double = 0.1
     
    @Option(name: "Show During AirPlay",
             description: "Display the blurred background during AirPlay.")
    var showDuringAirPlay: Bool = true
     
    @Option(name: "Maintain Aspect Ratio",
            description: "When scaling the blurred image to fit the background, maintain the aspect ratio instead of stretching the image only to the edges.")
    var maintainAspect: Bool = true
    
    @Option(name: "Restore Defaults",
            description: "Reset all options to their default values.",
            detailView: { _ in
        Button("Restore Defaults") {
            PowerUserOptions.resetFeature(.backgroundBlur)
        }
        .font(.system(size: 17, weight: .bold, design: .default))
        .foregroundColor(.red)
        .displayInline()
    })
    var reset: Bool = false
}
