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

struct FavoriteGamesOptions
{
    @Option
    var sortFirst: Bool = true
    
    @Option(name: "Highlight Favorite Games",
            description: "Give your favorite games a distinct color.")
    var highlighted: Bool = true
    
    @Option(name: "Use Theme Color",
            description: "Use a color complementary to your theme color. Disable to use the custom color selected below.")
    var themed: Bool = true
    
    @Option(name: "Favorite Highlight Color",
            description: "Select a custom color to use to highlight your favorite games.",
            detailView: { value in
        ColorPicker("Favorite Highlight Color", selection: value, supportsOpacity: false)
            .displayInline()
    })
    var color: Color = .yellow
    
    @Option
    var games: [String: [String]] = [
        System.ds.gameType.rawValue: [],
        System.gba.gameType.rawValue: [],
        System.gbc.gameType.rawValue: [],
        System.nes.gameType.rawValue: [],
        System.snes.gameType.rawValue: [],
        System.n64.gameType.rawValue: [],
        System.genesis.gameType.rawValue: []
    ]
    
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
