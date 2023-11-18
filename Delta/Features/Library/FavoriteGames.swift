//
//  FavoriteGames.swift
//  Delta
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
    var favoriteSort: Bool = true
    
    @Option(name: "Highlight Favorite Games",
            description: "Give your favorite games a distinct color.")
    var favoriteHighlight: Bool = true
    
    @Option(name: "Favorite Highlight Color",
            description: "Select a custom color to use to highlight your favorite games.",
            detailView: { value in
        ColorPicker("Favorite Highlight Color", selection: value, supportsOpacity: false)
            .displayInline()
    })
    var favoriteColor: Color = .yellow
    
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
    var resetFavoriteGames: Bool = false
}
