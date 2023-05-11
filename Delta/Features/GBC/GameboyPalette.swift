//
//  GameboyPalette.swift
//  Delta
//
//  Created by Chris Rittenhouse on 5/10/23.
//  Copyright © 2023 Lit Development. All rights reserved.
//

import SwiftUI

import Features

enum GameboyPalette: String, CaseIterable, CustomStringConvertible
{
    case dmg = "DMG"
    case pocket = "Pocket"
    case light = "Light"
    case dmgLibretro = "DMG (Libretro)"
    case pocketLibretro = "Pocket (Libretro)"
    case lightLibretro = "Light (Libretro)"
    
    var description: String {
        return self.rawValue
    }
}

extension GameboyPalette: LocalizedOptionValue
{
    var localizedDescription: Text {
        Text(self.description)
    }
    
    static var nilDescription: String {
        return "No Palette"
    }
    
    static var localizedNilDescription: Text {
        return Text(self.nilDescription)
    }
}

struct GameboyPaletteOptions
{
    @Option(name: "Color Palette",
            description: "Choose which color palette to use for GB games.",
            values: GameboyPalette.allCases)
    var color: GameboyPalette? = .pocket
}
