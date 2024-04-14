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
    case standard = "Standard"
    case standardDark = "Standard Dark"
    case inverted = "Inverted"
    case invertedDark = "Inverted Dark"
    case classic = "Classic"
    case tribute = "Tribute"
    case neon = "Neon"
    case joystickThemed = "Joystick"
    case joystick = "Lit Joystick"
    case connect = "Connect"
    case cartridge = "Cartridge"
    case smash = "Super Ignited Bros"
    case plumberRed = "Red Plumber"
    case plumberGreen = "Green Plumber"
    case mushroom = "Mushroom"
    case mushroomSuper = "Super Mushroom"
    case mushroom1Up = "1-Up Mushroom"
    case mushroomPoison = "Poison Mushroom"
    case mushroomMega = "Mega Mushroom"
    case goomba = "Stomp Bait"
    case pikachu = "Sparky"
    case pokeballCapture = "Capture Ball"
    case pokeball = "Poké Ball"
    case pokeballGreat = "Great Ball"
    case pokeballUltra = "Ultra Ball"
    case pokeballMaster = "Master Ball"
    case kirby = "Puffball"
    case sealing = "Sword That Seals"
    case sealingAlt = "Sword That Seals Alt"
    case igniting = "Sword That Ignites"
    case ignitingAlt = "Sword That Ignites Alt"
    // Basic
    case simple = "Simple"
    case glass = "Glass"
    case ablaze = "Ablaze"
    // Kong Pro
    case ball = "Firé Ball"
    case kong = "Barrel of Kong"
    case kongFlame = "Barrel of Flame"
    case black = "Space Black"
    case silver = "Silver"
    case gold = "Gold"
    
    var description: String {
        return self.rawValue
    }
    
    var id: String {
        return self.rawValue
    }
    
    var author: AppIconAuthor {
        switch self
        {
        case .normal, .standard, .standardDark, .inverted, .invertedDark, .connect, .tribute, .cartridge, .neon, .sealing, .igniting, .sealingAlt, .ignitingAlt, .smash, .kirby, .plumberRed, .plumberGreen, .goomba, .pikachu, .mushroom, .mushroomSuper, .mushroom1Up, .mushroomPoison, .mushroomMega, .pokeball, .pokeballCapture, .pokeballGreat, .pokeballUltra, .pokeballMaster, .joystick, .joystickThemed:
            return .litritt
            
        case .classic, .ball, .kong, .kongFlame, .black, .silver, .gold:
            return .kongo
            
        case .simple, .glass:
            return .epicpal
            
        case .ablaze:
            return .salty
        }
    }
    
    var baseAssetName: String {
        switch self
        {
        case .normal: return "IconStandardOrange"
        case .standard: return "IconStandard"
        case .standardDark: return "IconStandardDark"
        case .inverted: return "IconInverted"
        case .invertedDark: return "IconInvertedDark"
        case .connect: return "IconConnect"
        case .tribute: return "IconTribute"
        case .joystick, .joystickThemed: return "IconJoystick"
        case .cartridge: return "IconCartridge"
        case .neon: return "IconNeon"
        case .plumberRed: return "IconPlumberRed"
        case .plumberGreen: return "IconPlumberGreen"
        case .goomba: return "IconGoomba"
        case .mushroom: return "IconMushroom"
        case .mushroomSuper: return "IconSuperMushroom"
        case .mushroom1Up: return "Icon1UpMushroom"
        case .mushroomPoison: return "IconPoisonMushroom"
        case .mushroomMega: return "IconMegaMushroom"
        case .smash: return "IconSmash"
        case .pikachu: return "IconPikachu"
        case .pokeballCapture: return "IconCaptureBall"
        case .pokeball: return "IconPokeBall"
        case .pokeballGreat: return "IconGreatBall"
        case .pokeballUltra: return "IconUltraBall"
        case .pokeballMaster: return "IconMasterBall"
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
        }
    }
    
    var assetName: String {
        if self.themed
        {
            if Settings.userInterfaceFeatures.theme.color != .custom
            {
                return self.baseAssetName + Settings.userInterfaceFeatures.theme.color.description
            }
            else
            {
                return self.baseAssetName + ThemeColor.orange.description
            }
        }
        else
        {
            return self.baseAssetName
        }
    }
    
    var pro: Bool {
        switch self
        {
        case .normal, .tribute, .neon, .simple, .glass, .ablaze: return false
        default: return true
        }
    }
    
    var themed: Bool {
        switch self
        {
        case .standard, .standardDark, .inverted, .invertedDark, .mushroom, .pokeballCapture, .joystickThemed, .classic: return true
        default: return false
        }
    }
    
    var category: AppIconCategory {
        switch self
        {
        case _ where !self.pro: return .basic
        case _ where self.themed: return .themed
        case _ where self.author == .litritt: return .litPro
        case _ where self.author == .kongo: return .kongPro
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
    case themed = "Dynamic Theme Icons"
    case litPro = "Pro Icons"
    case kongPro = "Kongolabongo Icons"
    
    var id: String {
        return self.rawValue
    }
}

enum AppIconAuthor: String, CaseIterable, Identifiable
{
    case litritt = "LitRitt"
    case kongo = "Kongolabongo"
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
                    if PurchaseManager.shared.hasUnlockedPro || category == .basic {
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
