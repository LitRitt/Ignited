//
//  AppIconOptions.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 5/2/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import SwiftUI

import Features

enum AppIcon: String, CaseIterable, CustomStringConvertible, Identifiable
{
    case normal = "Default"
    case connect = "Connect"
    case tribute = "Tribute"
    case cartridge = "Cartridge"
    case neon = "Neon"
    case smash = "Super Ignited Bros"
    case kirby = "Puffball"
    case sealing = "Sword That Seals"
    case sealingAlt = "Sword That Seals Alt"
    case igniting = "Sword That Ignites"
    case ignitingAlt = "Sword That Ignites Alt"
    case sword = "Master Sword"
    case shield = "Hylian Shield"
    case simple = "Simple"
    case glass = "Glass"
    case ablaze = "Ablaze"
    case classic = "Classic"
    case ball = "Firé Ball"
    case kong = "King's Barrel"
    case black = "Space Black"
    case silver = "Silver"
    case gold = "Gold"
    
    var description: String {
        return self.rawValue
    }
    
    var id: String {
        return self.rawValue
    }
    
    var author: String {
        switch self
        {
        case .normal, .connect, .tribute, .cartridge, .neon, .sealing, .igniting, .sealingAlt, .ignitingAlt, .smash, .kirby: return "LitRitt"
        case .classic, .ball, .kong, .black, .silver, .gold: return "Kongolabongo"
        case .simple, .glass: return "epicpal"
        case .ablaze: return "Salty"
        case .sword, .shield: return "Scott the Rizzler"
        }
    }
    
    var assetName: String {
        switch self
        {
        case .normal: return "IconOrange"
        case .connect: return "IconConnect"
        case .tribute: return "IconTribute"
        case .cartridge: return "IconCartridge"
        case .neon: return "IconNeon"
        case .smash: return "IconSmash"
        case .kirby: return "IconKirby"
        case .sealing: return "IconSealing"
        case .igniting: return "IconIgniting"
        case .sealingAlt: return "IconSealingAlt"
        case .ignitingAlt: return "IconIgnitingAlt"
        case .classic: return "IconClassic"
        case .simple: return "IconSimple"
        case .glass: return "IconGlass"
        case .ablaze: return "IconAblaze"
        case .ball: return "IconBall"
        case .kong: return "IconKong"
        case .black: return "IconBlack"
        case .silver: return "IconSilver"
        case .gold: return "IconGold"
        case .shield: return "IconShield"
        case .sword: return "IconSword"
        }
    }
    
    var pro: Bool {
        switch self
        {
        case .normal, .tribute, .neon, .simple, .glass, .ablaze, .classic: return false
        default: return true
        }
    }
    
    var category: AppIconCategory {
        switch self
        {
        case .connect, .cartridge, .black, .silver, .gold: return .pro
        case .smash, .kirby, .sealing, .igniting, .sealingAlt, .ignitingAlt, .sword, .shield, .ball, .kong: return .game
        default: return .basic
        }
    }
}

extension AppIcon: LocalizedOptionValue
{
    var localizedDescription: Text {
        Text(self.description)
    }
}

extension AppIcon: Equatable
{
    static func == (lhs: AppIcon, rhs: AppIcon) -> Bool
    {
        return lhs.description == rhs.description
    }
}

enum AppIconCategory: String, CaseIterable
{
    case basic
    case pro
    case game
}

struct AppIconOptions
{
    @Option(name: "Alternate App Icon",
            description: "Choose from alternate app icons created by the community.",
            detailView: { value in
        List {
            Section {
                ForEach(AppIcon.allCases.filter { $0.category == .basic }) { icon in
                    HStack {
                        VStack(alignment: .leading) {
                            if icon == value.wrappedValue {
                                HStack {
                                    Text("✓")
                                    icon.localizedDescription
                                }
                                .foregroundColor(.accentColor)
                            } else {
                                icon.localizedDescription
                            }
                            Text("by \(icon.author)")
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        appIconImage(icon.assetName)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        value.wrappedValue = icon
                    }
                }
            } header: {
                appIconSectionHeader("Basic Icons")
            }
            Section {
                ForEach(AppIcon.allCases.filter { $0.category == .game }) { icon in
                    HStack {
                        VStack(alignment: .leading) {
                            if icon == value.wrappedValue {
                                HStack {
                                    Text("✓")
                                    icon.localizedDescription
                                }
                                .foregroundColor(.accentColor)
                                    .addProLabel()
                            } else {
                                icon.localizedDescription.addProLabel()
                            }
                            Text("by \(icon.author)")
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        appIconImage(icon.assetName)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if Settings.proFeaturesEnabled {
                            value.wrappedValue = icon
                        } else {
                            ToastView.show(NSLocalizedString("Ignited Pro is required to use this icon", comment: ""), onEdge: .bottom)
                        }
                    }
                }
            } header: {
                appIconSectionHeader("Game Icons")
            }
            Section {
                ForEach(AppIcon.allCases.filter { $0.category == .pro }) { icon in
                    HStack {
                        VStack(alignment: .leading) {
                            if icon == value.wrappedValue {
                                HStack {
                                    Text("✓")
                                    icon.localizedDescription
                                }
                                .foregroundColor(.accentColor)
                                    .addProLabel()
                            } else {
                                icon.localizedDescription.addProLabel()
                            }
                            Text("by \(icon.author)")
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        appIconImage(icon.assetName)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if Settings.proFeaturesEnabled {
                            value.wrappedValue = icon
                        } else {
                            ToastView.show(NSLocalizedString("Ignited Pro is required to use this icon", comment: ""), onEdge: .bottom)
                        }
                    }
                }
            } header: {
                appIconSectionHeader("Pro Icons")
            }
        }
        .onChange(of: value.wrappedValue) { _ in
            updateAppIcon()
        }
        .displayInline()
    })
    var alternateIcon: AppIcon = .normal
    
    @Option(name: "Restore Defaults",
            description: "Reset all options to their default values.",
            detailView: { _ in
        Button("Restore Defaults") {
            PowerUserOptions.resetFeature(.appIcon)
        }
        .font(.system(size: 17, weight: .bold, design: .default))
        .foregroundColor(.red)
        .displayInline()
    })
    var reset: Bool = false
}

extension AppIconOptions
{
    @ViewBuilder
    static func appIconImage(_ name: String) -> some View
    {
        return Image(uiImage: UIImage(named: name) ?? UIImage())
            .resizable()
            .frame(width: 57, height: 57)
            .cornerRadius(13)
    }
    
    @ViewBuilder
    static func appIconSectionHeader(_ title: String) -> some View
    {
        return ZStack {
            Color.accentColor
                .frame(maxWidth: .infinity, idealHeight: 30, alignment: .center)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            Text(title)
                .font(.system(size: 20, weight: .bold))
        }.padding([.top, .bottom], 10)
    }
    
    static func updateAppIcon()
    {
        let currentIcon = UIApplication.shared.alternateIconName
        let altIcon = Settings.userInterfaceFeatures.appIcon.alternateIcon
        
        switch altIcon
        {
        case .normal: if currentIcon != nil { UIApplication.shared.setAlternateIconName(nil) }
        default: if currentIcon != altIcon.assetName { UIApplication.shared.setAlternateIconName(altIcon.assetName) }
        }
    }
}
