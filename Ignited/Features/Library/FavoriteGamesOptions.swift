//
//  FavoriteGamesOptions.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 6/3/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import UIKit
import SwiftUI

import Features

enum FavoriteArtworkStyle: String, CaseIterable, CustomStringConvertible
{
    case theme = "Theme"
    case themeComplimentary = "Complimentary"
    case custom = "Custom"
    
    var description: String {
        return self.rawValue
    }
    
    var backgroundColor: UIColor? {
        switch self {
        case .theme: return Settings.libraryFeatures.artwork.style.backgroundColor
        case .themeComplimentary: return Settings.userInterfaceFeatures.theme.color.favoriteColor
        case .custom: return Settings.libraryFeatures.favorites.backgroundColorMode == .custom ? UIColor(Settings.libraryFeatures.favorites.backgroundColor) : Settings.userInterfaceFeatures.theme.color.favoriteColor
        }
    }
    
    var borderColor: UIColor? {
        switch self {
        case .theme: return Settings.userInterfaceFeatures.theme.color.uiColor
        case .themeComplimentary: return Settings.userInterfaceFeatures.theme.color.favoriteColor
        case .custom: return Settings.libraryFeatures.favorites.borderColorMode == .custom ? UIColor(Settings.libraryFeatures.favorites.borderColor) : Settings.userInterfaceFeatures.theme.color.favoriteColor
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .custom: return UIColor(Settings.libraryFeatures.favorites.textColor)
        default: return Settings.libraryFeatures.artwork.style.textColor
        }
    }
    
    var shadowColor: UIColor? {
        switch self {
        case .custom: return UIColor(Settings.libraryFeatures.favorites.shadowColor)
        default: return Settings.libraryFeatures.artwork.style.shadowColor
        }
        
    }
    
    var cornerRadius: Double {
        switch self {
        case .custom: return Settings.libraryFeatures.favorites.cornerRadius
        default: return Settings.libraryFeatures.artwork.style.cornerRadius
        }
    }
    
    var borderWidth: Double {
        switch self {
        case .custom: return Settings.libraryFeatures.favorites.borderWidth
        default: return Settings.libraryFeatures.artwork.style.borderWidth
        }
    }
    
    var shadowOpacity: Double {
        switch self {
        case .custom: return Settings.libraryFeatures.favorites.shadowOpacity
        default: return Settings.libraryFeatures.artwork.style.shadowOpacity
        }
    }
    
    var shadowRadius: Double {
        switch self {
        case .custom: return Settings.libraryFeatures.favorites.shadowRadius
        default: return Settings.libraryFeatures.artwork.style.shadowRadius
        }
    }
}

extension FavoriteArtworkStyle: LocalizedOptionValue
{
    var localizedDescription: Text {
        return Text(self.description)
    }
}

struct FavoriteGamesOptions
{
    @Option
    var sortFirst: Bool = true
    
    @Option(name: "Show Star Icon", description: "Enable to show a star icon on your favorite games' artwork.")
    var showStarIcon: Bool = true
    
    @Option(name: "Style",
            description: "Choose the style to use for favorite game artwork. Pro users can use a customizable style.",
            values: PurchaseManager.shared.hasUnlockedPro ? FavoriteArtworkStyle.allCases : [.theme, .themeComplimentary])
    var style: FavoriteArtworkStyle = .theme
    
    @Option(name: "Background Color Mode",
            description: "Choose which background color to use with the custom style option.",
            values: ArtworkCustomColor.allCases,
            attributes: [.pro, .hidden(when: {currentStyle != .custom})])
    var backgroundColorMode: ArtworkCustomColor = .custom
    
    @Option(name: "Custom Background Color",
            description: "Choose the color to use for the custom background color mode.",
            transparency: true,
            attributes: [.pro, .hidden(when: {currentStyle != .custom})])
    var backgroundColor: Color = .orange
    
    @Option(name: "Border Color Mode",
            description: "Choose which border color to use with the custom style option.",
            values: ArtworkCustomColor.allCases,
            attributes: [.pro, .hidden(when: {currentStyle != .custom})])
    var borderColorMode: ArtworkCustomColor = .custom
    
    @Option(name: "Custom Border Color",
            description: "Choose the color to use for the custom border color mode.",
            attributes: [.pro, .hidden(when: {currentStyle != .custom})])
    var borderColor: Color = .orange
    
    @Option(name: "Text Color Mode",
            description: "Choose which text color to use with the custom style option.",
            values: ArtworkCustomColor.allCases,
            attributes: [.pro, .hidden(when: {currentStyle != .custom})])
    var textColorMode: ArtworkCustomColor = .theme
    
    @Option(name: "Custom Text Color",
            description: "Choose the color to use for the custom text color mode.",
            attributes: [.pro, .hidden(when: {currentStyle != .custom})])
    var textColor: Color = .black
    
    @Option(name: "Shadow Color Mode",
            description: "Choose which shadow color to use with the custom style option.",
            values: ArtworkCustomColor.allCases,
            attributes: [.pro, .hidden(when: {currentStyle != .custom})])
    var shadowColorMode: ArtworkCustomColor = .theme
    
    @Option(name: "Custom Shadow Color",
            description: "Choose the color to use for the custom shadow color mode.",
            attributes: [.pro, .hidden(when: {currentStyle != .custom})])
    var shadowColor: Color = .white
    
    @Option(name: "Custom Shadow Radius",
            description: "Change the shadow radius to use with the custom style option.",
            range: 0.0...10.0,
            step: 0.5,
            unit: "pt",
            attributes: [.pro, .hidden(when: {currentStyle != .custom})])
    var shadowRadius: Double = 5
    
    @Option(name: "Custom Shadow Opacity",
            description: "Change the shadow opacity to use with the custom style option.",
            range: 0.0...1.0,
            step: 0.1,
            unit: "%",
            isPercentage: true,
            attributes: [.pro, .hidden(when: {currentStyle != .custom})])
    var shadowOpacity: Double = 0.5
    
    @Option(name: "Custom Corner Radius",
            description: "Change the corner radius to use with the custom style option.",
            range: 0.0...0.25,
            step: 0.01,
            unit: "%",
            isPercentage: true,
            attributes: [.pro, .hidden(when: {currentStyle != .custom})])
    var cornerRadius: Double = 0.15
    
    @Option(name: "Custom Border Width",
            description: "Change the border witdh to use with the custom style option.",
            range: 0.0...3.0,
            step: 0.5,
            unit: "pt",
            decimals: 1,
            attributes: [.pro, .hidden(when: {currentStyle != .custom})])
    var borderWidth: Double = 2
    
    @Option(name: "Restore Defaults",
            description: "Reset all options to their default values.",
            detailView: { _ in
        Button("Restore Defaults") {
            PowerUserOptions.resetFeature(.favoriteGames)
        }
        .font(.system(size: 17, weight: .bold, design: .default))
        .foregroundColor(.red)
        .displayInline()
    })
    var reset: Bool = false
}

extension FavoriteGamesOptions
{
    static var currentStyle: FavoriteArtworkStyle
    {
        return Settings.libraryFeatures.favorites.style
    }
}
