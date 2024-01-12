//
//  LowBatteryOptions.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 1/11/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import SwiftUI

import Features

struct LowBatteryOptions
{
    @Option(name: "Low Battery Level", description: "Change what battery level Ignited considers low battery. Auto save states will start being created automatically at low battery.", detailView: { value in
        VStack {
            HStack {
                Text("Low Battery Level: \(value.wrappedValue * 100, specifier: "%.f")%")
                Spacer()
            }
            HStack {
                Text("5%")
                Slider(value: value, in: 0.05...0.10, step: 0.01)
                Text("10%")
            }
        }.displayInline()
    })
    var lowLevel: Double = 0.10
    
    @Option(name: "Critical Battery Level", description: "Change what battery level Ignited considers critical battery. At critical battery, Ignited will save your game and quit to the library to keep your device from powering off. You will also be unable to launch any games until you charge your device.", detailView: { value in
        VStack {
            HStack {
                Text("Critical Battery Level: \(value.wrappedValue * 100, specifier: "%.f")%")
                Spacer()
            }
            HStack {
                Text("2%")
                Slider(value: value, in: 0.02...0.05, step: 0.01)
                Text("5%")
            }
        }.displayInline()
    })
    var criticalLevel: Double = 0.05
    
    @Option(name: "Restore Defaults",
            description: "Reset all options to their default values.",
            detailView: { _ in
        Button("Restore Defaults") {
            PowerUserOptions.resetFeature(.lowPower)
        }
        .font(.system(size: 17, weight: .bold, design: .default))
        .foregroundColor(.red)
        .displayInline()
    })
    var reset: Bool = false
}
