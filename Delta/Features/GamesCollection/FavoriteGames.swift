//
//  FavoriteGames.swift
//  Delta
//
//  Created by Chris Rittenhouse on 6/3/23.
//  Copyright © 2023 Lit Development. All rights reserved.
//

import UIKit
import SwiftUI

import Features

struct FavoriteGamesOptions
{
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
}
