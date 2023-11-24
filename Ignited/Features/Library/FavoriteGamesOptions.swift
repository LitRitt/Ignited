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

enum FavoriteColor: String, CaseIterable, CustomStringConvertible
{
    case none = "None"
    case theme = "Theme"
    case custom = "Custom"
    
    var description: String {
        return self.rawValue
    }
    
    var uiColor: UIColor {
        switch self {
        case .none: return Settings.userInterfaceFeatures.theme.color.uiColor
        case .theme: return Settings.userInterfaceFeatures.theme.color.favoriteColor
        case .custom: return UIColor(Settings.libraryFeatures.favorites.color)
        }
    }
}

extension FavoriteColor: LocalizedOptionValue
{
    var localizedDescription: Text {
        return Text(self.description)
    }
}

struct FavoriteGamesOptions
{
    @Option
    var sortFirst: Bool = true
    
    @Option(name: "Highlight Color",
            description: "Select which color to use to highlight your favorite games",
            values: FavoriteColor.allCases)
    var colorMode: FavoriteColor = .theme
    
    @Option(name: "Custom Highlight Color",
            description: "Select a custom color to use to highlight your favorite games.",
            detailView: { value in
        ColorPicker("Custom Highlight Color", selection: value, supportsOpacity: false)
            .displayInline()
    })
    var color: Color = .yellow
    
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
