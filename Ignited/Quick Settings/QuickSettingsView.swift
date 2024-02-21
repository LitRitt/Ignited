//
//  QuickSettingsView.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 5/14/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import SwiftUI

import Features

struct QuickSettingsView: View
{
    private var system: String
    private let systemsWithPalettes = [System.gbc.gameType.rawValue]
    
    @State private var fastForwardSpeed: Double
    @State private var fastForwardMode: FastForwardMode = Settings.gameplayFeatures.fastForward.mode
    
    @State private var gameAudioVolume: Double = Settings.gameplayFeatures.gameAudio.volume
    
    @State private var softwareSkinStyle: SoftwareSkinStyle = Settings.controllerFeatures.softwareSkin.style
    @State private var softwareSkinColor: SoftwareSkinColor = Settings.controllerFeatures.softwareSkin.color
    @State private var softwareSkinCustomColor: Color = Settings.controllerFeatures.softwareSkin.customColor
    @State private var softwareSkinCustomColorSecondary: Color = Settings.controllerFeatures.softwareSkin.customColorSecondary
    @State private var softwareSkinShadowOpacity: Double = Settings.controllerFeatures.softwareSkin.shadowOpacity
    
    @State private var controllerSkinOpacity: Double = Settings.controllerFeatures.skin.opacity
    @State private var controllerSkinColorMode: SkinBackgroundColor = Settings.controllerFeatures.skin.colorMode
    @State private var controllerSkinBackgroundColor: Color = Settings.controllerFeatures.skin.backgroundColor
    @State private var controllerSkinAirPlayKeepScreen: Bool = Settings.controllerFeatures.airPlayKeepScreen.isEnabled
    
    @State private var backgroundBlurStrength: Double = Settings.controllerFeatures.backgroundBlur.strength
    @State private var backgroundBlurTintIntensity: Double = Settings.controllerFeatures.backgroundBlur.tintIntensity
    
    @State private var gameboyPalette: GameboyPalette = Settings.gbFeatures.palettes.palette
    @State private var gameboySpritePalette1: GameboyPalette = Settings.gbFeatures.palettes.spritePalette1
    @State private var gameboySpritePalette2: GameboyPalette = Settings.gbFeatures.palettes.spritePalette2
    
    @State private var quickActionsEnabled: Bool = Settings.gameplayFeatures.quickSettings.quickActionsEnabled
    @State private var fastForwardEnabled: Bool = Settings.gameplayFeatures.quickSettings.fastForwardEnabled
    @State private var expandedFastForwardEnabled: Bool = Settings.gameplayFeatures.quickSettings.expandedFastForwardEnabled
    @State private var gameAudioEnabled: Bool = Settings.gameplayFeatures.quickSettings.gameAudioEnabled
    @State private var expandedGameAudioEnabled: Bool = Settings.gameplayFeatures.quickSettings.expandedGameAudioEnabled
    @State private var softwareSkinEnabled: Bool = Settings.gameplayFeatures.quickSettings.softwareSkinEnabled
    @State private var controllerSkinEnabled: Bool = Settings.gameplayFeatures.quickSettings.controllerSkinEnabled
    @State private var backgroundBlurEnabled: Bool = Settings.gameplayFeatures.quickSettings.backgroundBlurEnabled
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
                
