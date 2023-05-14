//
//  PowerUser.swift
//  Delta
//
//  Created by Chris Rittenhouse on 5/1/23.
//  Copyright © 2023 Lit Development. All rights reserved.
//

import SwiftUI

import Features

struct PowerUserOptions
{
    @Option(name: "Clear Auto Save States",
            description: "This will delete all auto save states from every game. The auto-load save states feature relies on these auto save states to resume your game where you left off. Deleting them can be useful to reduce the size of your Sync backup.")
    var clearAutoSaves: Bool = false
    
    @Option(name: "Reset All Album Artwork",
            description: "Resets the artwork for every game to the artwork provided by the database, if there is one.")
    var resetArtwork: Bool = false
    
    @Option(name: "Reset Build Counter",
            description: "Resets the internal variable that tracks the last update shown. Causes the updates screen to be shown at next launch.")
    var resetBuildCounter: Bool = false
}
