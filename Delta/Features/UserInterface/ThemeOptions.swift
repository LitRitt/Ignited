//
//  ThemeOptions.swift
//  Delta
//
//  Created by Chris Rittenhouse on 5/2/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import SwiftUI

import Features

enum ThemeColor: String, CaseIterable, CustomStringConvertible, Identifiable
{
    case red = "Red"
    case orange = "Orange"
    case yellow = "Yellow"
    case green = "Green"
    case teal = "Teal"
    case blue = "Blue"
    case purple = "Purple"
    case pink = "Pink"
    case custom = "Custom"
    
    var description: String {
        return self.rawValue
    }
    
    var id: String {
        return self.rawValue
    }
    
    var assetName: String {
        switch self
        {
        case .red: return "IconRed"
        case .orange: return "IconOrange"
        case .yellow: return "IconYellow"
        case .green: return "IconGreen"
        case .teal: return "IconTeal"
        case .blue: return "IconBlue"
        case .purple: return "IconPurple"
        case .pink: return "IconPink"
        case .custom: return "IconPride"
        }
    }
    
    var uiColor: UIColor {
        switch self
        {
        case .red: return UIColor(named: "IgnitedRed")!
        case .orange: return UIColor(named: "IgnitedOrange")!
        case .yellow: return UIColor(named: "IgnitedYellow")!
        case .green: return UIColor(named: "IgnitedGreen")!
        case .teal: return UIColor(named: "IgnitedTeal")!
        case .blue: return UIColor(named: "IgnitedBlue")!
        case .purple: return UIColor(named: "IgnitedPurple")!
        case .pink: return UIColor(named: "IgnitedPink")!
        case .custom:
            return UIColor() { (traits) in
                switch traits.userInterfaceStyle
                {
                case .light: return UIColor(Settings.userInterfaceFeatures.theme.customLightColor)
                case .dark, .unspecified: return UIColor(Settings.userInterfaceFeatures.theme.customDarkColor)
                }
            }
        }
    }
    
    var color: Color {
        if #available(iOS 15, *) {
            Color(uiColor: uiColor)
        } else {
            Color(fromRGB: uiColor.cgColor.rgb())
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

enum ThemeStyle: String, CaseIterable, CustomStringConvertible
{
    case auto = "Auto"
    case light = "Light"
    case dark = "Dark"
    
    var description: String {
        return self.rawValue
    }
    
    var userInterfaceStyle: UIUserInterfaceStyle {
        switch self
        {
        case .auto: return .unspecified
        case .light: return .light
        case .dark: return .dark
        }
    }
    
    var symbolName: String {
        switch self
        {
        case .auto: return "rectangle.righthalf.inset.filled.arrow.right"
        case .light: return "sun.min"
        case .dark: return "moon"
        }
    }
}

extension ThemeStyle: LocalizedOptionValue
{
    var localizedDescription: Text {
        Text(self.description)
    }
}

struct ThemeOptions
{
    @Option(name: "Style",
            description: "Choose between light and dark mode or automatic style.",
            values: ThemeStyle.allCases)
    var style: ThemeStyle = .auto
    
    @Option(name: "Color",
            description: "Choose an accent color for the app. This will apply to many parts of the UI, including the app icon if enabled.",
            detailView: { value in
        List {
            ForEach(ThemeColor.allCases) { color in
                HStack {
                    if color == value.wrappedValue
                    {
                        Text("✓").foregroundColor(color.color)
                    }
                    color.localizedDescription.foregroundColor(color.color)
                    Spacer()
                    Image(uiImage: Bundle.appIcon(forTheme: color) ?? UIImage())
                        .cornerRadius(13)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    value.wrappedValue = color
                }
            }
        }
        .onChange(of: value.wrappedValue) { _ in
            AppIconOptions.updateAppIcon()
        }
        .displayInline()
    })
    var color: ThemeColor = .orange
    
    @Option(name: "Custom Light Color",
            description: "Select a custom color to use with the light style.",
            detailView: { value in
        ColorPicker("Custom Light Color", selection: value, supportsOpacity: false)
            .displayInline()
    })
    var customLightColor: Color = .accentColor
    
    @Option(name: "Custom Dark Color",
            description: "Select a custom color to use with the dark style.",
            detailView: { value in
        ColorPicker("Custom Dark Color", selection: value, supportsOpacity: false)
            .displayInline()
    })
    var customDarkColor: Color = .accentColor
    
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
