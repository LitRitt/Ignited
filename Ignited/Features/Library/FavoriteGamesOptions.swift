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
    case none = "Default"
    case theme = "Complimentary"
    case custom = "Custom"
    
    var description: String {
        return self.rawValue
    }
    
    var backgroundColor: UIColor? {
        switch self {
        case .none: return Settings.libraryFeatures.artwork.style.backgroundColor
        case .theme: return Settings.userInterfaceFeatures.theme.color.favoriteColor
        case .custom: return Settings.libraryFeatures.favorites.backgroundColorMode == .custom ? UIColor(Settings.libraryFeatures.favorites.backgroundColor) : Settings.userInterfaceFeatures.theme.color.favoriteColor
        }
    }
    
    var borderColor: UIColor? {
        switch self {
        case .none: return Settings.userInterfaceFeatures.theme.color.uiColor
        case .theme: return Settings.userInterfaceFeatures.theme.color.favoriteColor
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
            description: "Choose the style to use for favorite game artwork. Custom options require Ignited Pro.",
            values: Settings.proFeaturesEnabled ? FavoriteArtworkStyle.allCases : [.none, .theme])
    var style: FavoriteArtworkStyle = .theme
    
    @Option(name: "Background Color Mode",
            description: "Choose which background color to use with the custom style option.",
            values: ArtworkCustomColor.allCases,
            attributes: [.pro])
    var backgroundColorMode: ArtworkCustomColor = .custom
    
    @Option(name: "Custom Background Color",
            description: "Choose the color to use for the custom background color mode.",
            transparency: true,
            attributes: [.pro])
    var backgroundColor: Color = .orange
    
    @Option(name: "Border Color Mode",
            description: "Choose which border color to use with the custom style option.",
            values: ArtworkCustomColor.allCases,
            attributes: [.pro])
    var borderColorMode: ArtworkCustomColor = .custom
    
    @Option(name: "Custom Border Color",
            description: "Choose the color to use for the custom border color mode.",
            attributes: [.pro])
    var borderColor: Color = .orange
    
    @Option(name: "Text Color Mode",
            description: "Choose which text color to use with the custom style option.",
            values: ArtworkCustomColor.allCases,
            attributes: [.pro])
    var textColorMode: ArtworkCustomColor = .theme
    
    @Option(name: "Custom Text Color",
            description: "Choose the color to use for the custom text color mode.",
            attributes: [.pro])
    var textColor: Color = .black
    
    @Option(name: "Shadow Color Mode",
            description: "Choose which shadow color to use with the custom style option.",
            values: ArtworkCustomColor.allCases,
            attributes: [.pro])
    var shadowColorMode: ArtworkCustomColor = .theme
    
    @Option(name: "Custom Shadow Color",
            description: "Choose the color to use for the custom shadow color mode.",
            attributes: [.pro])
    var shadowColor: Color = .white
    
    @Option(name: "Custom Shadow Radius",
            description: "Change the shadow radius to use with the custom style option.",
            range: 0.0...10.0,
            step: 0.5,
            unit: "pt",
            attributes: [.pro])
    var shadowRadius: Double = 5
    
    @Option(name: "Custom Shadow Opacity",
            description: "Change the shadow opacity to use with the custom style option.",
            range: 0.0...1.0,
            step: 0.1,
            unit: "%",
            isPercentage: true,
            attributes: [.pro])
    var shadowOpacity: Double = 0.5
    
    @Option(name: "Custom Corner Radius",
            description: "Change the corner radius to use with the custom style option.",
            range: 0.0...0.25,
            step: 0.01,
            unit: "%",
            isPercentage: true,
            attributes: [.pro])
    var cornerRadius: Double = 0.15
    
    @Option(name: "Custom Border Width",
            description: "Change the border witdh to use with the custom style option.",
            range: 0.0...3.0,
            step: 0.5,
            unit: "pt",
            decimals: 1,
            attributes: [.pro])
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
