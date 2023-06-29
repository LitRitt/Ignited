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
    
    @Option(name: "Title Size", description: "The size of the game's title.", detailView: { value in
        VStack {
            HStack {
                Text("Title Size: \(value.wrappedValue * 100, specifier: "%.f")%")
                Spacer()
            }
            HStack {
                Text("70%")
                Slider(value: value, in: 0.7...1.3, step: 0.05)
                Text("130%")
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
    
    @Option(name: "Restore Defaults", description: "Reset all options to their default values.", detailView: { value in
        Toggle(isOn: value) {
            Text("Restore Defaults")
                .font(.system(size: 17, weight: .bold, design: .default))
                .foregroundColor(.red)
        }
        .toggleStyle(SwitchToggleStyle(tint: .red))
        .displayInline()
    })
    var resetArtworkCustomization: Bool = false
}
