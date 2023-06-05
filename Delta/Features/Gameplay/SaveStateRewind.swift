//
//  SaveStateRewind.swift
//  Delta
//
//  Created by Chris Rittenhouse on 4/30/23.
//  Copyright © 2023 Lit Development. All rights reserved.
//

import SwiftUI

import Features

struct SaveStateRewindOptions
{
    @Option(name: "Interval", description: "Change how often the game state should be saved.", detailView: { value in
        VStack {
            HStack {
                Text("Interval: \(value.wrappedValue, specifier: "%.f")s")
                Spacer()
            }
            HStack {
                Text("3s")
                Slider(value: value, in: 3...15, step: 1)
                Text("15s")
            }
        }.displayInline()
    })
    var interval: Double = 15
    
    @Option(name: "Restore Defaults", description: "Reset all options to their default values.", detailView: { value in
        Toggle(isOn: value) {
            Text("Restore Defaults")
                .font(.system(size: 17, weight: .bold, design: .default))
                .foregroundColor(.red)
        }
        .toggleStyle(SwitchToggleStyle(tint: .red))
        .displayInline()
    })
    var resetSaveStateRewind: Bool = false
}
