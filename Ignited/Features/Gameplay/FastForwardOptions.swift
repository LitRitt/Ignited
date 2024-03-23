//
//  FastForwardOptions.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 4/30/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import SwiftUI

import Features

enum FastForwardSpeed: Double, CaseIterable, CustomStringConvertible, Identifiable
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
    
    var id: String {
        return self.description
    }
    
    var slowMo: Bool {
        switch self
        {
        case .x25, .x50: return true
        default: return false
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
    case cycle = "Cycle"
    
    var description: String {
        return self.rawValue
    }
    
    var symbolName: String {
        switch self {
        case .hold: return "button.horizontal.top.press"
        case .toggle: return "switch.2"
        case .cycle: return "arrow.3.trianglepath"
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
    @Option(name: "Fast Forward Mode",
            description: "In toggle mode, fast forward buttons will act as a toggle. In hold mode, fast forward buttons only activate when held down. In cycle mode, fast forward buttons will cycle through a set of selected speeds.",
            values: FastForwardMode.allCases)
    var mode: FastForwardMode = .toggle
    
    @Option(name: "Fast Forward Speed",
            description: "Set your preferred fast forward speed.",
            range: 0.1...8.0,
            step: 0.1,
            unit: "%",
            isPercentage: true,
            attributes: [.hidden(when: {currentMode == .cycle})])
    var speed: Double = 3.0
    
    @Option(name: "Cycle Speeds",
            description: "Choose which speeds to cycle between when using cycle mode.",
            attributes: [.hidden(when: {currentMode != .cycle})],
            detailView: { speeds in
        Section {
            ForEach(FastForwardSpeed.allCases) { speed in
                VStack {
                    Divider()
                    speedSelectionRow(for: speed, selectedSpeeds: speeds)
                }
            }
        } header: {
            Text("Cycle Speeds")
        }
        .displayInline()
    })
    var cycleModes: [Double] = [1.5, 3, 8]
    
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

extension FastForwardOptions
{
    static var currentMode: FastForwardMode
    {
        return Settings.gameplayFeatures.fastForward.mode
    }
}

extension FastForwardOptions
{
    @ViewBuilder
    static func speedImage(for speed: FastForwardSpeed) -> some View
    {
        if speed.slowMo
        {
            return Image(systemName: "tortoise.fill")
        }
        else
        {
            return Image(systemName: "hare.fill")
        }
    }
    
    @ViewBuilder
    static func speedSelectionRow(for speed: FastForwardSpeed, selectedSpeeds: Binding<[Double]>) -> some View
    {
        if selectedSpeeds.wrappedValue.contains(speed.rawValue)
        {
            HStack {
                speed.localizedDescription
                Text("✓")
                Spacer()
                speedImage(for: speed)
            }
            .foregroundColor(.accentColor)
            .contentShape(Rectangle())
            .onTapGesture {
                selectedSpeeds.wrappedValue.removeAll(where: {$0 == speed.rawValue})
            }
        }
        else
        {
            HStack {
                speed.localizedDescription
                Spacer()
                speedImage(for: speed)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                selectedSpeeds.wrappedValue.append(speed.rawValue)
            }
        }
    }
}