                if self.fastForwardEnabled
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
                                Picker("Fast Forward Mode", selection: self.$fastForwardMode) {
                                    ForEach(FastForwardMode.allCases, id: \.self) { value in
                                        value.localizedDescription
                                    }
                                }.pickerStyle(.menu)
                                    .onChange(of: self.fastForwardMode) { value in
                                        Settings.gameplayFeatures.fastForward.mode = value
                                    }
                            }
                        }.buttonStyle(.borderless)
                    } header: {
                        Text("Fast Forward")
                    }.listStyle(.insetGrouped)
                }
                
                if self.gameAudioEnabled
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
                                Toggle("Mute During Fast Forward", isOn: Settings.gameplayFeatures.gameAudio.$fastForwardMutes.valueBinding)
                                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                            }
                        }
                    } header: {
                        Text("Game Audio")
                    }.listStyle(.insetGrouped)
                }
                
                if self.softwareSkinEnabled && Settings.controllerFeatures.softwareSkin.isEnabled
                {
                    Section() {
                        VStack {
                            Picker("Style", selection: self.$softwareSkinStyle) {
                                ForEach(SoftwareSkinStyle.allCases, id: \.self) { value in
                                    value.localizedDescription
                                }
                            }.pickerStyle(.menu)
                                .onChange(of: self.softwareSkinStyle) { value in
                                    Settings.controllerFeatures.softwareSkin.style = value
                                }
                            Picker("Color", selection: self.$softwareSkinColor) {
                                ForEach(SoftwareSkinColor.allCases, id: \.self) { value in
                                    value.localizedDescription
                                }
                            }.pickerStyle(.menu)
                                .onChange(of: self.softwareSkinColor) { value in
                                    Settings.controllerFeatures.softwareSkin.color = value
                                }
                            ColorPicker("Custom Color", selection: self.$softwareSkinCustomColor, supportsOpacity: false)
                                .onChange(of: self.softwareSkinCustomColor) { value in
                                    Settings.controllerFeatures.softwareSkin.customColor = value
                                }
                            ColorPicker("Custom Secondary Color", selection: self.$softwareSkinCustomColorSecondary, supportsOpacity: false)
                                .onChange(of: self.softwareSkinCustomColorSecondary) { value in
                                    Settings.controllerFeatures.softwareSkin.customColorSecondary = value
                                }
                            Toggle("Shadows", isOn: Settings.controllerFeatures.softwareSkin.$shadows.valueBinding)
                                .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                            HStack {
                                Text("Shadow Opacity: \(self.softwareSkinShadowOpacity * 100, specifier: "%.f")%")
                                Spacer()
                                Button("Reset") {
                                    self.softwareSkinShadowOpacity = 0.7
                                    Settings.controllerFeatures.softwareSkin.shadowOpacity = self.softwareSkinShadowOpacity
                                }.buttonStyle(.borderless)
                            }
                            Slider(value: self.$softwareSkinShadowOpacity, in: 0.0...1.0, step: 0.05)
                                .onChange(of: self.softwareSkinShadowOpacity) { value in
                                    Settings.controllerFeatures.softwareSkin.shadowOpacity = value
                                }
                            Toggle("Translucent", isOn: Settings.controllerFeatures.softwareSkin.$translucentInputs.valueBinding)
                                .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                            Toggle("Fullscreen Landscape", isOn: Settings.controllerFeatures.softwareSkin.$fullscreenLandscape.valueBinding)
                                .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                        }
                    } header: {
                        Text("Software Skin")
                    }.listStyle(.insetGrouped)
                }
                
                if self.controllerSkinEnabled
                {
                    Section() {
                        VStack {
                            HStack {
                                Text("Controller Skin Opacity: \(self.controllerSkinOpacity * 100, specifier: "%.f")%")
                                Spacer()
                                Button("Reset") {
                                    self.controllerSkinOpacity = 0.7
                                    Settings.controllerFeatures.skin.opacity = self.controllerSkinOpacity
                                }.buttonStyle(.borderless)
                            }
                            Slider(value: self.$controllerSkinOpacity, in: 0.0...1.0, step: 0.05)
                                .onChange(of: self.controllerSkinOpacity) { value in
                                    Settings.controllerFeatures.skin.opacity = value
                                }
                            Picker("Background Color", selection: self.$controllerSkinColorMode) {
                                ForEach(Settings.proFeaturesEnabled ? SkinBackgroundColor.allCases : [.none, .theme], id: \.self) { value in
                                    value.localizedDescription
                                }
                            }.pickerStyle(.menu)
                                .onChange(of: self.controllerSkinColorMode) { value in
                                    Settings.controllerFeatures.skin.colorMode = value
                                }
                            if Settings.proFeaturesEnabled {
                                ColorPicker("Custom Background Color", selection: self.$controllerSkinBackgroundColor, supportsOpacity: false)
                                    .onChange(of: self.controllerSkinBackgroundColor) { value in
                                        Settings.controllerFeatures.skin.backgroundColor = value
                                    }
                            }
                            Toggle("Show Screen During AirPlay", isOn: self.$controllerSkinAirPlayKeepScreen)
                                .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                                .onChange(of: self.controllerSkinAirPlayKeepScreen) { value in
                                    Settings.controllerFeatures.airPlayKeepScreen.isEnabled = value
                                }
                            Toggle("Show Skin With Controller", isOn: Settings.controllerFeatures.skin.$alwaysShow.valueBinding)
                                .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                            }
                    } header: {
                        Text("Controller Skin")
                    }.listStyle(.insetGrouped)
                }
                
                if self.backgroundBlurEnabled && Settings.controllerFeatures.backgroundBlur.isEnabled
                {
                    Section() {
                        VStack {
                            if Settings.proFeaturesEnabled {
                                HStack {
                                    Text("Blur Strength: \(self.backgroundBlurStrength * 100, specifier: "%.f")%")
                                    Spacer()
                                    Button("Reset") {
                                        self.backgroundBlurStrength = 1.0
                                        Settings.controllerFeatures.backgroundBlur.strength = self.backgroundBlurStrength
                                    }.buttonStyle(.borderless)
                                }
                                Slider(value: self.$backgroundBlurStrength, in: 0.5...2.0, step: 0.1)
                                    .onChange(of: self.backgroundBlurStrength) { value in
                                        Settings.controllerFeatures.backgroundBlur.strength = value
                                    }
                                HStack {
                                    Text("Tint Intensity: \(self.backgroundBlurTintIntensity * 100, specifier: "%.f")%")
                                    Spacer()
                                    Button("Reset") {
                                        self.backgroundBlurTintIntensity = 0.1
                                        Settings.controllerFeatures.backgroundBlur.tintIntensity = self.backgroundBlurTintIntensity
                                    }.buttonStyle(.borderless)
                                }
                                Slider(value: self.$backgroundBlurTintIntensity, in: -0.5...0.5, step: 0.05)
                                    .onChange(of: self.backgroundBlurTintIntensity) { value in
                                        Settings.controllerFeatures.backgroundBlur.tintIntensity = value
                                    }
                            }
                            Toggle("Show During AirPlay", isOn: Settings.controllerFeatures.backgroundBlur.$showDuringAirPlay.valueBinding)
                                .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                            Toggle("Maintain Aspect Ratio", isOn: Settings.controllerFeatures.backgroundBlur.$maintainAspect.valueBinding)
                                .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                        }
                    } header: {
                        Text("Background Blur")
                    }.listStyle(.insetGrouped)
                }
                
                if self.colorPalettesEnabled,
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
                                ForEach(GameboyPalette.allCases.filter { !$0.pro || Settings.proFeaturesEnabled }, id: \.self) { value in
                                    value.localizedDescription
                                }
                            }
                            .onChange(of: self.gameboyPalette) { value in
                                    Settings.gbFeatures.palettes.palette = value
                                }
                        }
                    } header: {
                        Text("Main Color Palette")
                    }.listStyle(.insetGrouped)
                        
                    if Settings.gbFeatures.palettes.multiPalette
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
                                    ForEach(GameboyPalette.allCases.filter { !$0.pro || Settings.proFeaturesEnabled }, id: \.self) { value in
                                        value.localizedDescription
                                    }
                                }
                                .onChange(of: self.gameboySpritePalette1) { value in
                                        Settings.gbFeatures.palettes.spritePalette1 = value
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
                                    ForEach(GameboyPalette.allCases.filter { !$0.pro || Settings.proFeaturesEnabled }, id: \.self) { value in
                                        value.localizedDescription
                                    }
                                }
                                .onChange(of: self.gameboySpritePalette2) { value in
                                    Settings.gbFeatures.palettes.spritePalette2 = value
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
                        if Settings.controllerFeatures.softwareSkin.isEnabled {
                            Toggle("Software Skin", isOn: self.$softwareSkinEnabled)
                                .onChange(of: self.softwareSkinEnabled) { value in
                                    Settings.gameplayFeatures.quickSettings.softwareSkinEnabled = value
                                }
                        }
                        Toggle("Controller Skin", isOn: self.$controllerSkinEnabled)
                            .onChange(of: self.controllerSkinEnabled) { value in
                                Settings.gameplayFeatures.quickSettings.controllerSkinEnabled = value
                            }
                        if Settings.controllerFeatures.backgroundBlur.isEnabled {
                            Toggle("Background Blur", isOn: self.$backgroundBlurEnabled)
                                .onChange(of: self.backgroundBlurEnabled) { value in
                                    Settings.gameplayFeatures.quickSettings.backgroundBlurEnabled = value
                                }
                        }
                        if self.systemsWithPalettes.contains(system)
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

extension QuickSettingsView
{
    static func makeViewController(system system: String, speed speed: Double) -> UIHostingController<some View>
    {
        let view = QuickSettingsView(system: system, fastForwardSpeed: speed)
        
        let hostingController = UIHostingController(rootView: view)
        
        return hostingController
    }
}

