//
//  AppIcon.swift
//  Delta
//
//  Created by Chris Rittenhouse on 5/2/23.
//  Copyright © 2023 Lit Development. All rights reserved.
//

import SwiftUI

import Features

struct AppIconOptions
{
    @Option(name: "Use Custom Color",
            description: "Use the custom color selected below instead of the preset color above.")
    var useTheme: Bool = true
}
