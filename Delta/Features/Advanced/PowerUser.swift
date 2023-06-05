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
            description: "This will delete all auto save states from every game. The auto-load save states feature relies on these auto save states to resume your game where you left off. Deleting them can be useful to reduce the size of your Sync backup.",
            detailView: { value in
        Toggle(isOn: value) {
            Text("Clear Auto Save States")
                .font(.system(size: 17, weight: .bold, design: .default))
                .foregroundColor(.red)
        }
        .toggleStyle(SwitchToggleStyle(tint: .red))
        .displayInline()
    })
    var clearAutoSaves: Bool = false
    
    @Option(name: "Reset All Album Artwork",
            description: "Resets the artwork for every game to the artwork provided by the database, if there is one.",
            detailView: { value in
        Toggle(isOn: value) {
            Text("Reset All Album Artwork")
                .font(.system(size: 17, weight: .bold, design: .default))
                .foregroundColor(.red)
        }
        .toggleStyle(SwitchToggleStyle(tint: .red))
        .displayInline()
    })
    var resetArtwork: Bool = false
    
    @Option(name: "Reset Build Counter",
            description: "Resets the internal variable that tracks the last update shown. Causes the updates screen to be shown at next launch.",
            detailView: { value in
        Toggle(isOn: value) {
            Text("Reset Build Counter")
                .font(.system(size: 17, weight: .bold, design: .default))
                .foregroundColor(.red)
        }
        .toggleStyle(SwitchToggleStyle(tint: .red))
        .displayInline()
    })
    var resetBuildCounter: Bool = false
    
    @Option(name: "Reset All Feature Settings",
            description: "Resets every single feature setting to their default values. This cannot be undone, please only do so if you are absolutely sure your issue cannot be solved by resetting an individual feature, or want to return to a stock Ignited experience.",
            detailView: { value in
        Toggle(isOn: value) {
            Text("Reset All Feature Settings")
                .font(.system(size: 17, weight: .bold, design: .default))
                .foregroundColor(.red)
        }
        .toggleStyle(SwitchToggleStyle(tint: .red))
        .displayInline()
    })
    var resetAllSettings: Bool = false
}
