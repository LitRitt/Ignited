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
    // Lit Pro
    case normal = "Default"
    case connect = "Connect"
    case tribute = "Tribute"
    case cartridge = "Cartridge"
    case neon = "Neon"
    case plumberRed = "Red Plumber"
    case plumberGreen = "Green Plumber"
    case goomba = "Stomp Bait"
    case smash = "Super Ignited Bros"
    case kirby = "Puffball"
    case sealing = "Sword That Seals"
    case sealingAlt = "Sword That Seals Alt"
    case igniting = "Sword That Ignites"
    case ignitingAlt = "Sword That Ignites Alt"
    // Basic
    case simple = "Simple"
    case glass = "Glass"
    case ablaze = "Ablaze"
    case classic = "Classic"
    // Kong Pro
    case ball = "Firé Ball"
    case kong = "Barrel of Kong"
    case kongFlame = "Barrel of Flame"
    case black = "Space Black"
    case silver = "Silver"
    case gold = "Gold"
    // Scott Pro
    case sword = "Master Sword"
    case shield = "Hylian Shield"
    case mario = "Many Marios"
    
    var description: String {
        return self.rawValue
    }
    
    var id: String {
        return self.rawValue
    }
    
    var author: AppIconAuthor {
        switch self
        {
        case .normal, .connect, .tribute, .cartridge, .neon, .sealing, .igniting, .sealingAlt, .ignitingAlt, .smash, .kirby, .plumberRed, .plumberGreen, .goomba:
            return .litritt
            
        case .classic, .ball, .kong, .kongFlame, .black, .silver, .gold:
            return .kongo
            
        case .simple, .glass:
            return .epicpal
            
        case .ablaze:
            return .salty
            
        case .sword, .shield, .mario:
            return .scott
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
        case .plumberRed: return "IconPlumberRed"
        case .plumberGreen: return "IconPlumberGreen"
        case .goomba: return "IconGoomba"
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
        case .kong: return "IconBarrelKong"
        case .kongFlame: return "IconBarrelFlame"
        case .black: return "IconBlack"
        case .silver: return "IconSilver"
        case .gold: return "IconGold"
        case .shield: return "IconShield"
        case .sword: return "IconSword"
        case .mario: return "IconMario"
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
        case _ where !self.pro: return .basic
        case _ where self.author == .litritt: return .litPro
        case _ where self.author == .kongo: return .kongPro
        case _ where self.author == .scott: return .scottPro
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

enum AppIconCategory: String, CaseIterable, Identifiable
{
    case basic = "Basic Icons"
    case litPro = "Lit Pro Icons"
    case kongPro = "Kongo Pro Icons"
    case scottPro = "Scott Pro Icons"
    
    var id: String {
        return self.rawValue
    }
}

enum AppIconAuthor: String, CaseIterable, Identifiable
{
    case litritt = "LitRitt"
    case kongo = "Kongolabongo"
    case scott = "Scott the Rizzler"
    case epicpal = "epicpal"
    case salty = "Salty"
    
    var id: String {
        return self.rawValue
    }
}

struct AppIconOptions
{
    @Option(name: "Alternate App Icon",
            description: "Choose from alternate app icons created by the community.",
            detailView: { value in
        List {
            ForEach(AppIconCategory.allCases) { category in
                appIconSection(category, currentIcon: value)
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
    static func appIconSection(_ category: AppIconCategory, currentIcon: Binding<AppIcon>) -> some View
    {
        Section {
            ForEach(AppIcon.allCases.filter { $0.category == category }) { icon in
                HStack {
                    VStack(alignment: .leading) {
                        if icon == currentIcon.wrappedValue {
                            HStack {
                                Text("✓")
                                icon.localizedDescription
                            }
                            .foregroundColor(.accentColor)
                                .addProLabel(category != .basic)
                        } else {
                            icon.localizedDescription.addProLabel(category != .basic)
                        }
                        Text("by \(icon.author.rawValue)")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    appIconImage(icon.assetName)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if Settings.proFeaturesEnabled || category == .basic {
                        currentIcon.wrappedValue = icon
                    } else {
                        ToastView.show(NSLocalizedString("Ignited Pro is required to use this icon", comment: ""), onEdge: .bottom)
                    }
                }
            }
        } header: {
            appIconSectionHeader(category.rawValue)
        }
    }
    
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
                .foregroundColor(.white)
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
