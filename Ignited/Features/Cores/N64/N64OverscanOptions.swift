//
//  N64OverscanOptions.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 1/12/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import SwiftUI

import Features

public enum OverscanInsetEdge: String
{
    case top
    case bottom
    case left
    case right
}

struct N64OverscanOptions
{
    static let maxValue: UInt16 = 50
    
//    // [Identifier: [EdgeInset: Value]]
//    @Option
//    var games: [String: [String: UInt16]] = [:]
//    
//    @Option(name: "View Enabled Games", description: "View Enabled Games", detailView: { _ in
//        List {
//            ForEach(getEnabledGames(), id: \.self) { game in
//                Text(game)
//            }
//            .onDelete(perform: removeGame)
//        }
//    })
//    var viewEnabledGames: String = ""
//    
//    @Option(name: "Reset Overscan Settings",
//            description: "Reverts all overscan settings to 0 for all games.",
//            detailView: { _ in
//        Button("Reset Enabled Games") {
//            PowerUserOptions.resetFeature(.n64Overscan)
//        }
//        .font(.system(size: 17, weight: .bold, design: .default))
//        .foregroundColor(.red)
//        .displayInline()
//    })
//    var reset: Bool = false
}
