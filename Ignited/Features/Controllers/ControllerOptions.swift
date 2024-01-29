//
//  ControllerOptions.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 7/7/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import SwiftUI

import Features

struct ControllerOptions
{
    @Option(name: "Trigger Deadzone",
            description: "Change how far triggers need to be pressed before activating an input.",
            range: 0.00...0.95,
            step: 0.05,
            unit: "%",
            isPercentage: true)
    var triggerDeadzone: Double = 0.15
    
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
