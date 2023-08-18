//
//  RandomGame.swift
//  Delta
//
//  Created by Chris Rittenhouse on 8/17/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import SwiftUI

import Features

struct RandomGameOptions
{
    @Option(name: "Select from Current Collection",
            description: "When enabled, a game will be chosen from the current game collection page. When disabled, a game will be chosen from all games.")
    var useCollection: Bool = false
    
    @Option(name: "Restore Defaults",
            description: "Reset all options to their default values.",
            detailView: { _ in
        Button("Restore Defaults") {
            PowerUserOptions.resetFeature(.randomGame)
        }
        .font(.system(size: 17, weight: .bold, design: .default))
        .foregroundColor(.red)
        .displayInline()
    })
    var resetRandomGame: Bool = false
}

