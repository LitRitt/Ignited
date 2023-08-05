//
//  ThemeColor.swift
//  Delta
//
//  Created by Chris Rittenhouse on 5/2/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import SwiftUI

import Features

enum ThemeColor: String, CaseIterable, CustomStringConvertible, Identifiable
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
    
    var id: String {
        return self.rawValue
    }
    
    var assetName: String {
        switch self
        {
        case .pink: return "IconPink"
        case .red: return "IconRed"
        case .orange: return "AppIcon"
        case .yellow: return "IconYellow"
        case .green: return "IconGreen"
        case .mint: return "IconMint"
        case .teal: return "IconTeal"
        case .blue: return "IconBlue"
        case .purple: return "IconPurple"
        }
    }
}

extension ThemeColor: LocalizedOptionValue
{
    var localizedDescription: Text {
        Text(self.description)
    }
}

extension ThemeColor: Equatable
{
    static func == (lhs: ThemeColor, rhs: ThemeColor) -> Bool
    {
        return lhs.description == rhs.description
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
            detailView: { value in
        Picker("Theme Color", selection: value, content: {
            ForEach(ThemeColor.allCases) { color in
                Text(color.description).tag(color)
            }
        })
        .onChange(of: value.wrappedValue) { _ in
            AppIconOptions.updateAppIcon()
        }
        .displayInline()
    })
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
    var customColor: Color = Color(red: 253/255, green: 110/255, blue: 0/255)
    
    @Option(name: "Restore Defaults",
            description: "Reset all options to their default values.",
            detailView: { _ in
        Button("Restore Defaults") {
            PowerUserOptions.resetFeature(.themeColor)
        }
        .font(.system(size: 17, weight: .bold, design: .default))
        .foregroundColor(.red)
        .displayInline()
    })
    var resetThemeColor: Bool = false
}
