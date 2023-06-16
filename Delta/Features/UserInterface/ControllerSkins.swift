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
    
    @Option(name: "Blur Radius", description: "Change the radius of the blurred background. Higher value means more blurring", detailView: { value in
        VStack {
            HStack {
                Text("Blur Radius: \(value.wrappedValue, specifier: "%.f")px")
                Spacer()
            }
            HStack {
                Text("1px")
                Slider(value: value, in: 1...20, step: 1)
                Text("20px")
            }
        }.displayInline()
    })
    var blurRadius: Double = 5
    
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
