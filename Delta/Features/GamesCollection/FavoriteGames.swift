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
    
    @Option(name: "Favorite Highlight Intensity", description: "Change how intense the glow effect is on favorited games.", detailView: { value in
        VStack {
            HStack {
                Text("Favorite Highlight Intensity: \(value.wrappedValue * 100, specifier: "%.f")%")
                Spacer()
            }
            HStack {
                Text("0%")
                Slider(value: value, in: 0.0...1.0, step: 0.05)
                Text("100%")
            }
        }.displayInline()
    })
    var highlightIntensity: Double = 0.7
    
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
    
    @Option(name: "Restore Defaults", description: "Reset all options to their default values.", detailView: { value in
        Toggle(isOn: value) {
            Text("Restore Defaults")
                .font(.system(size: 17, weight: .bold, design: .default))
                .foregroundColor(.red)
        }
        .toggleStyle(SwitchToggleStyle(tint: .red))
        .displayInline()
    })
    var resetFavoriteGames: Bool = false
}
