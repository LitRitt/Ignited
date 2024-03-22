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
    
    @Option(name: "Show New Games",
            description: "Enable to show an icon in the title of your games when they've never been played.")
    var showNewGames: Bool = true
    
    @Option(name: "Show Pause Icon",
            description: "Enable to show a pause icon on your artwork when that game is currently paused.")
    var showPauseIcon: Bool = true
    
    @Option(name: "Force Aspect Ratio",
            description: "Enable to make all artwork within a given system use consistent aspect ratios.")
    var forceAspect: Bool = true
    
    @Option(name: "Aspect Ratio Threshold",
            description: "Change how close the original image aspect ratio must be to the forced ratio in order to apply the forced ratio.",
            range: 0.1...0.5,
            step: 0.05,
            unit: "%",
            isPercentage: true)
    var forceAspectTheshold: Double = 0.2
    
    @Option(name: "Live Artwork",
            description: "Enable to use a screenshot of your latest gameplay as the artwork.",
            attributes: [.pro])
    var useScreenshots: Bool = false
    
    @Option(name: "Title Size",
            description: "Change the size of game titles.",
            range: 0.0...1.5,
            step: 0.1,
            unit: "%",
            isPercentage: true)
    var titleSize: Double = 1.0
    
    @Option(name: "Title Max Lines",
            description: "Change the maximum number of lines that game titles can occupy.",
            range: 1...4,
            step: 1)
    var titleMaxLines: Double = 3
    
    @Option(name: "Style",
            description: "Choose the style to use for game artwork. Pro users can use a customizable style.",
            values: Settings.proFeaturesEnabled ? ArtworkStyle.allCases : [.basic, .vibrant, .flat])
    var style: ArtworkStyle = .basic
    
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
            PowerUserOptions.resetFeature(.artworkCustomization)
        }
        .font(.system(size: 17, weight: .bold, design: .default))
        .foregroundColor(.red)
        .displayInline()
    })
    var reset: Bool = false
}

extension GameArtworkOptions
{
    static var currentStyle: ArtworkStyle
    {
        return Settings.libraryFeatures.artwork.style
    }
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
        case .gbc: return CGSize(width: 100, height: 98)
        case .gba: return CGSize(width: 100, height: 100)
        case .ds: return CGSize(width: 100, height: 90)
        }
    }
    
    var artworkAspectRatio: CGFloat {
        return size.width / size.height
    }
}
