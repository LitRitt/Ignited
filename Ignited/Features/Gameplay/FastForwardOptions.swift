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
    case x25 = 0.25
    case x50 = 0.5
    case x150 = 1.5
    case x200 = 2
    case x300 = 3
    case x400 = 4
    case x600 = 6
    case x800 = 8
    
    var description: String {
        switch self {
        case .x25: return "25%"
        case .x50: return "50%"
        case .x150: return "150%"
        case .x200: return "200%"
        case .x300: return "300%"
        case .x400: return "400%"
        case .x600: return "600%"
        case .x800: return "800%"
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
