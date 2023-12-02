//
//  StatusBar.swift
//  Delta
//
//  Created by Chris Rittenhouse on 4/30/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import SwiftUI

import Features

enum StatusBarStyle: Int, CaseIterable, CustomStringConvertible
{
    case light = 1
    case dark = 3
    
    var description: String {
        switch self
        {
        case .light: return "Light Content"
        case .dark: return "Dark Content"
        }
    }
}

extension StatusBarStyle: LocalizedOptionValue
{
    var localizedDescription: Text {
        Text(self.description)
    }
}

struct StatusBarOptions
{
    @Option(name: "Status Bar Style",
            values: StatusBarStyle.allCases)
    var style: StatusBarStyle = .light
}
