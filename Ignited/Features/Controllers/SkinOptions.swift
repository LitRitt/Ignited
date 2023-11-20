//
//  SkinOptions.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 5/2/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import SwiftUI

import Features

struct SkinOptions
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
    
    @Option(name: "Match Theme Color",
            description: "Enable to use the theme color as the controller skin background color. Disable to use the color chosen below.")
    var matchTheme: Bool = false
    
    @Option(name: "Background Color",
            description: "Select a color to use as the controller skin background.",
            detailView: { value in
        ColorPicker("Background Color", selection: value, supportsOpacity: false)
            .displayInline()
    })
    var backgroundColor: Color = .black
    
    @Option(name: "Restore Defaults",
            description: "Reset all options to their default values.",
            detailView: { _ in
        Button("Restore Defaults") {
            PowerUserOptions.resetFeature(.skin)
        }
        .font(.system(size: 17, weight: .bold, design: .default))
        .foregroundColor(.red)
        .displayInline()
    })
    var resetSkins: Bool = false
}
