//
//  PauseMenuOptions.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 12/9/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import SwiftUI

import Features

enum ShakeToPauseMode: String, CaseIterable, CustomStringConvertible
{
    case enabled = "Enabled"
    case gyroDisables = "Gyro Disables"
    case disabled = "Disabled"
    
    var description: String {
        return self.rawValue
    }
}

extension ShakeToPauseMode: LocalizedOptionValue
{
    var localizedDescription: Text {
        return Text(self.description)
    }
}

extension [String]: LocalizedOptionValue
{
    public var localizedDescription: Text {
        return Text("Edit")
    }
}

struct PauseMenuOptions
{
    @Option(name: "Button Order",
            description: "Change the order that buttons appear in the pause menu. Tap and hold an item to move it up or down the list.",
            detailView: { items in
        List {
            ForEach(items, id: \.self) { $item in
                Text(item)
            }
            .onMove { from, to in
                items.wrappedValue.move(fromOffsets: from, toOffset: to)
            }
        }
    })
    var buttonOrder: [String] = ["Save State", "Load State", "Restart", "Screenshot", "Status Bar", "Sustain Buttons", "Rewind", "Fast Forward", "Microphone", "Rotation Lock", "Palettes", "Quick Settings", "Backgroud Blur", "Overscan Editor", "Cheat Codes", "Alt Skin", "Debug Mode"]
    
    @Option(name: "Shake to Open",
            description: "Allows you to shake your device to open the pause menu. Only works when all other device shake features are disabled. This feature acts as a failsafe to ensure you can always access the pause menu even if you are unable to via the controller or skin. Disable at your own risk.",
            values: ShakeToPauseMode.allCases)
    var shakeToPause: ShakeToPauseMode = .enabled
    
    @Option(name: "Restore Defaults",
            description: "Reset all options to their default values.",
            detailView: { _ in
        Button("Restore Defaults") {
            PowerUserOptions.resetFeature(.pauseMenu)
        }
        .font(.system(size: 17, weight: .bold, design: .default))
        .foregroundColor(.red)
        .displayInline()
    })
    var reset: Bool = false
}
