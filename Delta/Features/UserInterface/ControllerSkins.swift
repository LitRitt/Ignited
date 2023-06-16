//
//  ControllerSkins.swift
//  Delta
//
//  Created by Chris Rittenhouse on 5/2/23.
//  Copyright © 2023 Lit Development. All rights reserved.
//

import SwiftUI

import Features

struct ControllerSkinOptions
{
    @Option(name: "Opacity", description: "Change the opacity of supported controller skins.", detailView: { value in
        VStack {
            HStack {
                Text("Opacity: \(value.wrappedValue * 100, specifier: "%.f")%")
                Spacer()
            }
            HStack {
                Text("0%")
                Slider(value: value, in: 0.0...1.0, step: 0.05)
                Text("100%")
            }
        }.displayInline()
    })
    var opacity: Double = 0.7
    
    @Option(name: "Show With Controller",
            description: "Always show the controller skin, even if there's a physical controller connected.")
    var alwaysShow: Bool = false
    
    @Option(name: "Blurred Background",
            description: "Display a blurred version of the game screen as the background instead of having a black background.")
    var blurBackground: Bool = true
    
    @Option(name: "Maintain Aspect Ratio",
            description: "When scaling the blurred image to fit the background, maintain the aspect ratio instead of stretching the image only to the edges.")
    var blurAspect: Bool = true
    
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
    var resetControllerSkins: Bool = false
}
