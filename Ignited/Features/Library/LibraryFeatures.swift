//
//  LibraryFeatures.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 6/3/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import Features

struct LibraryFeatures: FeatureContainer
{
    static let shared = LibraryFeatures()
    
    @Feature(name: "Artwork Options",
             description: "Customize the look of your game artwork.",
             options: GameArtworkOptions(),
             permanent: true)
    var artwork
    
    @Feature(name: "Favorite Games",
             description: "Make your favorite games easy to find.",
             options: FavoriteGamesOptions(),
             permanent: true)
    var favorites
    
    @Feature(name: "Animated Artwork",
             description: "Bring your Library to life with your favorite GIFs.",
             options: AnimatedArtworkOptions())
    var animation
    
    private init()
    {
        self.prepareFeatures()
    }
}
