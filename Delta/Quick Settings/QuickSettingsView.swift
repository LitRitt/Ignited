//
//  QuickSettingsView.swift
//  Delta
//
//  Created by Chris Rittenhouse on 5/14/23.
//  Copyright © 2023 LitRitt. All rights reserved.
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
    
    @State private var controllerSkinOpacity: Double = ControllerSkinFeatures.shared.skinCustomization.opacity
    @State private var controllerSkinBackgroundColor: Color = ControllerSkinFeatures.shared.skinCustomization.backgroundColor
    
    @State private var backgroundBlurStrength: Double = ControllerSkinFeatures.shared.backgroundBlur.blurStrength
    @State private var backgroundBlurBrightness: Double = ControllerSkinFeatures.shared.backgroundBlur.blurBrightness
    
    @State private var gameboyPalette: GameboyPalette = GBCFeatures.shared.palettes.palette
    @State private var gameboySpritePalette1: GameboyPalette = GBCFeatures.shared.palettes.spritePalette1
    @State private var gameboySpritePalette2: GameboyPalette = GBCFeatures.shared.palettes.spritePalette2
    
    @State private var quickActionsEnabled: Bool = GameplayFeatures.shared.quickSettings.quickActionsEnabled
    @State private var fastForwardEnabled: Bool = GameplayFeatures.shared.quickSettings.fastForwardEnabled
    @State private var expandedFastForwardEnabled: Bool = GameplayFeatures.shared.quickSettings.expandedFastForwardEnabled
    @State private var gameAudioEnabled: Bool = GameplayFeatures.shared.quickSettings.gameAudioEnabled
    @State private var expandedGameAudioEnabled: Bool = GameplayFeatures.shared.quickSettings.expandedGameAudioEnabled
    @State private var controllerSkinEnabled: Bool = GameplayFeatures.shared.quickSettings.controllerSkinEnabled
    @State private var expandedControllerSkinEnabled: Bool = GameplayFeatures.shared.quickSettings.expandedControllerSkinEnabled
    @State private var backgroundBlurEnabled: Bool = GameplayFeatures.shared.quickSettings.backgroundBlurEnabled
    @State private var expandedBackgroundBlurEnabled: Bool = GameplayFeatures.shared.quickSettings.expandedBackgroundBlurEnabled
    @State private var colorPalettesEnabled: Bool = GameplayFeatures.shared.quickSettings.colorPalettesEnabled
    
    var body: some View {
        VStack {
            HStack {
                Button("Main Menu") {
                    self.performMainMenu()
                }.font(.system(size: 18, weight: .bold, design: .default))
                    .foregroundColor(.red)
                Spacer()
                Button("Pause Menu") {
                    self.performPause()
                }.font(.system(size: 18, weight: .bold, design: .default))
            }.buttonStyle(.bordered)
                .padding(.top, 16)
                .padding(.leading, 16)
                .padding(.trailing, 16)
            Form {
                if self.quickActionsEnabled
                {
                    Section() {
                            HStack {
                                VStack {
                                    Button {
                                        self.performScreenshot()
                                    } label: {
                                        Image("Screenshot")
                                            .frame(width: 40, height: 40)
                                    }
                                    Text("Screenshot")
                                        .font(.caption)
                                }
                                Spacer()
                                VStack {
                                    Button {
                                        self.performQuickSave()
                                    } label: {
                                        Image("SaveSaveState")
                                            .frame(width: 40, height: 40)
                                    }
                                    Text("Quick Save")
                                        .font(.caption)
                                }
                                Spacer()
                                VStack {
                                    Button {
                                        self.performQuickLoad()
                                    } label: {
                                        Image("LoadSaveState")
                                            .frame(width: 40, height: 40)
                                    }
                                    Text("Quick Load")
                                        .font(.caption)
                                }
                            }.buttonStyle(.borderless)
                    } header: {
                        Text("Quick Actions")
                    }.listStyle(.insetGrouped)
                }
                
                if self.fastForwardEnabled && GameplayFeatures.shared.fastForward.isEnabled
                {
                    Section() {
                        VStack {
                            HStack {
                                Text("Game Speed: \(self.fastForwardSpeed * 100, specifier: "%.f")%")
                                Spacer()
                                Button("Reset") {
                                    self.fastForwardSpeed = 1.0
                                    GameplayFeatures.shared.quickSettings.fastForwardSpeed = self.fastForwardSpeed
                                }
                            }
                            Slider(value: self.$fastForwardSpeed, in: 0.1...8.0, step: 0.1)
                                .onChange(of: self.fastForwardSpeed) { value in
                                    GameplayFeatures.shared.quickSettings.fastForwardSpeed = value
                                }
                            
                            if self.expandedFastForwardEnabled
                            {
                                HStack {
                                    Button("50%") {
                                        self.fastForwardSpeed = 0.5
                                        GameplayFeatures.shared.quickSettings.fastForwardSpeed = self.fastForwardSpeed
                                    }
                                    Spacer()
                                    Button("125%") {
                                        self.fastForwardSpeed = 1.25
                                        GameplayFeatures.shared.quickSettings.fastForwardSpeed = self.fastForwardSpeed
                                    }
                                    Spacer()
                                    Button("150%") {
                                        self.fastForwardSpeed = 1.5
                                        GameplayFeatures.shared.quickSettings.fastForwardSpeed = self.fastForwardSpeed
                                    }
                                    Spacer()
                                    Button("200%") {
                                        self.fastForwardSpeed = 2.0
                                        GameplayFeatures.shared.quickSettings.fastForwardSpeed = self.fastForwardSpeed
                                    }
                                }.padding(.top, 10)
                                HStack {
                                    Button("300%") {
                                        self.fastForwardSpeed = 3.0
                                        GameplayFeatures.shared.quickSettings.fastForwardSpeed = self.fastForwardSpeed
                                    }
                                    Spacer()
                                    Button("400%") {
                                        self.fastForwardSpeed = 4.0
                                        GameplayFeatures.shared.quickSettings.fastForwardSpeed = self.fastForwardSpeed
                                    }
                                    Spacer()
                                    Button("800%") {
                                        self.fastForwardSpeed = 8.0
                                        GameplayFeatures.shared.quickSettings.fastForwardSpeed = self.fastForwardSpeed
                                    }
                                    Spacer()
                                    Button("1600%") {
                                        self.fastForwardSpeed = 16.0
                                        GameplayFeatures.shared.quickSettings.fastForwardSpeed = self.fastForwardSpeed
                                    }
                                }.padding(.top, 10)
                                Toggle("Toggle Fast Forward", isOn: GameplayFeatures.shared.fastForward.$toggle.valueBinding)
                                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                            }
                        }.buttonStyle(.borderless)
                    } header: {
                        Text("Fast Forward")
                    }.listStyle(.insetGrouped)
                }
                
                if self.gameAudioEnabled && GameplayFeatures.shared.gameAudio.isEnabled
                {
                    Section() {
                        VStack {
                            HStack {
                                Text("Game Volume: \(self.gameAudioVolume * 100, specifier: "%.f")%")
                                Spacer()
                                Button("Reset") {
                                    self.gameAudioVolume = 1.0
                                    GameplayFeatures.shared.gameAudio.volume = self.gameAudioVolume
                                }.buttonStyle(.borderless)
                            }
                            Slider(value: self.$gameAudioVolume, in: 0.0...1.0, step: 0.05)
                                .onChange(of: self.gameAudioVolume) { value in
                                    GameplayFeatures.shared.gameAudio.volume = value
                                }
                            
                            if self.expandedGameAudioEnabled
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
                
                if self.controllerSkinEnabled && ControllerSkinFeatures.shared.skinCustomization.isEnabled
                {
                    Section() {
                        VStack {
                            HStack {
                                Text("Controller Skin Opacity: \(self.controllerSkinOpacity * 100, specifier: "%.f")%")
                                Spacer()
                                Button("Reset") {
                                    self.controllerSkinOpacity = 1.0
                                    ControllerSkinFeatures.shared.skinCustomization.opacity = self.controllerSkinOpacity
                                }.buttonStyle(.borderless)
                            }
                            Slider(value: self.$controllerSkinOpacity, in: 0.0...1.0, step: 0.05)
                                .onChange(of: self.controllerSkinOpacity) { value in
                                    ControllerSkinFeatures.shared.skinCustomization.opacity = value
                                }
                            
                            if self.expandedControllerSkinEnabled
                            {
                                ColorPicker("Background Color", selection: self.$controllerSkinBackgroundColor, supportsOpacity: false)
                                    .onChange(of: self.controllerSkinBackgroundColor) { value in
                                        ControllerSkinFeatures.shared.skinCustomization.backgroundColor = value
                                    }
                                Toggle("Match Theme Color", isOn: ControllerSkinFeatures.shared.skinCustomization.$matchTheme.valueBinding)
                                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                                Toggle("Show With Controller", isOn: ControllerSkinFeatures.shared.skinCustomization.$alwaysShow.valueBinding)
                                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                            }
                        }
                    } header: {
                        Text("Controller Skin")
                    }.listStyle(.insetGrouped)
                }
                
                if self.backgroundBlurEnabled && ControllerSkinFeatures.shared.backgroundBlur.isEnabled
                {
                    Section() {
                        VStack {
                            HStack {
                                Text("Blur Strength: \(self.backgroundBlurStrength * 100, specifier: "%.f")%")
                                Spacer()
                                Button("Reset") {
                                    self.backgroundBlurStrength = 1.0
                                    ControllerSkinFeatures.shared.backgroundBlur.blurStrength = self.backgroundBlurStrength
                                }.buttonStyle(.borderless)
                            }
                            Slider(value: self.$backgroundBlurStrength, in: 0.5...2.0, step: 0.1)
                                .onChange(of: self.backgroundBlurStrength) { value in
                                    ControllerSkinFeatures.shared.backgroundBlur.blurStrength = value
                                }
                            HStack {
                                Text("Blur Brightness: \(self.backgroundBlurBrightness * 100, specifier: "%.f")%")
                                Spacer()
                                Button("Reset") {
                                    self.backgroundBlurBrightness = 0
                                    ControllerSkinFeatures.shared.backgroundBlur.blurBrightness = self.backgroundBlurBrightness
                                }.buttonStyle(.borderless)
                            }
                            Slider(value: self.$backgroundBlurBrightness, in: -0.5...0.5, step: 0.05)
                                .onChange(of: self.backgroundBlurBrightness) { value in
                                    ControllerSkinFeatures.shared.backgroundBlur.blurBrightness = value
                                }
                            if self.expandedBackgroundBlurEnabled {
                                Toggle("Blur Enabled", isOn: ControllerSkinFeatures.shared.backgroundBlur.$blurBackground.valueBinding)
                                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                                Toggle("Override Skin Setting", isOn: ControllerSkinFeatures.shared.backgroundBlur.$blurOverride.valueBinding)
                                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                                Toggle("Maintain Aspect Ratio", isOn: ControllerSkinFeatures.shared.backgroundBlur.$blurAspect.valueBinding)
                                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                            }
                        }
                    } header: {
                        Text("Background Blur")
                    }.listStyle(.insetGrouped)
                }
                
                if self.colorPalettesEnabled,
                   GBCFeatures.shared.palettes.isEnabled,
                   self.systemsWithPalettes.contains(system)
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
                            Picker("", selection: self.$gameboyPalette) {
                                ForEach(GameboyPalette.allCases, id: \.self) { value in
                                    value.localizedDescription
                                }
                            }
                            .onChange(of: self.gameboyPalette) { value in
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
                                    Rectangle().foregroundColor(Color(fromRGB: self.gameboySpritePalette1.colors[0]))
                                    Rectangle().foregroundColor(Color(fromRGB: self.gameboySpritePalette1.colors[1]))
                                    Rectangle().foregroundColor(Color(fromRGB: self.gameboySpritePalette1.colors[2]))
                                    Rectangle().foregroundColor(Color(fromRGB: self.gameboySpritePalette1.colors[3]))
                                }.frame(width: 40, height: 30).cornerRadius(5)
                                Spacer()
                                Picker("", selection: self.$gameboySpritePalette1) {
                                    ForEach(GameboyPalette.allCases, id: \.self) { value in
                                        value.localizedDescription
                                    }
                                }
                                .onChange(of: self.gameboySpritePalette1) { value in
                                        GBCFeatures.shared.palettes.spritePalette1 = value
                                    }
                            }
                        } header: {
                            Text("Sprite Palette 1")
                        }.listStyle(.insetGrouped)
                        
                        Section() {
                            HStack {
                                Group {
                                    Rectangle().foregroundColor(Color(fromRGB: self.gameboySpritePalette2.colors[0]))
                                    Rectangle().foregroundColor(Color(fromRGB: self.gameboySpritePalette2.colors[1]))
                                    Rectangle().foregroundColor(Color(fromRGB: self.gameboySpritePalette2.colors[2]))
                                    Rectangle().foregroundColor(Color(fromRGB: self.gameboySpritePalette2.colors[3]))
                                }.frame(width: 40, height: 30).cornerRadius(5)
                                Spacer()
                                Picker("", selection: self.$gameboySpritePalette2) {
                                    ForEach(GameboyPalette.allCases, id: \.self) { value in
                                        value.localizedDescription
                                    }
                                }
                                .onChange(of: self.gameboySpritePalette2) { value in
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
                        Toggle("Quick Actions", isOn: self.$quickActionsEnabled)
                            .onChange(of: self.quickActionsEnabled) { value in
                                GameplayFeatures.shared.quickSettings.quickActionsEnabled = value
                            }
                        if GameplayFeatures.shared.fastForward.isEnabled {
                            Toggle("Fast Forward", isOn: self.$fastForwardEnabled)
                                .onChange(of: self.fastForwardEnabled) { value in
                                    GameplayFeatures.shared.quickSettings.fastForwardEnabled = value
                                }
                            if self.fastForwardEnabled {
                                Toggle("Expanded Fast Forward", isOn: self.$expandedFastForwardEnabled)
                                    .onChange(of: self.expandedFastForwardEnabled) { value in
                                        GameplayFeatures.shared.quickSettings.expandedFastForwardEnabled = value
                                    }
                            }
                        }
                        if GameplayFeatures.shared.gameAudio.isEnabled {
                            Toggle("Game Audio", isOn: self.$gameAudioEnabled)
                                .onChange(of: self.gameAudioEnabled) { value in
                                    GameplayFeatures.shared.quickSettings.gameAudioEnabled = value
                                }
                            if self.gameAudioEnabled {
                                Toggle("Expanded Game Audio", isOn: self.$expandedGameAudioEnabled)
                                    .onChange(of: self.expandedGameAudioEnabled) { value in
                                        GameplayFeatures.shared.quickSettings.expandedGameAudioEnabled = value
                                    }
                            }
                        }
                        if ControllerSkinFeatures.shared.skinCustomization.isEnabled {
                            Toggle("Controller Skin", isOn: self.$controllerSkinEnabled)
                                .onChange(of: self.controllerSkinEnabled) { value in
                                    GameplayFeatures.shared.quickSettings.controllerSkinEnabled = value
                                }
                            if self.controllerSkinEnabled {
                                Toggle("Expanded Controller Skin", isOn: self.$expandedControllerSkinEnabled)
                                    .onChange(of: self.expandedControllerSkinEnabled) { value in
                                        GameplayFeatures.shared.quickSettings.expandedControllerSkinEnabled = value
                                    }
                            }
                        }
                        if ControllerSkinFeatures.shared.backgroundBlur.isEnabled {
                            Toggle("Background Blur", isOn: self.$backgroundBlurEnabled)
                                .onChange(of: self.backgroundBlurEnabled) { value in
                                    GameplayFeatures.shared.quickSettings.backgroundBlurEnabled = value
                                }
                            if self.backgroundBlurEnabled {
                                Toggle("Expanded Background Blur", isOn: self.$expandedBackgroundBlurEnabled)
                                    .onChange(of: self.expandedBackgroundBlurEnabled) { value in
                                        GameplayFeatures.shared.quickSettings.expandedBackgroundBlurEnabled = value
                                    }
                            }
                        }
                        if self.systemsWithPalettes.contains(system),
                           GBCFeatures.shared.palettes.isEnabled
                        {
                            Toggle("Color Palettes", isOn: self.$colorPalettesEnabled)
                                .onChange(of: self.colorPalettesEnabled) { value in
                                    GameplayFeatures.shared.quickSettings.colorPalettesEnabled = value
                                }
                        }
                    }.toggleStyle(SwitchToggleStyle(tint: .accentColor))
                } header: {
                    Text("Enabled Sections")
                }.listStyle(.insetGrouped)
            }
        }.onDisappear() {
            NotificationCenter.default.post(name: .unwindFromSettings, object: nil, userInfo: [:])
        }
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
    
    func performMainMenu()
    {
        GameplayFeatures.shared.quickSettings.performMainMenu = true
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

