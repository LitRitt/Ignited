//
//  AirPlayDeviceOptions.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 3/5/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import SwiftUI

import Features

struct AirPlayDeviceOptions
{
    @Option(name: "Disable Main Screen",
            description: "Disables the main game screen and shows an AirPlay symbol.")
    var disableScreen: Bool = true
    
    @Option(name: "DS Bottom Screen Only",
            description: "Enable to only show the bottom screen when AirPlaying DS games.")
    var bottomScreenOnly: Bool = true
    
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
