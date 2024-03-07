//
//  StatusBar.swift
//  Delta
//
//  Created by Chris Rittenhouse on 4/30/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import SwiftUI

import Features

enum StatusBarStyle: String, CaseIterable, CustomStringConvertible, LocalizedOptionValue
{
    case auto = "Auto"
    case light = "Light"
    case dark = "Dark"
    case none = "None"
    
    var description: String {
        return self.rawValue
    }
    
    var localizedDescription: Text {
        Text(self.description)
    }
    
    var value: UIStatusBarStyle {
        switch self
        {
        case .auto:
            switch UIScreen.main.traitCollection.userInterfaceStyle
            {
            case .light:
                return .darkContent
            case .dark, .unspecified:
                return .lightContent
            }
            
        case .light: return .lightContent
        case .dark: return .darkContent
        case .none: return .default
        }
    }
}

struct StatusBarOptions
{
    @Option(name: "Status Bar Style",
            description: "Choose the style for the status bar during gameplay.",
            values: StatusBarStyle.allCases)
    var style: StatusBarStyle = .auto
}
