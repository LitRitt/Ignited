//
//  TouchFeedbackOverlayOptions.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 4/29/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import SwiftUI

import Features
import DeltaCore

extension ButtonOverlayStyle: LocalizedOptionValue
{
    public var localizedDescription: Text {
        Text(self.description)
    }
}

struct TouchFeedbackOverlayOptions
{
    @Option(name: "Theme Color",
            description: "Enable to use the app theme color for overlays. Disable to use the color specified below for overlays.")
    var themed: Bool = true
    
    @Option(name: "Custom Color",
            description: "Select a custom color to use for the overlays.")
    var overlayColor: Color = .white
    
    @Option(name: "Style",
            description: "Choose the style to use for overlays. Free users are limited to the default \"Bubble\" style.",
            values: ButtonOverlayStyle.allCases.filter { $0 == .bubble || Settings.proFeaturesEnabled },
            attributes: [.pro])
    var style: ButtonOverlayStyle = .bubble
    
    @Option(name: "Opacity",
            description: "Adjust the opacity of the overlays.",
            range: 0.25...1.00,
            step: 0.05,
            unit: "%",
            isPercentage: true)
    var opacity: Double = 1.0
    
    @Option(name: "Size",
            description: "Adjust the size of the overlays.",
            range: 0.70...1.30,
            step: 0.05,
            unit: "%",
            isPercentage: true)
    var size: Double = 1.0
    
    @Option(name: "Restore Defaults",
            description: "Reset all options to their default values.",
            detailView: { _ in
        Button("Restore Defaults") {
            PowerUserOptions.resetFeature(.touchOverlay)
        }
        .font(.system(size: 17, weight: .bold, design: .default))
        .foregroundColor(.red)
        .displayInline()
    })
    var reset: Bool = false
}
