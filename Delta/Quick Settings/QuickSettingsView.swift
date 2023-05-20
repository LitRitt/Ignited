//
//  QuickSettingsView.swift
//  Delta
//
//  Created by Chris Rittenhouse on 5/14/23.
//  Copyright © 2023 Lit Development. All rights reserved.
//

import SwiftUI

import Features

private enum Systems: String, CaseIterable
{
    case gba = "com.rileytestut.delta.game.gba"
    case gbc = "com.rileytestut.delta.game.gbc"
    case ds = "com.rileytestut.delta.game.ds"
    case nes = "com.rileytestut.delta.game.nes"
    case snes = "com.rileytestut.delta.game.snes"
    case n64 = "com.rileytestut.delta.game.n64"
    case genesis = "com.rileytestut.delta.game.genesis"
}

@available(iOS 15.0, *)
struct QuickSettingsView: View
{
    private var system: String
    private let systemsWithPalettes = [Systems.gbc.rawValue]
    
    @State private var fastForwardSpeed: Double
    @State private var gameAudioVolume: Double = GameplayFeatures.shared.gameAudio.volume
    
    @State private var gameboyPalette: GameboyPalette = GBCFeatures.shared.palettes.palette
    @State private var gameboySpritePalette1: GameboyPalette = GBCFeatures.shared.palettes.spritePalette1
    @State private var gameboySpritePalette2: GameboyPalette = GBCFeatures.shared.palettes.spritePalette2
    
