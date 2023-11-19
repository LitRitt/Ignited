//
//  BackgroundBlurOptions.swift
//  Delta
//
//  Created by Chris Rittenhouse on 6/28/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import SwiftUI

import Features

struct BackgroundBlurOptions
{
    @Option(name: "Blur Strength", description: "Change the strength of the blur applied to the background.", detailView: { value in
        VStack {
            HStack {
                Text("Blur Strength: \(value.wrappedValue * 100, specifier: "%.f")%")
                Spacer()
            }
            HStack {
                Text("50%")
                Slider(value: value, in: 0.5...2.0, step: 0.1)
                Text("200%")
            }
        }.displayInline()
    })
    var strength: Double = 1
    
    @Option(name: "Tint Intensity", description: "Change the intensity of the light/dark mode tint. Negative values invert the tint between light and dark.", detailView: { value in
        VStack {
            HStack {
                Text("Tint Intensity: \(value.wrappedValue * 100, specifier: "%.f")%")
                Spacer()
            }
            HStack {
                Text("-50%")
                Slider(value: value, in: -0.5...0.5, step: 0.05)
                Text("50%")
            }
        }.displayInline()
    })
    var tintIntensity: Double = 0.15
     
    @Option(name: "Show During AirPlay",
             description: "Display the blurred background during AirPlay.")
    var showDuringAirPlay: Bool = true
     
    @Option(name: "Maintain Aspect Ratio",
            description: "When scaling the blurred image to fit the background, maintain the aspect ratio instead of stretching the image only to the edges.")
    var maintainAspect: Bool = true
    
    @Option(name: "Override Skin Setting",
            description: "If a skin has set a preference to use a background blur or not, you can enable this option to override the skin's setting and always use the setting provided below.")
    var overrideSkin: Bool = false
    
    @Option(name: "Show During Override",
             description: "When the Override Skin Setting option above is enabled, this option determines whether the background blur is shown.")
    var blurEnabled: Bool = true
    
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
    var resetBackgroundBlur: Bool = false
}
