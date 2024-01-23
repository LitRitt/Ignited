//
//  FastForwardOptions.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 4/30/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import SwiftUI

import Features

enum FastForwardSpeed: Double, CaseIterable, CustomStringConvertible
{
    case x025 = 0.25
    case x05 = 0.5
    case x2 = 2
    case x3 = 3
    case x4 = 4
    case x6 = 6
    case x8 = 8
    
    var description: String {
        switch self {
        case .x025: return "25%"
        case .x05: return "50%"
        case .x2: return "200%"
        case .x3: return "300%"
        case .x4: return "400%"
        case .x6: return "600%"
        case .x8: return "800%"
        }
    }
}

extension FastForwardSpeed: LocalizedOptionValue
{
    var localizedDescription: Text {
        return Text(self.description)
    }
}

enum FastForwardMode: String, CaseIterable, CustomStringConvertible
{
    case hold = "Hold"
    case toggle = "Toggle"
    
    var description: String {
        return self.rawValue
    }
    
    var symbolName: String {
        switch self {
        case .hold: return "button.horizontal.top.press"
        case .toggle: return "switch.2"
        }
    }
}

extension FastForwardMode: LocalizedOptionValue
{
    var localizedDescription: Text {
        return Text(self.description)
    }
}

struct FastForwardOptions
{
    @Option(name: "Custom Speed", description: "Set your preferred fast forward speed.", detailView: { value in
        VStack {
            HStack {
                Text("Custom Speed: \(value.wrappedValue * 100, specifier: "%.f")%")
                Spacer()
            }
            HStack {
                Text("10%")
                Slider(value: value, in: 0.1...8.0, step: 0.1)
                Text("800%")
            }
        }.displayInline()
    })
    var speed: Double = 3.0
    
    @Option(name: "Fast Forward Mode",
            description: "In toggle mode, fast forward buttons will act as a toggle. In hold mode, fast forward buttons only activate when held down.",
            values: FastForwardMode.allCases)
    var mode: FastForwardMode = .toggle
    
    @Option(name: "Restore Defaults",
            description: "Reset all options to their default values.",
            detailView: { _ in
        Button("Restore Defaults") {
            PowerUserOptions.resetFeature(.fastForward)
        }
        .font(.system(size: 17, weight: .bold, design: .default))
        .foregroundColor(.red)
        .displayInline()
    })
    var reset: Bool = false
}
