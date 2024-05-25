//
//  GamesWidget.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 5/19/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import WidgetKit
import SwiftUI

struct GameCountProvider: TimelineProvider {
    func placeholder(in context: Context) -> GameCountEntry {
        return GameCountEntry(numberOfGames: 25)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (GameCountEntry) -> Void) {
        completion(GameCountEntry())
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<GameCountEntry>) -> Void) {
        completion(Timeline(entries: [GameCountEntry()], policy: .atEnd))
    }
}

struct GameCountEntry: TimelineEntry {
    let date: Date
    let numberOfGames: Int
    
    init(numberOfGames: Int = SharedSettings.numberOfGames) {
        self.date = Date()
        self.numberOfGames = numberOfGames
    }
}

struct GameCountEntryView: View {
    var entry: GameCountProvider.Entry

    var body: some View {
        ZStack {
            VStack(spacing: -2) {
                Text("\(entry.numberOfGames)")
                    .font(.system(size: fontSize(entry.numberOfGames), weight: .bold, design: .rounded))
                Text(entry.numberOfGames == 1 ? "GAME" : "GAMES")
                    .font(.caption)
            }
            .fixedSize()
            .offset(y: -2)
        }
    }
    
    func fontSize(_ games: Int) -> Double {
        switch games {
        case 0...9: return 32
        case 10...99: return 28
        case 100...999: return 24
        case 1000...9999: return 20
        default: return 16
        }
    }
}

struct GameCountWidget: Widget {
    let kind: String = "GameCountWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: GameCountProvider()) { entry in
            GameCountEntryView(entry: entry)
                .containerBackground(Color.clear, for: .widget)
        }
        .configurationDisplayName("Game Counter")
        .description("Shows how many games you have installed.")
        .supportedFamilies([.accessoryCircular])
    }
}
