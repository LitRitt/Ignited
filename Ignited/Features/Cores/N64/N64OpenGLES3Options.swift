//
//  N64OpenGLES3Options.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 1/10/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import SwiftUI

import Features

struct N64OpenGLES3Options
{
    @Option
    var enabledGames: [String] = []
    
    @Option(name: "Reset Enabled Games",
            description: "Disable OpenGLES 3 for all games.",
            detailView: { _ in
        Button("Reset Enabled Games") {
            PowerUserOptions.resetFeature(.n64OpenGLES3)
        }
        .font(.system(size: 17, weight: .bold, design: .default))
        .foregroundColor(.red)
        .displayInline()
    })
    var reset: Bool = false
}
