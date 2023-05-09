//
//  GameArtwork.swift
//  Delta
//
//  Created by Chris Rittenhouse on 4/30/23.
//  Copyright © 2023 Lit Development. All rights reserved.
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
    case mostRecent = "Most Recently Played"
    case leastRecent = "Least Recently Played"
    
    var description: String {
        return self.rawValue
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
    @Option(name: "Sort Order",
            description: "Choose how games should be sorted.",
            values: SortOrder.allCases)
    var sortOrder: SortOrder = .alphabeticalAZ
    
    @Option(name: "Artwork Size",
            description: "Change the size of game artwork.",
            values: ArtworkSize.allCases)
    var size: ArtworkSize = .medium
    
    @Option(name: "Theme Background Color",
            description: "Enable to use theme color for the artwork background color. Disable to use the color selected below.")
    var bgThemed: Bool = true
    
    @Option(name: "Background Color",
            description: "Select a custom color to use for the artwork background.",
            detailView: { value in
        ColorPicker("Background Color", selection: value, supportsOpacity: false)
            .displayInline()
    })
    var bgColor: Color = Color(red: 253/255, green: 110/255, blue: 0/255)
    
    @Option(name: "Background Opacity", description: "Adjust the opacity of the artwork background.", detailView: { value in
        VStack {
            HStack {
                Text("Background Opacity: \(value.wrappedValue * 100, specifier: "%.f")%")
                Spacer()
            }
            HStack {
                Text("0%")
                Slider(value: value, in: 0.0...1.0, step: 0.05)
                Text("100%")
            }
        }.displayInline()
    })
    var bgOpacity: Double = 0.7
    
    @Option(name: "Favorite Games First",
            description: "Sort favorited games to the top of the games list.")
    var favoriteSort: Bool = true
    
    @Option(name: "Highlight Favorite Games",
            description: "Give your favorite games a distinct glow.")
    var favoriteHighlight: Bool = true
    
    @Option(name: "Favorite Highlight Color",
            description: "Select a custom color to use to highlight your favorite games.",
            detailView: { value in
        ColorPicker("Favorite Highlight Color", selection: value, supportsOpacity: false)
            .displayInline()
    })
    var favoriteColor: Color = Color(red: 255/255, green: 234/255, blue: 0/255)
    
    @Option(name: "Animation Speed", description: "Adjust the animation speed of animated artwork.", detailView: { value in
        VStack {
            HStack {
                Text("Animation Speed: \(value.wrappedValue * 100, specifier: "%.f")%")
                Spacer()
            }
            HStack {
                Text("50%")
                Slider(value: value, in: 0.5...2.0, step: 0.05)
                Text("200%")
            }
        }.displayInline()
    })
    var animationSpeed: Double = 1.0
    
    @Option(name: "Animation Delay", description: "Adjust the pause between animations for animated artwork.", detailView: { value in
        VStack {
            HStack {
                Text("Animation Pause: \(value.wrappedValue, specifier: "%.f") Frames")
                Spacer()
            }
            HStack {
                Text("0")
                Slider(value: value, in: 0...50, step: 1)
                Text("50")
            }
        }.displayInline()
    })
    var animationPause: Double = 20
    
    @Option
    var favoriteGames: [String: [String]] = [
        System.ds.gameType.rawValue: [],
        System.gba.gameType.rawValue: [],
        System.gbc.gameType.rawValue: [],
        System.nes.gameType.rawValue: [],
        System.snes.gameType.rawValue: [],
        System.n64.gameType.rawValue: [],
        System.genesis.gameType.rawValue: []
    ]
    
    @Option(name: "Corner Radius", description: "How round the corners should be.", detailView: { value in
        VStack {
            HStack {
                Text("Corner Radius: \(value.wrappedValue, specifier: "%.f")pt")
                Spacer()
            }
            HStack {
                Text("0pt")
                Slider(value: value, in: 0...20, step: 1)
                Text("20pt")
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
                Slider(value: value, in: 0.0...2.0, step: 0.1)
                Text("2pt")
            }
        }.displayInline()
    })
    var borderWidth: Double = 1.2
    
    @Option(name: "Shadow Opacity", description: "How dark the shadows should be.", detailView: { value in
        VStack {
            HStack {
                Text("Shadow Opacity: \(value.wrappedValue * 100, specifier: "%.f")%")
                Spacer()
            }
            HStack {
                Text("0%")
                Slider(value: value, in: 0.0...1.0, step: 0.05)
                Text("100%")
            }
        }.displayInline()
    })
    var shadowOpacity: Double = 0.5
}
