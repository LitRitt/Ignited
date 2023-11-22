//
//  GameArtworkOptions.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 4/30/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import UIKit
import SwiftUI

import Features

enum ArtworkStyle: String, CaseIterable, CustomStringConvertible
{
    case vibrant = "Vibrant"
    case simple = "Simple"
    case custom = "Custom"
    
    var description: String {
        return self.rawValue
    }
    
    var symbolName: String {
        switch self
        {
        case .vibrant: return "photo.artframe"
        case .simple: return "photo"
        case .custom: return "wrench.and.screwdriver"
        }
    }
    
    var roundedCorners: Double {
        switch self {
        case .vibrant: return 0.15
        case .simple: return 0
        case .custom: return Settings.libraryFeatures.artwork.roundedCorners
        }
    }
    
    var borderWidth: Double {
        switch self {
        case .vibrant: return 2.0
        case .simple: return 0
        case .custom: return Settings.libraryFeatures.artwork.borderWidth
        }
    }
    
    var glowOpacity: Double {
        switch self {
        case .vibrant: return 0.7
        case .simple: return 0.3
        case .custom: return Settings.libraryFeatures.artwork.glowOpacity
        }
    }
    
    var glowColor: Color? {
        switch self {
        case .vibrant: return nil
        case .simple: return .black
        case .custom: return Settings.libraryFeatures.artwork.glowColor
        }
    }
}

extension ArtworkStyle: LocalizedOptionValue
{
    var localizedDescription: Text {
        return Text(self.description)
    }
}

enum ArtworkSize: String, CaseIterable, CustomStringConvertible
{
    case small = "Small"
    case medium = "Medium"
    case large = "Large"
    
    var description: String {
        return self.rawValue
    }
    
    var symbolName: String {
        switch self
        {
        case .small: return "square.grid.4x3.fill"
        case .medium: return "square.grid.3x3.fill"
        case .large: return "square.grid.2x2.fill"
        }
    }
    
    var textSize: CGFloat {
        let sizeModifier = UIScreen.main.traitCollection.horizontalSizeClass == .regular ? 1.5 : 1
        
        switch self
        {
        case .small: return 10 * sizeModifier
        case .medium: return 12 * sizeModifier
        case .large: return 14 * sizeModifier
        }
    }
}

extension ArtworkSize: LocalizedOptionValue
{
    var localizedDescription: Text {
        Text(self.description)
    }
}

enum SortOrder: String, CaseIterable, CustomStringConvertible
{
    case alphabeticalAZ = "Alphabetical A-Z"
    case alphabeticalZA = "Alphabetical Z-A"
    case mostRecent = "Most Recent"
    case leastRecent = "Least Recent"
    
    var description: String {
        return self.rawValue
    }
    
    var symbolName: String {
        switch self
        {
        case .alphabeticalAZ: return "arrowtriangle.up"
        case .alphabeticalZA: return "arrowtriangle.down"
        case .mostRecent: return "arrow.clockwise"
        case .leastRecent: return "arrow.counterclockwise"
        }
    }
}

extension SortOrder: LocalizedOptionValue
{
    var localizedDescription: Text {
        Text(self.description)
    }
}

struct GameArtworkOptions
{
    @Option
    var sortOrder: SortOrder = .alphabeticalAZ
    
    @Option
    var size: ArtworkSize = .medium
    
    @Option(name: "Style",
            description: "Choose the style to use for artwork.",
            values: ArtworkStyle.allCases)
    var style: ArtworkStyle = .vibrant
    
    @Option(name: "Custom Rounded Corners", description: "How round the corners should be.", detailView: { value in
        VStack {
            HStack {
                Text("Custom Rounded Corners: \(value.wrappedValue * 100, specifier: "%.f")%")
                Spacer()
            }
            HStack {
                Text("0%")
                Slider(value: value, in: 0.0...0.25, step: 0.05)
                Text("25%")
            }
        }.displayInline()
    })
    var roundedCorners: Double = 0.15
    
    @Option(name: "Custom Border Width", description: "How thick the border should be.", detailView: { value in
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
    
    @Option(name: "Custom Glow Intensity", description: "How intense the theme colored glow effect is.", detailView: { value in
        VStack {
            HStack {
                Text("Custom Glow Intensity: \(value.wrappedValue * 100, specifier: "%.f")%")
                Spacer()
            }
            HStack {
                Text("0%")
                Slider(value: value, in: 0.0...1.0, step: 0.1)
                Text("100%")
            }
        }.displayInline()
    })
    var glowOpacity: Double = 0.5
    
    @Option(name: "Custom Glow Color",
            description: "Select a custom color to use for the glow around artwork.",
            detailView: { value in
        ColorPicker("Custom Glow Color", selection: value, supportsOpacity: false)
            .displayInline()
    })
    var glowColor: Color = .white
    
    @Option(name: "Theme All Artwork", description: "Apply the theme color to all game artwork, not just the currently running game.")
    var themeAll: Bool = true
    
    @Option(name: "Show New Games", description: "Enable to show an icon in the title of your games when they've never been played.")
    var showNewGames: Bool = true
    
    @Option(name: "Use Game Screenshots", description: "Enable to show the most recent save state's screenshot of the game as its artwork.")
    var useScreenshots: Bool = true
    
    @Option(name: "Title Size", description: "The size of the game's title.", detailView: { value in
        VStack {
            HStack {
                Text("Title Size: \(value.wrappedValue * 100, specifier: "%.f")%")
                Spacer()
            }
            HStack {
                Text("0%")
                Slider(value: value, in: 0.0...1.5, step: 0.1)
                Text("150%")
            }
        }.displayInline()
    })
    var titleSize: Double = 1.0
    
    @Option(name: "Title Max Lines", description: "How many lines the title can occupy.", detailView: { value in
        VStack {
            HStack {
                Text("Title Max Lines: \(value.wrappedValue, specifier: "%.f")")
                Spacer()
            }
            HStack {
                Text("1")
                Slider(value: value, in: 1...4, step: 1)
                Text("4")
            }
        }.displayInline()
    })
    var titleMaxLines: Double = 3
    
    @Option(name: "Restore Defaults",
            description: "Reset all options to their default values.",
            detailView: { _ in
        Button("Restore Defaults") {
            PowerUserOptions.resetFeature(.artworkCustomization)
        }
        .font(.system(size: 17, weight: .bold, design: .default))
        .foregroundColor(.red)
        .displayInline()
    })
    var reset: Bool = false
}
