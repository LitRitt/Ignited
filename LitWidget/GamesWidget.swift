//
//  GamesWidget.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 5/19/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import WidgetKit
import SwiftUI

struct GameNumberProvider: TimelineProvider {
    private let suiteName: String = "group.com.litritt.ignitedemulator"
    
    private let keyNumberOfGames: String = "LitWidget.totalNumberOfGames"
    
    func placeholder(in context: Context) -> GameNumberEntry {
        return GameNumberEntry(date: Date(), numberOfGames: 925)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (GameNumberEntry) -> Void) {
        let date = Date()
        let numberOfGames: Int
        
        if let userDefaults = UserDefaults(suiteName: self.suiteName),
           let value = userDefaults.value(forKey: self.keyNumberOfGames) as? Int {
            numberOfGames = value
        } else {
            numberOfGames = 0
        }
        
        let entry = GameNumberEntry(date: date, numberOfGames: numberOfGames)

        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<GameNumberEntry>) -> Void) {
        let date = Date()
        let numberOfGames: Int
        
        if let userDefaults = UserDefaults(suiteName: self.suiteName),
           let value = userDefaults.value(forKey: self.keyNumberOfGames) as? Int {
            numberOfGames = value
        } else {
            numberOfGames = 0
        }
        
        let entry = GameNumberEntry(date: date, numberOfGames: numberOfGames)
        let nextUpdateDate = Calendar.current.date(byAdding: .second, value: 30, to: date)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))

        completion(timeline)
    }
}

struct GameNumberEntry: TimelineEntry {
    let date: Date
    let numberOfGames: Int
}

struct GameNumberEntryView : View {
    var entry: GameNumberProvider.Entry

    var body: some View {
        ZStack {
            Image("Flame")
                .resizable()
                .aspectRatio(contentMode: .fit)
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .blur(radius: 10)
            VStack {
                Text("Games")
                    .font(.system(size: 24))
                    .fontWeight(.semibold)
                Text("\(entry.numberOfGames)")
                    .font(.system(size: 48))
                    .fontWeight(.bold)
            }
            .shadow(color: .black.opacity(0.5), radius: 10)
        }
    }
}

struct GameNumberWidget: Widget {
    let kind: String = "GameNumberWidget"
    
    let gradient: Gradient = Gradient(colors: [.widgetBackgroundTop, .widgetBackgroundBottom])

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: GameNumberProvider()) { entry in
            GameNumberEntryView(entry: entry)
                .containerBackground(.linearGradient(gradient, startPoint: UnitPoint(x: 0.5, y: 0), endPoint: UnitPoint(x: 0.5, y: 1)), for: .widget)
        }
        .configurationDisplayName("Games")
        .description("Shows how many games you have installed.")
        .supportedFamilies([.systemSmall])
    }
}
