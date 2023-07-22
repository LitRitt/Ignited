//
//  AppIcon.swift
//  Delta
//
//  Created by Chris Rittenhouse on 5/2/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import SwiftUI

import Features

enum AppIcon: String, CaseIterable, CustomStringConvertible, Identifiable
{
    case normal = "Default"
    case cartridge = "Cartridge"
    case beta = "Beta"
    case neon = "Neon"
    case pride = "Pride"
    case steel = "Steel"
    case classic = "Classic"
    case simple = "Simple"
    case glass = "Glass"
    case ablaze = "Ablaze"
    
    var description: String {
        return self.rawValue
    }
    
    var id: String {
        return self.rawValue
    }
    
    var author: String {
        switch self
        {
        case .normal, .cartridge, .beta, .neon, .pride, .steel: return "LitRitt"
        case .classic: return "Kongolabongo"
        case .simple, .glass: return "epicpal"
        case .ablaze: return "Salty"
        }
    }
    
    var assetName: String {
        switch self
        {
        case .normal: return "AppIcon"
        case .cartridge: return "IconCartridge"
        case .beta: return "IconBeta"
        case .neon: return "IconNeon"
        case .pride: return "IconPride"
        case .steel: return "IconSteel"
        case .classic: return "IconClassic"
        case .simple: return "IconSimple"
        case .glass: return "IconGlass"
        case .ablaze: return "IconAblaze"
        }
    }
}

extension AppIcon: LocalizedOptionValue
{
    var localizedDescription: Text {
        Text(self.description)
    }
}

struct AppIconOptions
{
    @Option(name: "Match Theme Color",
            description: "Enable to use an app icon that matches theme color setting (does not apply to custom theme colors). Disable to use the default app icon, or one of the alternate icons specified below.")
    var useTheme: Bool = true
    
    @Option(name: "Alternate App Icon",
            description: "Choose from alternate app icons created by the community.",
            detailView: { value in
        List {
            ForEach(AppIcon.allCases) { icon in
                HStack {
                    if icon == value.wrappedValue
                    {
                        Text("✓")
                    }
                    icon.localizedDescription
                    Text("- by \(icon.author)")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                    Spacer()
                    Image(uiImage: Bundle.appIcon(for: icon) ?? UIImage())
                        .cornerRadius(13)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    value.wrappedValue = icon
                }
            }
        }.displayInline()
    })
    var alternateIcon: AppIcon = .normal
    
    @Option(name: "Restore Defaults", description: "Reset all options to their default values.", detailView: { value in
        Toggle(isOn: value) {
            Text("Restore Defaults")
                .font(.system(size: 17, weight: .bold, design: .default))
                .foregroundColor(.red)
        }
        .toggleStyle(SwitchToggleStyle(tint: .red))
        .displayInline()
    })
    var resetAppIcon: Bool = false
}
