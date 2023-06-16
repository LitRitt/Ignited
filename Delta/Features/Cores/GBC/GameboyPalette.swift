//
//  GameboyPalette.swift
//  Delta
//
//  Created by Chris Rittenhouse on 5/10/23.
//  Copyright © 2023 Lit Development. All rights reserved.
//

import SwiftUI

import Features

enum GameboyPalette: String, CaseIterable, CustomStringConvertible, Identifiable
{
    case custom1 = "Custom 1"
    case custom2 = "Custom 2"
    case custom3 = "Custom 3"
    case dmg = "DMG"
    case pocket = "Pocket"
    case light = "Light"
    case studio = "GB Studio"
    case kirokaze = "Kirokaze"
    case iceCream = "Ice Cream"
    case mist = "Mist"
    case demichrome = "Demichrome"
    case rustic = "Rustic"
    case wish = "Wish"
    case spacehaze = "Spacehaze"
    case aqua = "Aqua"
    case nymph = "Nymph"
    case andrade = "Andrade"
    case gold = "Gold"
    case velvet = "Velvet"
    case grapefruit = "Grapefruit"
    case amber = "Amber"
    case minty = "Minty"
    
    var description: String {
        return self.rawValue
    }
    
    var id: String {
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
        case .custom1: return [
            UIColor(GBCFeatures.shared.palettes.customPalette1Color1).cgColor.rgb(),
            UIColor(GBCFeatures.shared.palettes.customPalette1Color2).cgColor.rgb(),
            UIColor(GBCFeatures.shared.palettes.customPalette1Color3).cgColor.rgb(),
            UIColor(GBCFeatures.shared.palettes.customPalette1Color4).cgColor.rgb()]
        case .custom2: return [
            UIColor(GBCFeatures.shared.palettes.customPalette2Color1).cgColor.rgb(),
            UIColor(GBCFeatures.shared.palettes.customPalette2Color2).cgColor.rgb(),
            UIColor(GBCFeatures.shared.palettes.customPalette2Color3).cgColor.rgb(),
            UIColor(GBCFeatures.shared.palettes.customPalette2Color4).cgColor.rgb()]
        case .custom3: return [
            UIColor(GBCFeatures.shared.palettes.customPalette3Color1).cgColor.rgb(),
            UIColor(GBCFeatures.shared.palettes.customPalette3Color2).cgColor.rgb(),
            UIColor(GBCFeatures.shared.palettes.customPalette3Color3).cgColor.rgb(),
            UIColor(GBCFeatures.shared.palettes.customPalette3Color4).cgColor.rgb()]
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
        case .minty: return [0x00FFCA, 0x05BFDB, 0x088395, 0x0A4D68]
        }
    }
    
    static var nilColors: [UInt32] = [0xFFFFFF, 0xAAAAAA, 0x666666, 0x000000]
}

struct GameboyPaletteOptions
{
    @Option(name: "Color Palettes",
            description: "See what colors are used in each palette",
            detailView: { _ in
        List {
            ForEach(GameboyPalette.allCases) { palette in
                HStack {
                    palette.localizedDescription
                    Spacer()
                    Group {
                        Rectangle().foregroundColor(Color(fromRGB: palette.colors[0]))
                        Rectangle().foregroundColor(Color(fromRGB: palette.colors[1]))
                        Rectangle().foregroundColor(Color(fromRGB: palette.colors[2]))
                        Rectangle().foregroundColor(Color(fromRGB: palette.colors[3]))
                    }.frame(width: 35, height: 50).cornerRadius(5)
                }
            }
        }
    })
    var preview: String = "View"
    
    @Option(name: "Multiple Palettes",
            description: "Enable to use all three palette options. Disable to use only the Main Palette.")
    var multiPalette: Bool = false
    
    @Option(name: "Main Palette",
            description: "Choose the color palette for everything other than sprites.",
            values: GameboyPalette.allCases)
    var palette: GameboyPalette = .studio
    
    @Option(name: "Sprite Palette 1",
            description: "Choose the color palette to use for sprite layer 1.",
            values: GameboyPalette.allCases)
    var spritePalette1: GameboyPalette = .studio
    
    @Option(name: "Sprite Palette 2",
            description: "Choose which color palette to use for sprite layer 2.",
            values: GameboyPalette.allCases)
    var spritePalette2: GameboyPalette = .studio
    
    @Option(name: "Custom Palette 1",
            detailView: { _ in
        HStack {
            Text("Custom Palette 1")
            Spacer()
            Group {
                Rectangle().foregroundColor(Color(fromRGB: GameboyPalette.custom1.colors[0]))
                Rectangle().foregroundColor(Color(fromRGB: GameboyPalette.custom1.colors[1]))
                Rectangle().foregroundColor(Color(fromRGB: GameboyPalette.custom1.colors[2]))
                Rectangle().foregroundColor(Color(fromRGB: GameboyPalette.custom1.colors[3]))
            }.frame(width: 35, height: 50).cornerRadius(5)
        }.displayInline()
    })
    var customPalette1: String = ""
    
