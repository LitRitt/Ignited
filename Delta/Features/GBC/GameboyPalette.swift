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
    case custom = "Custom"
    case dmg = "DMG"
    case pocket = "Pocket"
    case light = "Light"
    case studio = "GB Studio"
    case kirokaze = "Kirokaze"
    case iceCream = "Ice Cream"
    case mist = "Mist"
    case demichrome = "2Bit Demichrome"
    case rustic = "Rustic"
    case wish = "Wish"
    case spacehaze = "Spacehaze"
    case aqua = "BLK AQU4"
    case nymph = "Nymph"
    case andrade = "Andrade"
    case gold = "Gold"
    case velvet = "Velvet"
    case grapefruit = "Grapefruit"
    case amber = "Amber"
    
    var description: String {
        return self.rawValue
    }
}

extension GameboyPalette: LocalizedOptionValue
{
    var localizedDescription: Text {
        Text(self.description)
    }
}

extension GameboyPalette
{
    var colors: [UInt32]
    {
        switch self
        {
        case .custom: return [
            GBCFeatures.shared.palettes.customColor1.cgColor!.rgb(),
            GBCFeatures.shared.palettes.customColor2.cgColor!.rgb(),
            GBCFeatures.shared.palettes.customColor3.cgColor!.rgb(),
            GBCFeatures.shared.palettes.customColor4.cgColor!.rgb()]
        case .dmg: return [0x99A342, 0x768736, 0x4F632C, 0x405420]
        case .pocket: return [0xAAB59C, 0x848C72, 0x4E5540, 0x292E25]
        case .light: return [0x4BD4E5, 0x4ABBC8, 0x13A1AA, 0x286F7F]
        case .studio: return [0xe0f8cf, 0x86c06c, 0x306850, 0x071821]
        case .kirokaze: return [0xe2f3e4, 0x94e344, 0x46878f, 0x332c50]
        case .iceCream: return [0xfff6d3, 0xf9a875, 0xeb6b6f, 0x7c3f58]
        case .mist: return [0xc4f0c2, 0x5ab9a8, 0x1e606e, 0x2d1b00]
        case .demichrome: return [0xe9efec, 0xa0a08b, 0x555568, 0x211e20]
        case .rustic: return [0xedb4a1, 0xa96868, 0x764462, 0x2c2137]
        case .wish: return [0x8be5ff, 0x608fcf, 0x7550e8, 0x622e4c]
        case .spacehaze: return [0xf8e3c4, 0xcc3495, 0x6b1fb1, 0x0b0630]
        case .aqua: return [0x9ff4e5, 0x00b9be, 0x005f8c, 0x002b59]
        case .nymph: return [0xa1ef8c, 0x3fac95, 0x446176, 0x2c2137]
        case .andrade: return [0xe3eec0, 0xaeba89, 0x5e6745, 0x202020]
        case .gold: return [0xcfab51, 0x9d654c, 0x4d222c, 0x210b1b]
        case .velvet: return [0x9775a6, 0x683a68, 0x412752, 0x2d162c]
        case .grapefruit: return [0xfff5dd, 0xf4b26b, 0xb76591, 0x65296c]
        case .amber: return [0xfed018, 0xd35600, 0x5e1210, 0x0d0405]
        }
    }
    
    static var nilColors: [UInt32] = [0xFFFFFF, 0xAAAAAA, 0x666666, 0x000000]
}

struct GameboyPaletteOptions
{
    @Option(name: "Color Palette",
            description: "Choose which color palette to use for GB games.",
            values: GameboyPalette.allCases)
    var palette: GameboyPalette = .pocket
    
    @Option(name: "Custom Palette Color 1",
            description: "Select a custom color to use for palette color 1.",
            detailView: { value in
        ColorPicker("Custom Palette Color 1", selection: value, supportsOpacity: false)
            .displayInline()
    })
    var customColor1: Color = Color(red: 0/255, green: 0/255, blue: 0/255)
    
    @Option(name: "Custom Palette Color 2",
            description: "Select a custom color to use for palette color 2.",
            detailView: { value in
        ColorPicker("Custom Palette Color 2", selection: value, supportsOpacity: false)
            .displayInline()
    })
    var customColor2: Color = Color(red: 86/255, green: 86/255, blue: 86/255)
    
    @Option(name: "Custom Palette Color 3",
            description: "Select a custom color to use for palette color 3.",
            detailView: { value in
        ColorPicker("Custom Palette Color 3", selection: value, supportsOpacity: false)
            .displayInline()
    })
    var customColor3: Color = Color(red: 172/255, green: 172/255, blue: 172/255)
    
    @Option(name: "Custom Palette Color 4",
            description: "Select a custom color to use for palette color 4.",
            detailView: { value in
        ColorPicker("Custom Palette Color 4", selection: value, supportsOpacity: false)
            .displayInline()
    })
    var customColor4: Color = Color(red: 255/255, green: 255/255, blue: 255/255)
}
