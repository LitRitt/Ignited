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
    
    @State private var gameAudioVolume: Double = Settings.gameplayFeatures.gameAudio.volume
    
    @State private var controllerSkinOpacity: Double = Settings.controllerSkinFeatures.skinCustomization.opacity
    @State private var controllerSkinBackgroundColor: Color = Settings.controllerSkinFeatures.skinCustomization.backgroundColor
    @State private var controllerSkinAirPlayKeepScreen: Bool = Settings.controllerSkinFeatures.airPlayKeepScreen.isEnabled
    
    @State private var backgroundBlurStrength: Double = Settings.controllerSkinFeatures.backgroundBlur.blurStrength
    @State private var backgroundBlurBrightness: Double = Settings.controllerSkinFeatures.backgroundBlur.blurBrightness
    @State private var backgroundBlurTintIntensity: Double = Settings.controllerSkinFeatures.backgroundBlur.blurTintIntensity
    @State private var backgroundBlurTintEnabled: Bool = Settings.controllerSkinFeatures.backgroundBlur.blurTint
    
    @State private var gameboyPalette: GameboyPalette = Settings.gbcFeatures.palettes.palette
    @State private var gameboySpritePalette1: GameboyPalette = Settings.gbcFeatures.palettes.spritePalette1
    @State private var gameboySpritePalette2: GameboyPalette = Settings.gbcFeatures.palettes.spritePalette2
    
    @State private var quickActionsEnabled: Bool = Settings.gameplayFeatures.quickSettings.quickActionsEnabled
    @State private var fastForwardEnabled: Bool = Settings.gameplayFeatures.quickSettings.fastForwardEnabled
    @State private var expandedFastForwardEnabled: Bool = Settings.gameplayFeatures.quickSettings.expandedFastForwardEnabled
    @State private var gameAudioEnabled: Bool = Settings.gameplayFeatures.quickSettings.gameAudioEnabled
    @State private var expandedGameAudioEnabled: Bool = Settings.gameplayFeatures.quickSettings.expandedGameAudioEnabled
    @State private var controllerSkinEnabled: Bool = Settings.gameplayFeatures.quickSettings.controllerSkinEnabled
    @State private var expandedControllerSkinEnabled: Bool = Settings.gameplayFeatures.quickSettings.expandedControllerSkinEnabled
    @State private var backgroundBlurEnabled: Bool = Settings.gameplayFeatures.quickSettings.backgroundBlurEnabled
    @State private var expandedBackgroundBlurEnabled: Bool = Settings.gameplayFeatures.quickSettings.expandedBackgroundBlurEnabled
    @State private var colorPalettesEnabled: Bool = Settings.gameplayFeatures.quickSettings.colorPalettesEnabled
    
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
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 30))
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
                                        Image(systemName: "tray.and.arrow.down.fill")
                                            .font(.system(size: 30))
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
                                        Image(systemName: "tray.and.arrow.up.fill")
                                            .font(.system(size: 30))
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
                
                if self.fastForwardEnabled && Settings.gameplayFeatures.fastForward.isEnabled
                {
                    Section() {
                        VStack {
                            HStack {
                                Text("Game Speed: \(self.fastForwardSpeed * 100, specifier: "%.f")%")
                                Spacer()
                                Button("Reset") {
                                    self.fastForwardSpeed = 1.0
                                    Settings.gameplayFeatures.quickSettings.fastForwardSpeed = self.fastForwardSpeed
                                }
                            }
                            Slider(value: self.$fastForwardSpeed, in: 0.1...8.0, step: 0.1)
                                .onChange(of: self.fastForwardSpeed) { value in
                                    Settings.gameplayFeatures.quickSettings.fastForwardSpeed = value
                                }
                            
                            if self.expandedFastForwardEnabled
                            {
                                HStack {
                                    Button("50%") {
                                        self.fastForwardSpeed = 0.5
                                        Settings.gameplayFeatures.quickSettings.fastForwardSpeed = self.fastForwardSpeed
                                    }
                                    Spacer()
                                    Button("125%") {
                                        self.fastForwardSpeed = 1.25
                                        Settings.gameplayFeatures.quickSettings.fastForwardSpeed = self.fastForwardSpeed
                                    }
                                    Spacer()
                                    Button("150%") {
                                        self.fastForwardSpeed = 1.5
                                        Settings.gameplayFeatures.quickSettings.fastForwardSpeed = self.fastForwardSpeed
                                    }
                                    Spacer()
                                    Button("200%") {
                                        self.fastForwardSpeed = 2.0
                                        Settings.gameplayFeatures.quickSettings.fastForwardSpeed = self.fastForwardSpeed
                                    }
                                }.padding(.top, 10)
                                HStack {
                                    Button("300%") {
                                        self.fastForwardSpeed = 3.0
                                        Settings.gameplayFeatures.quickSettings.fastForwardSpeed = self.fastForwardSpeed
                                    }
                                    Spacer()
                                    Button("400%") {
                                        self.fastForwardSpeed = 4.0
                                        Settings.gameplayFeatures.quickSettings.fastForwardSpeed = self.fastForwardSpeed
                                    }
                                    Spacer()
                                    Button("800%") {
                                        self.fastForwardSpeed = 8.0
                                        Settings.gameplayFeatures.quickSettings.fastForwardSpeed = self.fastForwardSpeed
                                    }
                                    Spacer()
                                    Button("1600%") {
                                        self.fastForwardSpeed = 16.0
                                        Settings.gameplayFeatures.quickSettings.fastForwardSpeed = self.fastForwardSpeed
                                    }
                                }.padding(.top, 10)
                                Toggle("Toggle Fast Forward", isOn: Settings.gameplayFeatures.fastForward.$toggle.valueBinding)
                                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                            }
                        }.buttonStyle(.borderless)
                    } header: {
                        Text("Fast Forward")
                    }.listStyle(.insetGrouped)
                }
                
                if self.gameAudioEnabled && Settings.gameplayFeatures.gameAudio.isEnabled
                {
                    Section() {
                        VStack {
                            HStack {
                                Text("Game Volume: \(self.gameAudioVolume * 100, specifier: "%.f")%")
                                Spacer()
                                Button("Reset") {
                                    self.gameAudioVolume = 1.0
                                    Settings.gameplayFeatures.gameAudio.volume = self.gameAudioVolume
                                }.buttonStyle(.borderless)
                            }
                            Slider(value: self.$gameAudioVolume, in: 0.0...1.0, step: 0.05)
                                .onChange(of: self.gameAudioVolume) { value in
                                    Settings.gameplayFeatures.gameAudio.volume = value
                                }
                            
                            if self.expandedGameAudioEnabled
                            {
                                Toggle("Respect Silent Mode", isOn: Settings.gameplayFeatures.gameAudio.$respectSilent.valueBinding)
                                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                                Toggle("Play Over Other Media", isOn: Settings.gameplayFeatures.gameAudio.$playOver.valueBinding)
                                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                            }
                        }
                    } header: {
                        Text("Game Audio")
                    }.listStyle(.insetGrouped)
                }
                
                if self.controllerSkinEnabled && Settings.controllerSkinFeatures.skinCustomization.isEnabled
                {
                    Section() {
                        VStack {
                            HStack {
                                Text("Controller Skin Opacity: \(self.controllerSkinOpacity * 100, specifier: "%.f")%")
                                Spacer()
                                Button("Reset") {
                                    self.controllerSkinOpacity = 1.0
                                    Settings.controllerSkinFeatures.skinCustomization.opacity = self.controllerSkinOpacity
                                }.buttonStyle(.borderless)
                            }
                            Slider(value: self.$controllerSkinOpacity, in: 0.0...1.0, step: 0.05)
                                .onChange(of: self.controllerSkinOpacity) { value in
                                    Settings.controllerSkinFeatures.skinCustomization.opacity = value
                                }
                            
                            if self.expandedControllerSkinEnabled
                            {
                                ColorPicker("Background Color", selection: self.$controllerSkinBackgroundColor, supportsOpacity: false)
                                    .onChange(of: self.controllerSkinBackgroundColor) { value in
                                        Settings.controllerSkinFeatures.skinCustomization.backgroundColor = value
                                    }
                                Toggle("Match Theme Color", isOn: Settings.controllerSkinFeatures.skinCustomization.$matchTheme.valueBinding)
                                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                                Toggle("Show Screen During AirPlay", isOn: self.$controllerSkinAirPlayKeepScreen)
                                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                                    .onChange(of: self.controllerSkinAirPlayKeepScreen) { value in
                                        Settings.controllerSkinFeatures.airPlayKeepScreen.isEnabled = value
                                    }
                                Toggle("Show Skin With Controller", isOn: Settings.controllerSkinFeatures.skinCustomization.$alwaysShow.valueBinding)
                                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                            }
                        }
                    } header: {
                        Text("Controller Skin")
                    }.listStyle(.insetGrouped)
                }
                
                if self.backgroundBlurEnabled && Settings.controllerSkinFeatures.backgroundBlur.isEnabled
                {
                    Section() {
                        VStack {
                            HStack {
                                Text("Blur Strength: \(self.backgroundBlurStrength * 100, specifier: "%.f")%")
                                Spacer()
                                Button("Reset") {
                                    self.backgroundBlurStrength = 1.0
                                    Settings.controllerSkinFeatures.backgroundBlur.blurStrength = self.backgroundBlurStrength
                                }.buttonStyle(.borderless)
                            }
                            Slider(value: self.$backgroundBlurStrength, in: 0.5...2.0, step: 0.1)
                                .onChange(of: self.backgroundBlurStrength) { value in
                                    Settings.controllerSkinFeatures.backgroundBlur.blurStrength = value
                                }
                            if self.backgroundBlurTintEnabled {
                                HStack {
                                    Text("Tint Intensity: \(self.backgroundBlurTintIntensity * 100, specifier: "%.f")%")
                                    Spacer()
                                    Button("Reset") {
                                        self.backgroundBlurTintIntensity = 0.1
                                        Settings.controllerSkinFeatures.backgroundBlur.blurTintIntensity = self.backgroundBlurTintIntensity
                                    }.buttonStyle(.borderless)
                                }
                                Slider(value: self.$backgroundBlurTintIntensity, in: 0.05...0.30, step: 0.05)
                                    .onChange(of: self.backgroundBlurTintIntensity) { value in
                                        Settings.controllerSkinFeatures.backgroundBlur.blurTintIntensity = value
                                    }
                            } else {
                                HStack {
                                    Text("Blur Brightness: \(self.backgroundBlurBrightness * 100, specifier: "%.f")%")
                                    Spacer()
                                    Button("Reset") {
                                        self.backgroundBlurBrightness = 0
                                        Settings.controllerSkinFeatures.backgroundBlur.blurBrightness = self.backgroundBlurBrightness
                                    }.buttonStyle(.borderless)
                                }
                                Slider(value: self.$backgroundBlurBrightness, in: -0.5...0.5, step: 0.05)
                                    .onChange(of: self.backgroundBlurBrightness) { value in
                                        Settings.controllerSkinFeatures.backgroundBlur.blurBrightness = value
                                    }
                            }
                            if self.expandedBackgroundBlurEnabled {
                                Toggle("Light/Dark Mode Tint", isOn: self.$backgroundBlurTintEnabled)
                                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                                    .onChange(of: self.backgroundBlurTintEnabled) { value in
                                        Settings.controllerSkinFeatures.backgroundBlur.blurTint = value
                                    }
                                Toggle("Show During AirPlay", isOn: Settings.controllerSkinFeatures.backgroundBlur.$blurAirPlay.valueBinding)
                                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                                Toggle("Maintain Aspect Ratio", isOn: Settings.controllerSkinFeatures.backgroundBlur.$blurAspect.valueBinding)
                                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                                Toggle("Override Skin Setting", isOn: Settings.controllerSkinFeatures.backgroundBlur.$blurOverride.valueBinding)
                                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                                Toggle("Blur Enabled", isOn: Settings.controllerSkinFeatures.backgroundBlur.$blurBackground.valueBinding)
                                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                            }
                        }
                    } header: {
                        Text("Background Blur")
                    }.listStyle(.insetGrouped)
                }
                
                if self.colorPalettesEnabled,
                   Settings.gbcFeatures.palettes.isEnabled,
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
                                    Settings.gbcFeatures.palettes.palette = value
                                }
                        }
                    } header: {
                        Text("Main Color Palette")
                    }.listStyle(.insetGrouped)
                        
                    if Settings.gbcFeatures.palettes.multiPalette
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
                                        Settings.gbcFeatures.palettes.spritePalette1 = value
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
                                    Settings.gbcFeatures.palettes.spritePalette2 = value
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
                                Settings.gameplayFeatures.quickSettings.quickActionsEnabled = value
                            }
                        if Settings.gameplayFeatures.fastForward.isEnabled {
                            Toggle("Fast Forward", isOn: self.$fastForwardEnabled)
                                .onChange(of: self.fastForwardEnabled) { value in
                                    Settings.gameplayFeatures.quickSettings.fastForwardEnabled = value
                                }
                            if self.fastForwardEnabled {
                                Toggle("Expanded Fast Forward", isOn: self.$expandedFastForwardEnabled)
                                    .onChange(of: self.expandedFastForwardEnabled) { value in
                                        Settings.gameplayFeatures.quickSettings.expandedFastForwardEnabled = value
                                    }
                            }
                        }
                        if Settings.gameplayFeatures.gameAudio.isEnabled {
                            Toggle("Game Audio", isOn: self.$gameAudioEnabled)
                                .onChange(of: self.gameAudioEnabled) { value in
                                    Settings.gameplayFeatures.quickSettings.gameAudioEnabled = value
                                }
                            if self.gameAudioEnabled {
                                Toggle("Expanded Game Audio", isOn: self.$expandedGameAudioEnabled)
                                    .onChange(of: self.expandedGameAudioEnabled) { value in
                                        Settings.gameplayFeatures.quickSettings.expandedGameAudioEnabled = value
                                    }
                            }
                        }
                        if Settings.controllerSkinFeatures.skinCustomization.isEnabled {
                            Toggle("Controller Skin", isOn: self.$controllerSkinEnabled)
                                .onChange(of: self.controllerSkinEnabled) { value in
                                    Settings.gameplayFeatures.quickSettings.controllerSkinEnabled = value
                                }
                            if self.controllerSkinEnabled {
                                Toggle("Expanded Controller Skin", isOn: self.$expandedControllerSkinEnabled)
                                    .onChange(of: self.expandedControllerSkinEnabled) { value in
                                        Settings.gameplayFeatures.quickSettings.expandedControllerSkinEnabled = value
                                    }
                            }
                        }
                        if Settings.controllerSkinFeatures.backgroundBlur.isEnabled {
                            Toggle("Background Blur", isOn: self.$backgroundBlurEnabled)
                                .onChange(of: self.backgroundBlurEnabled) { value in
                                    Settings.gameplayFeatures.quickSettings.backgroundBlurEnabled = value
                                }
                            if self.backgroundBlurEnabled {
                                Toggle("Expanded Background Blur", isOn: self.$expandedBackgroundBlurEnabled)
                                    .onChange(of: self.expandedBackgroundBlurEnabled) { value in
                                        Settings.gameplayFeatures.quickSettings.expandedBackgroundBlurEnabled = value
                                    }
                            }
                        }
                        if self.systemsWithPalettes.contains(system),
                           Settings.gbcFeatures.palettes.isEnabled
                        {
                            Toggle("Color Palettes", isOn: self.$colorPalettesEnabled)
                                .onChange(of: self.colorPalettesEnabled) { value in
                                    Settings.gameplayFeatures.quickSettings.colorPalettesEnabled = value
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
        Settings.gameplayFeatures.quickSettings.performQuickSave = true
    }
    
    func performQuickLoad()
    {
        Settings.gameplayFeatures.quickSettings.performQuickLoad = true
    }
    
    func performScreenshot()
    {
        Settings.gameplayFeatures.quickSettings.performScreenshot = true
    }
    
    func performPause()
    {
        Settings.gameplayFeatures.quickSettings.performPause = true
    }
    
    func performMainMenu()
    {
        Settings.gameplayFeatures.quickSettings.performMainMenu = true
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