    @Option(name: "Custom Palette 1 Color 1",
            detailView: { value in
        ColorPicker("Color 1", selection: value, supportsOpacity: false)
            .displayInline()
    })
    var customPalette1Color1: Color = Color(fromRGB: GameboyPalette.studio.colors[0])
    
    @Option(name: "Custom Palette 1 Color 2",
            detailView: { value in
        ColorPicker("Color 2", selection: value, supportsOpacity: false)
            .displayInline()
    })
    var customPalette1Color2: Color = Color(fromRGB: GameboyPalette.studio.colors[1])
    
    @Option(name: "Custom Palette 1 Color 3",
            detailView: { value in
        ColorPicker("Color 3", selection: value, supportsOpacity: false)
            .displayInline()
    })
    var customPalette1Color3: Color = Color(fromRGB: GameboyPalette.studio.colors[2])
    
    @Option(name: "Custom Palette 1 Color 4",
            detailView: { value in
        ColorPicker("Color 4", selection: value, supportsOpacity: false)
            .displayInline()
    })
    var customPalette1Color4: Color = Color(fromRGB: GameboyPalette.studio.colors[3])
    
    @Option(name: "Custom Palette 2",
            detailView: { _ in
        HStack {
            Text("Custom Palette 2")
            Spacer()
            Group {
                Rectangle().foregroundColor(Color(fromRGB: GameboyPalette.custom2.colors[0]))
                Rectangle().foregroundColor(Color(fromRGB: GameboyPalette.custom2.colors[1]))
                Rectangle().foregroundColor(Color(fromRGB: GameboyPalette.custom2.colors[2]))
                Rectangle().foregroundColor(Color(fromRGB: GameboyPalette.custom2.colors[3]))
            }.frame(width: 35, height: 50).cornerRadius(5)
        }.displayInline()
    })
    var customPalette2: String = ""
    
    @Option(name: "Custom Palette 2 Color 1",
            detailView: { value in
        ColorPicker("Color 1", selection: value, supportsOpacity: false)
            .displayInline()
    })
    var customPalette2Color1: Color = Color(fromRGB: GameboyPalette.minty.colors[0])
    
    @Option(name: "Custom Palette 2 Color 2",
            detailView: { value in
        ColorPicker("Color 2", selection: value, supportsOpacity: false)
            .displayInline()
    })
    var customPalette2Color2: Color = Color(fromRGB: GameboyPalette.minty.colors[1])
    
    @Option(name: "Custom Palette 2 Color 3",
            detailView: { value in
        ColorPicker("Color 3", selection: value, supportsOpacity: false)
            .displayInline()
    })
    var customPalette2Color3: Color = Color(fromRGB: GameboyPalette.minty.colors[2])
    
    @Option(name: "Custom Palette 2 Color 4",
            detailView: { value in
        ColorPicker("Color 4", selection: value, supportsOpacity: false)
            .displayInline()
    })
    var customPalette2Color4: Color = Color(fromRGB: GameboyPalette.minty.colors[3])
    
    @Option(name: "Custom Palette 3",
            detailView: { _ in
        HStack {
            Text("Custom Palette 3")
            Spacer()
            Group {
                Rectangle().foregroundColor(Color(fromRGB: GameboyPalette.custom3.colors[0]))
                Rectangle().foregroundColor(Color(fromRGB: GameboyPalette.custom3.colors[1]))
                Rectangle().foregroundColor(Color(fromRGB: GameboyPalette.custom3.colors[2]))
                Rectangle().foregroundColor(Color(fromRGB: GameboyPalette.custom3.colors[3]))
            }.frame(width: 35, height: 50).cornerRadius(5)
        }.displayInline()
    })
    var customPalette3: String = ""
    
    @Option(name: "Custom Palette 3 Color 1",
            detailView: { value in
        ColorPicker("Color 1", selection: value, supportsOpacity: false)
            .displayInline()
    })
    var customPalette3Color1: Color = Color(fromRGB: GameboyPalette.spacehaze.colors[0])
    
    @Option(name: "Custom Palette 3 Color 2",
            detailView: { value in
        ColorPicker("Color 2", selection: value, supportsOpacity: false)
            .displayInline()
    })
    var customPalette3Color2: Color = Color(fromRGB: GameboyPalette.spacehaze.colors[1])
    
    @Option(name: "Custom Palette 3 Color 3",
            detailView: { value in
        ColorPicker("Color 3", selection: value, supportsOpacity: false)
            .displayInline()
    })
    var customPalette3Color3: Color = Color(fromRGB: GameboyPalette.spacehaze.colors[2])
    
    @Option(name: "Custom Palette 3 Color 4",
            detailView: { value in
        ColorPicker("Color 4", selection: value, supportsOpacity: false)
            .displayInline()
    })
    var customPalette3Color4: Color = Color(fromRGB: GameboyPalette.spacehaze.colors[3])
    
    @Option(name: "Restore Defaults", description: "Reset all options to their default values.", detailView: { value in
        Toggle(isOn: value) {
            Text("Restore Defaults")
                .font(.system(size: 17, weight: .bold, design: .default))
                .foregroundColor(.red)
        }
        .toggleStyle(SwitchToggleStyle(tint: .red))
        .displayInline()
    })
    var resetGameboyPalettes: Bool = false
}
