//
//  GamesCollectionFeatures.swift
//  Delta
//
//  Created by Chris Rittenhouse on 6/3/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import Features

struct GamesCollectionFeatures: FeatureContainer
{
    static let shared = GamesCollectionFeatures()
    
    @Feature(name: "Artwork Customization",
             description: "Change the style of the game artwork.",
             options: GameArtworkOptions())
    var artwork
    
    @Feature(name: "Animated Artwork",
             description: "Bring your games collection to life.",
             options: AnimatedArtworkOptions())
    var animation
    
    @Feature(name: "Favorite Games",
             description: "Bring your favorite games front and center.",
             options: FavoriteGamesOptions())
    var favorites
    
    private init()
    {
        self.prepareFeatures()
    }
}
