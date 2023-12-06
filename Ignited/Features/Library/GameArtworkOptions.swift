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

enum ArtworkCustomColor: String, CaseIterable, CustomStringConvertible, LocalizedOptionValue
{
    case theme = "Theme"
    case custom = "Custom"
    
    var description: String {
        return rawValue
    }
    
    var localizedDescription: Text {
        Text(description)
    }
}

enum ArtworkStyle: String, CaseIterable, CustomStringConvertible
{
    case basic = "Basic"
    case vibrant = "Vibrant"
    case flat = "Flat"
    case custom = "Custom"
    
    var description: String {
        return self.rawValue
    }
    
    var symbolName: String {
        switch self
        {
        case .basic: return "swirl.circle.righthalf.filled"
        case .vibrant: return "cloud.rainbow.half"
        case .flat: return "photo"
        case .custom: return "wrench.and.screwdriver"
        }
    }
    
    var backgroundColor: UIColor? {
        switch self {
        case .basic: return nil
        case .vibrant: return nil
        case .flat: return nil
        case .custom: return Settings.libraryFeatures.artwork.backgroundColorMode == .custom ? UIColor(Settings.libraryFeatures.artwork.backgroundColor) : nil
        }
    }
    
    var borderColor: UIColor? {
        switch self {
        case .basic: return .secondaryLabel
        case .vibrant: return nil
        case .flat: return .black
        case .custom: return Settings.libraryFeatures.artwork.borderColorMode == .custom ? UIColor(Settings.libraryFeatures.artwork.borderColor) : nil
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .basic: return .label
        case .vibrant: return .label
        case .flat: return .label
        case .custom: return Settings.libraryFeatures.artwork.textColorMode == .custom ? UIColor(Settings.libraryFeatures.artwork.textColor) : .secondaryLabel
        }
    }
    
    var shadowColor: UIColor? {
        switch self {
        case .basic: return .black
        case .vibrant: return nil
        case .flat: return .black
        case .custom: return Settings.libraryFeatures.artwork.shadowColorMode == .custom ? UIColor(Settings.libraryFeatures.artwork.shadowColor) : nil
        }
    }
    
    var cornerRadius: Double {
        switch self {
        case .basic: return 0.1
        case .vibrant: return 0.15
        case .flat: return 0
        case .custom: return Settings.libraryFeatures.artwork.cornerRadius
        }
    }
    
    var borderWidth: Double {
        switch self {
        case .basic: return 1.2
        case .vibrant: return 2
        case .flat: return 0
        case .custom: return Settings.libraryFeatures.artwork.borderWidth
        }
    }
    
    var shadowOpacity: Double {
        switch self {
        case .basic: return 0.5
        case .vibrant: return 0.8
        case .flat: return 0
        case .custom: return Settings.libraryFeatures.artwork.shadowOpacity
        }
    }
    
    var shadowRadius: Double {
        switch self {
        case .basic: return 5
        case .vibrant: return 8
        case .flat: return 0
        case .custom: return Settings.libraryFeatures.artwork.shadowRadius
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
            description: "Choose the style to use for game artwork.",
            values: ArtworkStyle.allCases)
    var style: ArtworkStyle = .basic
    
    @Option(name: "Background Color Mode",
            values: ArtworkCustomColor.allCases)
    var backgroundColorMode: ArtworkCustomColor = .custom
    
    @Option(name: "Custom Background Color",
            detailView: { value in
        ColorPicker("Custom Background Color", selection: value, supportsOpacity: true)
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
    
    @Option(name: "Custom Shadow Radius",
            detailView: { value in
        VStack {
            HStack {
                Text("Custom Shadow Radius: \(value.wrappedValue, specifier: "%.f")pt")
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
    
    @Option(name: "Title Size",
            detailView: { value in
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
    
    @Option(name: "Title Max Lines",
            detailView: { value in
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
    
    @Option(name: "Show New Games", description: "Enable to show an icon in the title of your games when they've never been played.")
    var showNewGames: Bool = true
    
    @Option(name: "Live Artwork", description: "Enable to use a screenshot of your latest gameplay as the artwork.")
    var useScreenshots: Bool = true
    
    @Option(name: "Force Aspect Ratio", description: "Enable to make all artwork within a given system use consistent aspect ratios.")
    var forceAspect: Bool = true
    
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

extension System
{
    var size: CGSize {
        switch self {
        case .genesis: return CGSize(width: 74, height: 100)
        case .ms: return CGSize(width: 74, height: 100)
        case .gg: return CGSize(width: 72, height: 100)
        case .nes: return CGSize(width: 73, height: 100)
        case .snes: return CGSize(width: 100, height: 73)
        case .n64: return CGSize(width: 100, height: 70)
        case .gb: return CGSize(width: 100, height: 98)
        case .gbc: return CGSize(width: 100, height: 98)
        case .gba: return CGSize(width: 100, height: 100)
        case .ds: return CGSize(width: 100, height: 97)
        }
    }
    
    var artworkAspectRatio: CGFloat {
        return size.width / size.height
    }
}
