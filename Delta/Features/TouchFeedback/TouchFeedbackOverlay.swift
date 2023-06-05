//
//  TouchFeedbackOverlay.swift
//  Delta
//
//  Created by Chris Rittenhouse on 4/29/23.
//  Copyright © 2023 Lit Development. All rights reserved.
//

import SwiftUI

import Features

struct TouchFeedbackOverlayOptions
{
    @Option(name: "Theme Color",
            description: "Enable to use the app theme color for overlays. Disable to use the color specified below for overlays.")
    var themed: Bool = true
    
    @Option(name: "Custom Color",
            description: "Select a custom color to use for the overlays.",
            detailView: { value in
        ColorPicker("Custom Color", selection: value, supportsOpacity: false)
            .displayInline()
    })
    var overlayColor: Color = Color(red: 255/255, green: 255/255, blue: 255/255)
    
    @Option(name: "Opacity", description: "Adjust the opacity of the overlays.", detailView: { value in
        VStack {
            HStack {
                Text("Opacity: \(value.wrappedValue * 100, specifier: "%.f")%")
                Spacer()
            }
            HStack {
                Text("15%")
                Slider(value: value, in: 0.15...1.00, step: 0.05)
                Text("100%")
            }
        }.displayInline()
    })
    var opacity: Double = 0.7
    
    @Option(name: "Size", description: "Adjust the size of the overlays.", detailView: { value in
        VStack {
            HStack {
                Text("Size: \(value.wrappedValue * 100, specifier: "%.f")%")
                Spacer()
            }
            HStack {
                Text("50%")
                Slider(value: value, in: 0.50...2.00, step: 0.05)
                Text("200%")
            }
        }.displayInline()
    })
    var size: Double = 1.0
    
    @Option(name: "Restore Defaults", description: "Reset all options to their default values.", detailView: { value in
        Toggle(isOn: value) {
            Text("Restore Defaults")
                .font(.system(size: 17, weight: .bold, design: .default))
                .foregroundColor(.red)
        }
        .toggleStyle(SwitchToggleStyle(tint: .red))
        .displayInline()
    })
    var resetTouchOverlay: Bool = false
}
