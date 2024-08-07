//
//  ImportOptions.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 5/18/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import SwiftUI

import Features

struct ImportOptions
{
    @Option(name: "Automated Importing",
            description: "Enable to automatically import files from the Import folder when launching the app.")
    var automated: Bool = true
    
    @Option(name: "Sanitize Game Names",
            description: "Enable to remove region and revision tags from game file names when importing them.")
    var sanitize: Bool = true
    
    @Option(name: "Confirmation Popup",
            description: "Enable to show a popup detailing what was and wasn't successfully imported.")
    var popup: Bool = true
    
    @Option(name: "Restore Defaults",
            description: "Reset all options to their default values.",
            detailView: { _ in
        Button("Restore Defaults") {
            PowerUserOptions.resetFeature(.importOptions)
        }
        .font(.system(size: 17, weight: .bold, design: .default))
        .foregroundColor(.red)
        .displayInline()
    })
    var reset: Bool = false
}
