//
//  FavoriteGames.swift
//  Delta
//
//  Created by Chris Rittenhouse on 5/5/23.
//  Copyright © 2023 Lit Development. All rights reserved.
//

import SwiftUI

import Features

struct FavoriteGamesOptions
{
    @Option(name: "Favorite Games",
            description: "Select games to be shown at the top of your games list.",
            values: ArtworkSize.allCases)
    var size: ArtworkSize = .medium
}
