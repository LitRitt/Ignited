//
//  System.swift
//  Ignited
//
//  Created by Riley Testut on 4/30/17.
//  Copyright © 2017 Riley Testut. All rights reserved.
//

import DeltaCore

import SNESDeltaCore
import GBADeltaCore
import GBCDeltaCore
import NESDeltaCore
import N64DeltaCore
import MelonDSDeltaCore
import Systems

// Legacy Cores
import struct DSDeltaCore.DS

enum System: CaseIterable
{
    case genesis
    case ms
    case gg
    case nes
    case snes
    case n64
    case gbc
    case gba
    case ds
    
    static var registeredSystems: [System] {
        let systems = System.allCases.filter { Delta.registeredCores.keys.contains($0.gameType) }
        return systems
    }
    
    static var allCores: [DeltaCoreProtocol] {
        return [GPGX.core, MS.core, GG.core, NES.core, SNES.core, N64.core, GBC.core, GBA.core, mGBA.core, DS.core, MelonDS.core]
    }
}

extension System
{
    var localizedName: String {
        switch self
        {
        case .genesis: return NSLocalizedString("Genesis", comment: "")
        case .ms: return NSLocalizedString("Master System", comment: "")
        case .gg: return NSLocalizedString("Game Gear", comment: "")
        case .nes: return NSLocalizedString("Nintendo", comment: "")
        case .snes: return NSLocalizedString("Super Nintendo", comment: "")
        case .n64: return NSLocalizedString("Nintendo 64", comment: "")
        case .gbc: return NSLocalizedString("Game Boy Color", comment: "")
        case .gba: return NSLocalizedString("Game Boy Advance", comment: "")
        case .ds: return NSLocalizedString("Nintendo DS", comment: "")
        }
    }
    
    var localizedShortName: String {
        switch self
        {
        case .genesis: return NSLocalizedString("GEN", comment: "")
        case .ms: return NSLocalizedString("MS", comment: "")
        case .gg: return NSLocalizedString("GG", comment: "")
        case .nes: return NSLocalizedString("NES", comment: "")
        case .snes: return NSLocalizedString("SNES", comment: "")
        case .n64: return NSLocalizedString("N64", comment: "")
        case .gbc: return NSLocalizedString("GBC", comment: "")
        case .gba: return NSLocalizedString("GBA", comment: "")
        case .ds: return NSLocalizedString("DS", comment: "")
        }
    }
    
    var year: Int {
        switch self
        {
        case .genesis: return 1980 // 1989
        case .ms: return 1981
        case .gg: return 1982
        case .nes: return 1985
        case .snes: return 1990
        case .n64: return 1996
        case .gbc: return 1998
        case .gba: return 2001
        case .ds: return 2004
        }
    }
}

extension System
{
    var deltaCore: DeltaCoreProtocol {
        switch self
        {
        case .genesis: return GPGX.core
        case .ms: return MS.core
        case .gg: return GG.core
        case .nes: return NES.core
        case .snes: return SNES.core
        case .n64: return N64.core
        case .gbc: return GBC.core
        case .gba: return Settings.preferredCore(for: .gba) ?? mGBA.core
        case .ds: return Settings.preferredCore(for: .ds) ?? MelonDS.core
        }
    }
    
    var gameType: DeltaCore.GameType {
        switch self
        {
        case .genesis: return .genesis
        case .ms: return .ms
        case .gg: return .gg
        case .nes: return .nes
        case .snes: return .snes
        case .n64: return .n64
        case .gbc: return .gbc
        case .gba: return .gba
        case .ds: return .ds
        }
    }
    
    init?(gameType: DeltaCore.GameType)
    {
        switch gameType
        {
        case GameType.genesis: self = .genesis
        case GameType.ms: self = .ms
        case GameType.gg: self = .gg
        case GameType.nes: self = .nes
        case GameType.snes: self = .snes
        case GameType.n64: self = .n64
        case GameType.gbc: self = .gbc
        case GameType.gba: self = .gba
        case GameType.ds: self = .ds
        default: return nil
        }
    }
}

extension DeltaCore.GameType
{
    init?(fileExtension: String)
    {
        switch fileExtension.lowercased()
        {
        case "gen", "bin", "md", "smd", "sg": self = .genesis
        case "sms": self = .ms
        case "gg": self = .gg
        case "nes": self = .nes
        case "smc", "sfc", "fig": self = .snes
        case "n64", "z64": self = .n64
        case "gbc", "gb": self = .gbc
        case "gba": self = .gba
        case "ds", "nds": self = .ds
        default: return nil
        }
    }
}
