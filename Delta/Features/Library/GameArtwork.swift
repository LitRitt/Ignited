//
//  GameArtwork.swift
//  Delta
//
//  Created by Chris Rittenhouse on 4/30/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import UIKit
import SwiftUI

import Features

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
    
    @Option(name: "Theme All Artwork", description: "Apply the theme color to all game artwork, not just the currently running game.")
    var themeAll: Bool = true
    
    @Option(name: "Use Game Screenshots", description: "Enable to show the most recent save state's screenshot of the game as its artwork.")
    var useScreenshots: Bool = true
    
    @Option(name: "Title Size", description: "The size of the game's title.", detailView: { value in
        VStack {
            HStack {
                Text("Title Size: \(value.wrappedValue * 100, specifier: "%.f")%")
                Spacer()
            }
            HStack {
                Text("Hidden")
                Slider(value: value, in: 0.0...1.5, step: 0.05)
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
    
    @Option(name: "Corner Radius", description: "How round the corners should be.", detailView: { value in
        VStack {
            HStack {
                Text("Corner Radius: \(value.wrappedValue, specifier: "%.f")pt")
                Spacer()
            }
            HStack {
                Text("0pt")
                Slider(value: value, in: 0...30, step: 1)
                Text("30pt")
            }
        }.displayInline()
    })
    var cornerRadius: Double = 15
    
    @Option(name: "Border Width", description: "How thick the border should be.", detailView: { value in
        VStack {
            HStack {
                Text("Border Width: \(value.wrappedValue, specifier: "%.1f")pt")
                Spacer()
            }
            HStack {
                Text("0pt")
                Slider(value: value, in: 0.0...5.0, step: 0.5)
                Text("2pt")
            }
        }.displayInline()
    })
    var borderWidth: Double = 2
    
    @Option(name: "Shadow Opacity", description: "How dark the shadows should be.", detailView: { value in
        VStack {
            HStack {
                Text("Shadow Opacity: \(value.wrappedValue * 100, specifier: "%.f")%")
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
            PowerUserOptions.resetFeature(.artworkCustomization)
        }
        .font(.system(size: 17, weight: .bold, design: .default))
        .foregroundColor(.red)
        .displayInline()
    })
    var resetArtworkCustomization: Bool = false
}
