//
//  IgnitedCoreProtocol+Delta.swift
//  Ignited
//
//  Created by Riley Testut on 4/30/17.
//  Copyright © 2017 Riley Testut. All rights reserved.
//

import DeltaCore

import NESDeltaCore
import SNESDeltaCore
import GBCDeltaCore
import GBADeltaCore
import N64DeltaCore
import MelonDSDeltaCore

import Systems

// Legacy Cores
import struct DSDeltaCore.DS

@dynamicMemberLookup
struct DeltaCoreMetadata
{
    enum Key: String, CaseIterable, Identifiable
    {
        case name = "Name"
        case developer = "Developer"
        case source = "Source"
        case donate = "Donate"
        
        var id: String {
            return self.rawValue
        }
    }
    
    struct Item
    {
        var value: String
        var url: URL?
    }
    
    var name: Item { self.items[.name]! }
    private let items: [Key: Item]
    
    init?(_ items: [Key: Item])
    {
        guard items.keys.contains(.name) else { return nil }
        self.items = items
    }
    
    subscript(dynamicMember keyPath: KeyPath<Key.Type, Key>) -> Item?
    {
        let key = Key.self[keyPath: keyPath]
        return self[key]
    }
    
    subscript(_ key: Key) -> Item?
    {
        let item = self.items[key]
        return item
    }
    
    var sortedKeys: [Key]?
    {
        var keys = [Key]()
        
        for key in Key.allCases
        {
            if let _ = self.items[key]
            {
                keys.append(key)
            }
        }
        
        return keys.count > 0 ? keys : nil
    }
}

extension DeltaCoreProtocol
{
    var supportedRates: ClosedRange<Double> {
        return 1...self.maximumFastForwardSpeed
    }
    
    private var maximumFastForwardSpeed: Double {
        switch self
        {
        case NES.core, SNES.core, GBC.core: return 4
        case GBA.core: return 3
        case N64.core where UIDevice.current.hasA11ProcessorOrBetter: return 3
        case N64.core where UIDevice.current.hasA9ProcessorOrBetter: return 1.5
        case MelonDS.core where ProcessInfo.processInfo.isJITAvailable: return 3
        case MelonDS.core where UIDevice.current.hasA11ProcessorOrBetter: return 1.5
        case GPGX.core: return 4
        default: return 1
        }
    }
    
    var metadata: DeltaCoreMetadata? {
        switch self
        {
        case DS.core:
            return DeltaCoreMetadata([.name: .init(value: NSLocalizedString("DeSmuME (Legacy)", comment: ""), url: URL(string: "http://desmume.org")),
                                      .developer: .init(value: NSLocalizedString("DeSmuME team", comment: ""), url: URL(string: "https://wiki.desmume.org/index.php?title=DeSmuME:About")),
                                      .source: .init(value: NSLocalizedString("GitHub", comment: ""), url: URL(string: "https://github.com/TASVideos/desmume"))])
            
        case MelonDS.core:
            return DeltaCoreMetadata([.name: .init(value: NSLocalizedString("melonDS", comment: ""), url: URL(string: "http://melonds.kuribo64.net")),
                                      .developer: .init(value: NSLocalizedString("Arisotura", comment: ""), url: URL(string: "https://twitter.com/Arisotura")),
                                      .source: .init(value: NSLocalizedString("GitHub", comment: ""), url: URL(string: "https://github.com/Arisotura/melonDS")),
                                      .donate: .init(value: NSLocalizedString("Patreon", comment: ""), url: URL(string: "https://www.patreon.com/staplebutter"))])
            
        case GBA.core:
            return DeltaCoreMetadata([.name: .init(value: NSLocalizedString("VBA-M (Legacy)", comment: ""), url: URL(string: "https://visualboyadvance.org")),
                                      .source: .init(value: NSLocalizedString("GitHub", comment: ""), url: URL(string: "https://github.com/visualboyadvance-m/visualboyadvance-m"))])
            
        case mGBA.core:
            return DeltaCoreMetadata([.name: .init(value: NSLocalizedString("mGBA", comment: ""), url: URL(string: "https://mgba.io")),
                                      .developer: .init(value: NSLocalizedString("endrift", comment: ""), url: URL(string: "http://endrift.com")),
                                      .source: .init(value: NSLocalizedString("GitHub", comment: ""), url: URL(string: "https://github.com/mgba-emu/mgba")),
                                      .donate: .init(value: NSLocalizedString("Patreon", comment: ""), url: URL(string: "https://www.patreon.com/mgba"))])
            
        case GBC.core:
            return DeltaCoreMetadata([.name: .init(value: NSLocalizedString("Gambatte", comment: ""), url: URL(string: "https://sourceforge.net/projects/gambatte/")),
                                      .developer: .init(value: NSLocalizedString("sinamas", comment: ""), url: URL(string: "https://sourceforge.net/u/sinamas/profile/")),
                                      .source: .init(value: NSLocalizedString("GitHub", comment: ""), url: URL(string: "https://github.com/libretro/gambatte-libretro"))])
            
        case mGBC.core:
            return DeltaCoreMetadata([.name: .init(value: NSLocalizedString("mGBA", comment: ""), url: URL(string: "https://mgba.io")),
                                      .developer: .init(value: NSLocalizedString("endrift", comment: ""), url: URL(string: "http://endrift.com")),
                                      .source: .init(value: NSLocalizedString("GitHub", comment: ""), url: URL(string: "https://github.com/mgba-emu/mgba")),
                                      .donate: .init(value: NSLocalizedString("Patreon", comment: ""), url: URL(string: "https://www.patreon.com/mgba"))])
            
        default: return nil
        }
    }
}