    var body: some View {
        VStack {
            HStack {
                Text("Quick Settings").font(.largeTitle)
                    .foregroundColor(.accentColor)
                Spacer()
                Button("Pause") {
                    performPause()
                }.buttonStyle(.bordered)
            }
                .padding(.top, 30)
                .padding(.leading, 30)
                .padding(.trailing, 30)
            Form {
                if GameplayFeatures.shared.quickSettings.quickActionsEnabled
                {
                    Section() {
                            HStack {
                                VStack {
                                    Button {
                                        performScreenshot()
                                    } label: {
                                        Image("Screenshot")
                                    }
                                    Text("Screenshot")
                                        .font(.caption)
                                }
                                Spacer()
                                VStack {
                                    Button {
                                        performQuickSave()
                                    } label: {
                                        Image("SaveSaveState")
                                    }
                                    Text("Quick Save")
                                        .font(.caption)
                                }
                                Spacer()
                                VStack {
                                    Button {
                                        performQuickLoad()
                                    } label: {
                                        Image("LoadSaveState")
                                    }
                                    Text("Quick Load")
                                        .font(.caption)
                                }
                            }.buttonStyle(.borderless)
                    } header: {
                        Text("Quick Actions")
                    }.listStyle(.insetGrouped)
                }
                
                if GameplayFeatures.shared.quickSettings.fastForwardEnabled && GameplayFeatures.shared.fastForward.isEnabled
                {
                    Section() {
                        VStack {
                            HStack {
                                Text("Game Speed: \(fastForwardSpeed * 100, specifier: "%.f")%")
                                Spacer()
                                Button("Reset") {
                                    fastForwardSpeed = 1.0
                                    updateFastForwardSpeed()
                                }
                            }
                            Slider(value: $fastForwardSpeed, in: 0.1...8.0, step: 0.1)
                                .onChange(of: fastForwardSpeed) { value in
                                    GameplayFeatures.shared.quickSettings.fastForwardSpeed = value
                                }
                            
                            if GameplayFeatures.shared.quickSettings.expandedFastForwardEnabled
                            {
                                HStack {
                                    Button("50%") {
                                        fastForwardSpeed = 0.5
                                        updateFastForwardSpeed()
                                    }
                                    Spacer()
                                    Button("125%") {
                                        fastForwardSpeed = 1.25
                                        updateFastForwardSpeed()
                                    }
                                    Spacer()
                                    Button("150%") {
                                        fastForwardSpeed = 1.5
                                        updateFastForwardSpeed()
                                    }
                                    Spacer()
                                    Button("200%") {
                                        fastForwardSpeed = 2.0
                                        updateFastForwardSpeed()
                                    }
                                }.padding(.top, 10)
                                HStack {
                                    Button("300%") {
                                        fastForwardSpeed = 3.0
                                        updateFastForwardSpeed()
                                    }
                                    Spacer()
                                    Button("400%") {
                                        fastForwardSpeed = 4.0
                                        updateFastForwardSpeed()
                                    }
                                    Spacer()
                                    Button("800%") {
                                        fastForwardSpeed = 8.0
                                        updateFastForwardSpeed()
                                    }
                                    Spacer()
                                    Button("1600%") {
                                        fastForwardSpeed = 16.0
                                        updateFastForwardSpeed()
                                    }
                                }.padding(.top, 10)
                            }
                        }.buttonStyle(.borderless)
                    } header: {
                        Text("Fast Forward")
                    }.listStyle(.insetGrouped)
                }
                
                if GameplayFeatures.shared.quickSettings.gameAudioEnabled && GameplayFeatures.shared.gameAudio.isEnabled
                {
                    Section() {
                        VStack {
                            HStack {
                                Text("Game Volume: \(gameAudioVolume * 100, specifier: "%.f")%")
                                Spacer()
                                Button("Reset") {
                                    gameAudioVolume = 1.0
                                    updateGameAudioVolume()
                                }.buttonStyle(.borderless)
                            }
                            Slider(value: $gameAudioVolume, in: 0.0...1.0, step: 0.05)
                                .onChange(of: gameAudioVolume) { value in
                                    GameplayFeatures.shared.gameAudio.volume = value
                                }
                            
                            if GameplayFeatures.shared.quickSettings.expandedGameAudioEnabled
                            {
                                Toggle("Respect Silent Mode", isOn: GameplayFeatures.shared.gameAudio.$respectSilent.valueBinding)
                                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                                Toggle("Play Over Other Media", isOn: GameplayFeatures.shared.gameAudio.$playOver.valueBinding)
                                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                            }
                        }
                    } header: {
                        Text("Game Audio")
                    }.listStyle(.insetGrouped)
                }
                
                if GameplayFeatures.shared.quickSettings.colorPalettesEnabled,
                   GBCFeatures.shared.palettes.isEnabled,
                   systemsWithPalettes.contains(system)
                {
                    Section() {
                        HStack {
                            Group {
                                Rectangle().foregroundColor(Color(fromRGB: gameboyPalette.colors[0]))
                                Rectangle().foregroundColor(Color(fromRGB: gameboyPalette.colors[1]))
                                Rectangle().foregroundColor(Color(fromRGB: gameboyPalette.colors[2]))
                                Rectangle().foregroundColor(Color(fromRGB: gameboyPalette.colors[3]))
                            }.frame(width: 40, height: 30).cornerRadius(5)
                            Spacer()
                            Picker("", selection: $gameboyPalette) {
                                ForEach(GameboyPalette.allCases, id: \.self) { value in
                                    value.localizedDescription
                                }
                            }
                                .onChange(of: gameboyPalette) { value in
                                    GBCFeatures.shared.palettes.palette = value
                                }
                        }
                    } header: {
                        Text("Main Color Palette")
                    }.listStyle(.insetGrouped)
                        
                    if GBCFeatures.shared.palettes.multiPalette
                    {
                        Section() {
                            HStack {
                                Group {
                                    Rectangle().foregroundColor(Color(fromRGB: gameboySpritePalette1.colors[0]))
                                    Rectangle().foregroundColor(Color(fromRGB: gameboySpritePalette1.colors[1]))
                                    Rectangle().foregroundColor(Color(fromRGB: gameboySpritePalette1.colors[2]))
                                    Rectangle().foregroundColor(Color(fromRGB: gameboySpritePalette1.colors[3]))
                                }.frame(width: 40, height: 30).cornerRadius(5)
                                Spacer()
                                Picker("", selection: $gameboySpritePalette1) {
                                    ForEach(GameboyPalette.allCases, id: \.self) { value in
                                        value.localizedDescription
                                    }
                                }
                                    .onChange(of: gameboySpritePalette1) { value in
                                        GBCFeatures.shared.palettes.spritePalette1 = value
                                    }
                            }
                        } header: {
                            Text("Sprite Palette 1")
                        }.listStyle(.insetGrouped)
                        
                        Section() {
                            HStack {
                                Group {
                                    Rectangle().foregroundColor(Color(fromRGB: gameboySpritePalette2.colors[0]))
                                    Rectangle().foregroundColor(Color(fromRGB: gameboySpritePalette2.colors[1]))
                                    Rectangle().foregroundColor(Color(fromRGB: gameboySpritePalette2.colors[2]))
                                    Rectangle().foregroundColor(Color(fromRGB: gameboySpritePalette2.colors[3]))
                                }.frame(width: 40, height: 30).cornerRadius(5)
                                Spacer()
                                Picker("", selection: $gameboySpritePalette2) {
                                    ForEach(GameboyPalette.allCases, id: \.self) { value in
                                        value.localizedDescription
                                    }
                                }
                                    .onChange(of: gameboySpritePalette2) { value in
                                    GBCFeatures.shared.palettes.spritePalette2 = value
                                }
                            }
                        } header: {
                            Text("Sprite Palette 2")
                        }.listStyle(.insetGrouped)
                    }
                }
                
                Section() {
                    VStack {
                        Toggle("Quick Actions", isOn: GameplayFeatures.shared.quickSettings.$quickActionsEnabled.valueBinding)
                        Toggle("Fast Forward", isOn: GameplayFeatures.shared.quickSettings.$fastForwardEnabled.valueBinding)
                        Toggle("Expanded Fast Forward", isOn: GameplayFeatures.shared.quickSettings.$expandedFastForwardEnabled.valueBinding)
                        Toggle("Game Audio", isOn: GameplayFeatures.shared.quickSettings.$gameAudioEnabled.valueBinding)
                        Toggle("Expanded Game Audio", isOn: GameplayFeatures.shared.quickSettings.$expandedGameAudioEnabled.valueBinding)
                        if systemsWithPalettes.contains(system)
                        {
                            Toggle("Color Palettes", isOn: GameplayFeatures.shared.quickSettings.$colorPalettesEnabled.valueBinding)
                        }
                    }.toggleStyle(SwitchToggleStyle(tint: .accentColor))
                } header: {
                    Text("Enabled Sections")
                }.listStyle(.insetGrouped)
            }
        }
    }
    
    func updateGameAudioVolume()
    {
        GameplayFeatures.shared.gameAudio.volume = gameAudioVolume
    }
    
    func updateFastForwardSpeed()
    {
        GameplayFeatures.shared.quickSettings.fastForwardSpeed = fastForwardSpeed
    }
    
    func performQuickSave()
    {
        GameplayFeatures.shared.quickSettings.performQuickSave = true
    }
    
    func performQuickLoad()
    {
        GameplayFeatures.shared.quickSettings.performQuickLoad = true
    }
    
    func performScreenshot()
    {
        GameplayFeatures.shared.quickSettings.performScreenshot = true
    }
    
    func performPause()
    {
        GameplayFeatures.shared.quickSettings.performPause = true
    }
}

@available(iOS 15.0, *)
extension QuickSettingsView
{
    static func makeViewController(system system: String, speed speed: Double) -> UIHostingController<some View>
    {
        let view = QuickSettingsView(system: system, fastForwardSpeed: speed)
        
        let hostingController = UIHostingController(rootView: view)
        
        return hostingController
    }
}

