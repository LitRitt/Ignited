//
//  AirPlayDisplayOptions.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 3/5/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import SwiftUI

import Features
import DeltaCore

extension TouchControllerSkin.LayoutAxis: LocalizedOptionValue, CustomStringConvertible
{
    public var description: String {
        switch self
        {
        case .vertical: return "Vertical"
        case .horizontal: return "Horizontal"
        }
    }
    
    public var localizedDescription: Text {
        return Text(description)
    }
}

struct AirPlayDisplayOptions
{
    @Option(name: "Background Blur",
            description: "Enable to show the background blur on the external display.")
    var backgroundBlur: Bool = true
    
    @Option(name: "DS Top Screen Only",
            description: "Enable to only show the top screen when AirPlaying DS games.")
    var topScreenOnly: Bool = true

    @Option(name: "DS Screen Layout",
            description: "Choose the layout for DS screens when Top Screen Only is disabled.",
            values: TouchControllerSkin.LayoutAxis.allCases)
    var layoutAxis: TouchControllerSkin.LayoutAxis = .vertical
    
    @Option(name: "Restore Defaults",
            description: "Reset all options to their default values.",
            detailView: { _ in
        Button("Restore Defaults") {
            PowerUserOptions.resetFeature(.controller)
        }
        .font(.system(size: 17, weight: .bold, design: .default))
        .foregroundColor(.red)
        .displayInline()
    })
    var reset: Bool = false
}