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
    private var gameViewController: GameViewController
    private var system: String
    private let systemsWithPalettes = [System.gbc.gameType.rawValue]
    
    @State private var fastForwardSpeed: Double
    @State private var fastForwardMode: FastForwardMode = Settings.gameplayFeatures.fastForward.mode
    
    @State private var gameAudioVolume: Double = Settings.gameplayFeatures.gameAudio.volume
    
    @State private var standardSkinStyle: StandardSkinStyle = Settings.standardSkinFeatures.styleAndColor.style
    @State private var standardSkinColor: StandardSkinColor = Settings.standardSkinFeatures.styleAndColor.color
    @State private var standardSkinCustomColor: Color = Settings.standardSkinFeatures.styleAndColor.customColor
    @State private var standardSkinCustomColorSecondary: Color = Settings.standardSkinFeatures.styleAndColor.customColorSecondary
    @State private var standardSkinShadowOpacity: Double = Settings.standardSkinFeatures.styleAndColor.shadowOpacity
    @State private var standardSkinDSTopScreenSize: Double = Settings.standardSkinFeatures.gameScreen.dsTopScreenSize
    @State private var standardSkinSafeArea: Double = Settings.standardSkinFeatures.gameScreen.unsafeArea
    @State private var standardSkinExtendedEdges: Double = Settings.standardSkinFeatures.inputsAndLayout.extendedEdges
    @State private var standardSkinDirectionalInputType: StandardSkinDirectionalInputType = Settings.standardSkinFeatures.inputsAndLayout.directionalInputType
    @State private var standardSkinABXYLayout: StandardSkinABXYLayout = Settings.standardSkinFeatures.inputsAndLayout.abxyLayout
    @State private var standardSkinN64FaceLayout: StandardSkinN64FaceLayout = Settings.standardSkinFeatures.inputsAndLayout.n64FaceLayout
    @State private var standardSkinN64ShoulderLayout: StandardSkinN64ShoulderLayout = Settings.standardSkinFeatures.inputsAndLayout.n64ShoulderLayout
    @State private var standardSkinGenesisFaceLayout: StandardSkinGenesisFaceLayout = Settings.standardSkinFeatures.inputsAndLayout.genesisFaceLayout
    @State private var standardSkinCustomButton1: ActionInput = Settings.standardSkinFeatures.inputsAndLayout.customButton1
    @State private var standardSkinCustomButton2: ActionInput = Settings.standardSkinFeatures.inputsAndLayout.customButton2
    
    @State private var backgroundBlurStyle: UIBlurEffect.Style = Settings.controllerFeatures.backgroundBlur.style
    @State private var backgroundBlurTintColor: BackgroundBlurTintColor = Settings.controllerFeatures.backgroundBlur.tintColor
    @State private var backgroundBlurTintCustomColor: Color = Settings.controllerFeatures.backgroundBlur.customColor
    @State private var backgroundBlurTintOpacity: Double = Settings.controllerFeatures.backgroundBlur.tintOpacity
    
    @State private var controllerSkinOpacity: Double = Settings.controllerFeatures.skin.opacity
    @State private var controllerSkinColorMode: SkinBackgroundColor = Settings.controllerFeatures.skin.colorMode
    @State private var controllerSkinBackgroundColor: Color = Settings.controllerFeatures.skin.backgroundColor
    
    @State private var gameboyPalette: GameboyPalette = Settings.gbFeatures.palettes.palette
    @State private var gameboySpritePalette1: GameboyPalette = Settings.gbFeatures.palettes.spritePalette1
    @State private var gameboySpritePalette2: GameboyPalette = Settings.gbFeatures.palettes.spritePalette2
    
    @State private var quickActionsEnabled: Bool = Settings.gameplayFeatures.quickSettings.quickActionsEnabled
    @State private var fastForwardEnabled: Bool = Settings.gameplayFeatures.quickSettings.fastForwardEnabled
    @State private var expandedFastForwardEnabled: Bool = Settings.gameplayFeatures.quickSettings.expandedFastForwardEnabled
    @State private var gameAudioEnabled: Bool = Settings.gameplayFeatures.quickSettings.gameAudioEnabled
    @State private var expandedGameAudioEnabled: Bool = Settings.gameplayFeatures.quickSettings.expandedGameAudioEnabled
    @State private var standardSkinEnabled: Bool = Settings.gameplayFeatures.quickSettings.standardSkinEnabled
    @State private var controllerSkinEnabled: Bool = Settings.gameplayFeatures.quickSettings.controllerSkinEnabled
    @State private var backgroundBlurEnabled: Bool = Settings.gameplayFeatures.quickSettings.backgroundBlurEnabled
    @State private var colorPalettesEnabled: Bool = Settings.gameplayFeatures.quickSettings.colorPalettesEnabled
    
    var body: some View {
        VStack {
            HStack {
                Button("Main Menu") {
                    self.gameViewController.performMainMenuAction()
                }.font(.system(size: 18, weight: .bold, design: .default))
                    .foregroundColor(.red)
                Spacer()
                Button("Pause Menu") {
                    self.gameViewController.performPauseAction()
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
                                        self.gameViewController.performScreenshotAction()
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
                                        self.gameViewController.performQuickSaveAction()
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
                                        self.gameViewController.performQuickLoadAction()
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
                
                if self.standardSkinEnabled
                {
                    Section() {
                        VStack {
                            Picker("Style", selection: self.$standardSkinStyle) {
                                ForEach(StandardSkinStyle.allCases, id: \.self) { value in
                                    value.localizedDescription
                                }
                            }.pickerStyle(.menu)
                                .onChange(of: self.standardSkinStyle) { value in
                                    Settings.standardSkinFeatures.styleAndColor.style = value
                                }
                            Picker("Color", selection: self.$standardSkinColor) {
                                ForEach(StandardSkinColor.allCases, id: \.self) { value in
                                    value.localizedDescription
                                }
                            }.pickerStyle(.menu)
                                .onChange(of: self.standardSkinColor) { value in
                                    Settings.standardSkinFeatures.styleAndColor.color = value
                                }
                            ColorPicker("Custom Color", selection: self.$standardSkinCustomColor, supportsOpacity: false)
                                .onChange(of: self.standardSkinCustomColor) { value in
                                    Settings.standardSkinFeatures.styleAndColor.customColor = value
                                }
                            ColorPicker("Custom Secondary Color", selection: self.$standardSkinCustomColorSecondary, supportsOpacity: false)
                                .onChange(of: self.standardSkinCustomColorSecondary) { value in
                                    Settings.standardSkinFeatures.styleAndColor.customColorSecondary = value
                                }
                            if self.system != System.n64.gameType.rawValue
                            {
                                Picker("Custom Button 1", selection: self.$standardSkinCustomButton1) {
                                    ForEach([ActionInput.fastForward, ActionInput.quickSave, ActionInput.quickLoad, ActionInput.screenshot, ActionInput.restart], id: \.self) { value in
                                        value.localizedDescription
                                    }
                                }.pickerStyle(.menu)
                                    .onChange(of: self.standardSkinCustomButton1) { value in
                                        Settings.standardSkinFeatures.inputsAndLayout.customButton1 = value
                                    }
                                Picker("Custom Button 2", selection: self.$standardSkinCustomButton2) {
                                    ForEach([ActionInput.fastForward, ActionInput.quickSave, ActionInput.quickLoad, ActionInput.screenshot, ActionInput.restart], id: \.self) { value in
                                        value.localizedDescription
                                    }
                                }.pickerStyle(.menu)
                                    .onChange(of: self.standardSkinCustomButton2) { value in
                                        Settings.standardSkinFeatures.inputsAndLayout.customButton2 = value
                                    }
                                Toggle("DS Screen Swap", isOn: Settings.standardSkinFeatures.inputsAndLayout.$dsScreenSwap.valueBinding)
                                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                                Picker("Directional Input", selection: self.$standardSkinDirectionalInputType) {
                                    ForEach(StandardSkinDirectionalInputType.allCases, id: \.self) { value in
                                        value.localizedDescription
                                    }
                                }.pickerStyle(.menu)
                                    .onChange(of: self.standardSkinDirectionalInputType) { value in
                                        Settings.standardSkinFeatures.inputsAndLayout.directionalInputType = value
                                    }
                            }
                            if self.system != System.n64.gameType.rawValue,
                               self.system != System.genesis.gameType.rawValue,
                               self.system != System.ms.gameType.rawValue,
                               self.system != System.gg.gameType.rawValue
                            {
                                Picker("A,B,X,Y Layout", selection: self.$standardSkinABXYLayout) {
                                    ForEach(StandardSkinABXYLayout.allCases, id: \.self) { value in
                                        value.localizedDescription
                                    }
                                }.pickerStyle(.menu)
                                    .onChange(of: self.standardSkinABXYLayout) { value in
                                        Settings.standardSkinFeatures.inputsAndLayout.abxyLayout = value
                                    }
                            }
                            if self.system == System.n64.gameType.rawValue
                            {
                                Picker("N64 Face Layout", selection: self.$standardSkinN64FaceLayout) {
                                    ForEach(StandardSkinN64FaceLayout.allCases, id: \.self) { value in
                                        value.localizedDescription
                                    }
                                }.pickerStyle(.menu)
                                    .onChange(of: self.standardSkinN64FaceLayout) { value in
                                        Settings.standardSkinFeatures.inputsAndLayout.n64FaceLayout = value
                                    }
                                Picker("N64 Shoulder Layout", selection: self.$standardSkinN64ShoulderLayout) {
                                    ForEach(StandardSkinN64ShoulderLayout.allCases, id: \.self) { value in
                                        value.localizedDescription
                                    }
                                }.pickerStyle(.menu)
                                    .onChange(of: self.standardSkinN64ShoulderLayout) { value in
                                        Settings.standardSkinFeatures.inputsAndLayout.n64ShoulderLayout = value
                                    }
                            }
                            if self.system == System.genesis.gameType.rawValue
                            {
                                Picker("Genesis Face Layout", selection: self.$standardSkinGenesisFaceLayout) {
                                    ForEach(StandardSkinGenesisFaceLayout.allCases, id: \.self) { value in
                                        value.localizedDescription
                                    }
                                }.pickerStyle(.menu)
                                    .onChange(of: self.standardSkinGenesisFaceLayout) { value in
                                        Settings.standardSkinFeatures.inputsAndLayout.genesisFaceLayout = value
                                    }
                            }
                            Toggle("Translucent", isOn: Settings.standardSkinFeatures.styleAndColor.$translucentInputs.valueBinding)
                                .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                            Toggle("Fullscreen Landscape", isOn: Settings.standardSkinFeatures.gameScreen.$fullscreenLandscape.valueBinding)
                                .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                            Toggle("Shadows", isOn: Settings.standardSkinFeatures.styleAndColor.$shadows.valueBinding)
                                .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                            HStack {
                                Text("Shadow Opacity: \(self.standardSkinShadowOpacity * 100, specifier: "%.f")%")
                                Spacer()
                                Button("Reset") {
                                    self.standardSkinShadowOpacity = 0.5
                                    Settings.standardSkinFeatures.styleAndColor.shadowOpacity = self.standardSkinShadowOpacity
                                }.buttonStyle(.borderless)
                            }
                            Slider(value: self.$standardSkinShadowOpacity, in: 0.0...1.0, step: 0.05)
                                .onChange(of: self.standardSkinShadowOpacity) { value in
                                    Settings.standardSkinFeatures.styleAndColor.shadowOpacity = value
                                }
                            if self.system == System.ds.gameType.rawValue
                            {
                                HStack {
                                    Text("DS Top Screen Size: \(self.standardSkinDSTopScreenSize * 100, specifier: "%.f")%")
                                    Spacer()
                                    Button("Reset") {
                                        self.standardSkinDSTopScreenSize = 0.5
                                        Settings.standardSkinFeatures.gameScreen.dsTopScreenSize = self.standardSkinDSTopScreenSize
                                    }.buttonStyle(.borderless)
                                }
                                Slider(value: self.$standardSkinDSTopScreenSize, in: 0.2...0.8, step: 0.05)
                                    .onChange(of: self.standardSkinDSTopScreenSize) { value in
                                        Settings.standardSkinFeatures.gameScreen.dsTopScreenSize = value
                                    }
                            }
                            HStack {
                                Text("Extended Edges: \(self.standardSkinExtendedEdges, specifier: "%.f")pt")
                                Spacer()
                                Button("Reset") {
                                    self.standardSkinExtendedEdges = 10
                                    Settings.standardSkinFeatures.inputsAndLayout.extendedEdges = self.standardSkinExtendedEdges
                                }.buttonStyle(.borderless)
                            }
                            Slider(value: self.$standardSkinExtendedEdges, in: 0...20, step: 1)
                                .onChange(of: self.standardSkinExtendedEdges) { value in
                                    Settings.standardSkinFeatures.inputsAndLayout.extendedEdges = value
                                }
                            HStack {
                                Text("Notch/Island Safe Area: \(self.standardSkinSafeArea, specifier: "%.f")pt")
                                Spacer()
                                Button("Reset") {
                                    self.standardSkinSafeArea = 40
                                    Settings.standardSkinFeatures.gameScreen.unsafeArea = self.standardSkinSafeArea
                                }.buttonStyle(.borderless)
                            }
                            Slider(value: self.$standardSkinSafeArea, in: 0...60, step: 1)
                                .onChange(of: self.standardSkinSafeArea) { value in
                                    Settings.standardSkinFeatures.gameScreen.unsafeArea = value
                                }
                        }
                    } header: {
                        Text("Standard Skin")
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
                                Picker("Blur Style", selection: self.$backgroundBlurStyle) {
                                    ForEach(UIBlurEffect.Style.allCases, id: \.self) { value in
                                        value.localizedDescription
                                    }
                                }.pickerStyle(.menu)
                                    .onChange(of: self.backgroundBlurStyle) { value in
                                        Settings.controllerFeatures.backgroundBlur.style = value
                                    }
                            }
                            Picker("Tint Color", selection: self.$backgroundBlurTintColor) {
                                ForEach(Settings.proFeaturesEnabled ? BackgroundBlurTintColor.allCases : [.none, .theme], id: \.self) { value in
                                    value.localizedDescription
                                }
                            }.pickerStyle(.menu)
                                .onChange(of: self.backgroundBlurTintColor) { value in
                                    Settings.controllerFeatures.backgroundBlur.tintColor = value
                                }
                            if Settings.proFeaturesEnabled {
                                ColorPicker("Custom Tint Color", selection: self.$backgroundBlurTintCustomColor, supportsOpacity: false)
                                    .onChange(of: self.backgroundBlurTintCustomColor) { value in
                                        Settings.controllerFeatures.backgroundBlur.customColor = value
                                    }
                            }
                            HStack {
                                Text("Tint Opacity: \(self.backgroundBlurTintOpacity * 100, specifier: "%.f")%")
                                Spacer()
                                Button("Reset") {
                                    self.backgroundBlurTintOpacity = 0.5
                                    Settings.controllerFeatures.backgroundBlur.tintOpacity = self.backgroundBlurTintOpacity
                                }.buttonStyle(.borderless)
                            }
                            Slider(value: self.$backgroundBlurTintOpacity, in: 0.2...0.8, step: 0.05)
                                .onChange(of: self.backgroundBlurTintOpacity) { value in
                                    Settings.controllerFeatures.backgroundBlur.tintOpacity = value
                                }
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
                        Toggle("Standard Skin", isOn: self.$standardSkinEnabled)
                            .onChange(of: self.standardSkinEnabled) { value in
                                Settings.gameplayFeatures.quickSettings.standardSkinEnabled = value
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
}

extension QuickSettingsView
{
    static func makeViewController(gameViewController: GameViewController, system: String, speed: Double) -> UIHostingController<some View>
    {
        let view = QuickSettingsView(gameViewController: gameViewController, system: system, fastForwardSpeed: speed)
        
        let hostingController = UIHostingController(rootView: view)
        
        return hostingController
    }
}

