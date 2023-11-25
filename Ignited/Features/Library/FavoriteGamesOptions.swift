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
    case theme = "Theme"
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
        case .none: return Settings.libraryFeatures.artwork.style.borderColor
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
    
    @Option(name: "Style",
            description: "Choose the style to use for favorite game artwork.",
            values: FavoriteArtworkStyle.allCases)
    var style: FavoriteArtworkStyle = .theme
    
    @Option(name: "Background Color Mode",
            values: ArtworkCustomColor.allCases)
    var backgroundColorMode: ArtworkCustomColor = .custom
    
    @Option(name: "Custom Background Color",
            detailView: { value in
        ColorPicker("Custom Background Color", selection: value, supportsOpacity: false)
            .displayInline()
    })
    var backgroundColor: Color = .orange
    
    @Option(name: "Border Color Mode",
            values: ArtworkCustomColor.allCases)
    var borderColorMode: ArtworkCustomColor = .custom
    
    @Option(name: "Custom Border Color",
            detailView: { value in
        ColorPicker("Custom Border Color", selection: value, supportsOpacity: false)
            .displayInline()
    })
    var borderColor: Color = .orange
    
    @Option(name: "Text Color Mode",
            values: ArtworkCustomColor.allCases)
    var textColorMode: ArtworkCustomColor = .theme
    
    @Option(name: "Custom Text Color",
            detailView: { value in
        ColorPicker("Custom Text Color", selection: value, supportsOpacity: false)
            .displayInline()
    })
    var textColor: Color = .black
    
    @Option(name: "Shadow Color Mode",
            values: ArtworkCustomColor.allCases)
    var shadowColorMode: ArtworkCustomColor = .theme
    
    @Option(name: "Custom Shadow Color",
            detailView: { value in
        ColorPicker("Custom Shadow Color", selection: value, supportsOpacity: false)
            .displayInline()
    })
    var shadowColor: Color = .white
    
    @Option(name: "Custom Corner Radius",
            detailView: { value in
        VStack {
            HStack {
                Text("Custom Corners Radius: \(value.wrappedValue * 100, specifier: "%.f")%")
                Spacer()
            }
            HStack {
                Text("0%")
                Slider(value: value, in: 0.0...0.25, step: 0.01)
                Text("25%")
            }
        }.displayInline()
    })
    var cornerRadius: Double = 0.15
    
    @Option(name: "Custom Border Width",
            detailView: { value in
        VStack {
            HStack {
                Text("Custom Border Width: \(value.wrappedValue, specifier: "%.1f")pt")
                Spacer()
            }
            HStack {
                Text("0pt")
                Slider(value: value, in: 0.0...3.0, step: 0.5)
                Text("3pt")
            }
        }.displayInline()
    })
    var borderWidth: Double = 2
    
    @Option(name: "Custom Shadow Radius",
            detailView: { value in
        VStack {
            HStack {
                Text("Custom Shadow Radius: \(value.wrappedValue, specifier: "%.f")%")
                Spacer()
            }
            HStack {
                Text("0pt")
                Slider(value: value, in: 0.0...10.0, step: 0.5)
                Text("10pt")
            }
        }.displayInline()
    })
    var shadowRadius: Double = 5
    
    @Option(name: "Custom Shadow Opacity",
            detailView: { value in
        VStack {
            HStack {
                Text("Custom Shadow Opacity: \(value.wrappedValue * 100, specifier: "%.f")%")
                Spacer()
            }
            HStack {
                Text("0%")
                Slider(value: value, in: 0.0...1.0, step: 0.1)
                Text("100%")
            }
        }.displayInline()
    })
    var shadowOpacity: Double = 0.5
    
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