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
    @Option(name: "Enabled",
             description: "Display a blurred version of the game screen as the controller skin background.")
     var blurBackground: Bool = true
     
    @Option(name: "Show During AirPlay",
             description: "Display the blurred background during AirPlay.")
     var blurAirPlay: Bool = false
     
    @Option(name: "Maintain Aspect Ratio",
            description: "When scaling the blurred image to fit the background, maintain the aspect ratio instead of stretching the image only to the edges.")
    var blurAspect: Bool = true
    
    @Option(name: "Override Skin Setting",
            description: "If a skin has set a preference to use a background blur or not, you can enable this option to override the skin's setting and always use the setting provided above.")
    var blurOverride: Bool = false
    
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
    var blurStrength: Double = 1
    
    @Option(name: "Blur Brightness", description: "Change the brightness of the blurred background image. Negative values darken the image, positive values brighten the image.", detailView: { value in
        VStack {
            HStack {
                Text("Blur Brightness: \(value.wrappedValue * 100, specifier: "%.f")%")
                Spacer()
            }
            HStack {
                Text("-50%")
                Slider(value: value, in: -0.5...0.5, step: 0.05)
                Text("50%")
            }
        }.displayInline()
    })
    var blurBrightness: Double = 0
    
    @Option(name: "Restore Defaults", description: "Reset all options to their default values.", detailView: { value in
        Toggle(isOn: value) {
            Text("Restore Defaults")
                .font(.system(size: 17, weight: .bold, design: .default))
                .foregroundColor(.red)
        }
        .toggleStyle(SwitchToggleStyle(tint: .red))
        .displayInline()
    })
    var resetBackgroundBlur: Bool = false
}
