//
//  ThemeColor.swift
//  Delta
//
//  Created by Chris Rittenhouse on 5/2/23.
//  Copyright © 2023 Lit Development. All rights reserved.
//

import SwiftUI

import Features

enum ThemeColor: String, CaseIterable, CustomStringConvertible
{
    case pink = "Pink"
    case red = "Red"
    case orange = "Orange"
    case yellow = "Yellow"
    case green = "Green"
    case mint = "Mint"
    case teal = "Teal"
    case blue = "Blue"
    case purple = "Purple"
    
    var description: String {
        return self.rawValue
    }
}

extension ThemeColor: LocalizedOptionValue
{
    var localizedDescription: Text {
        Text(self.description)
    }
}

extension Color: LocalizedOptionValue
{
    public var localizedDescription: Text {
        Text(self.description)
    }
}

struct ThemeColorOptions
{
    @Option(name: "Theme Color",
            description: "Change the accent color of the app.",
            values: ThemeColor.allCases)
    var accentColor: ThemeColor = .orange
    
    @Option(name: "Use Custom Color",
            description: "Use the custom color selected below instead of the preset color above.")
    var useCustom: Bool = false
    
    @Option(name: "Custom Color",
            description: "Select a custom color to use as the accent color.",
            detailView: { value in
        ColorPicker("Custom Color", selection: value, supportsOpacity: false)
            .displayInline()
    })
    var customColor: Color = Color.white
}
