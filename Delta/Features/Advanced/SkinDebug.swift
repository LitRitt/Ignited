//
//  SkinDebug.swift
//  Delta
//
//  Created by Chris Rittenhouse on 5/1/23.
//  Copyright © 2023 Lit Development. All rights reserved.
//

import SwiftUI

import Features

enum SkinDebugDevice: String, CaseIterable, CustomStringConvertible
{
    case standard = "Standard iPhone"
    case edgeToEdge = "EdgeToEdge iPhone"
    case ipad = "Standard iPad"
    case splitView = "SplitView iPad"
    
    var description: String {
        return self.rawValue
    }
}

extension SkinDebugDevice: LocalizedOptionValue
{
    var localizedDescription: Text {
        Text(self.description)
    }
    
    static var nilDescription: String {
        return "Don't Override"
    }
    
    static var localizedNilDescription: Text {
        Text(self.nilDescription)
    }
}

struct SkinDebugOptions
{
    @Option
    var isOn: Bool = false
    
    @Option(name: "Device Override",
            description: "Show a different device's controller skin while debugging. Useful for testing skins on devices you don't have access to.",
            values: SkinDebugDevice.allCases)
    var device: SkinDebugDevice? = nil
}
