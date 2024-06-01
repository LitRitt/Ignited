//
//  RecentlyPlayedWidget.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 5/21/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import WidgetKit
import SwiftUI
import UIKit

struct RecentlyPlayedProvider: TimelineProvider {
    func placeholder(in context: Context) -> RecentlyPlayedEntry {
        return RecentlyPlayedEntry(isPlaceholder: true)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (RecentlyPlayedEntry) -> Void) {
        completion(RecentlyPlayedEntry())
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<RecentlyPlayedEntry>) -> Void) {
        var entries = [RecentlyPlayedEntry]()
        let currentDate = Date()
        for minuteOffset in 0 ... 30 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: currentDate)!
            let entry = RecentlyPlayedEntry(date: entryDate)
            entries.append(entry)
        }
        completion(Timeline(entries: entries, policy: .atEnd))
    }
}

struct RecentlyPlayedEntry: TimelineEntry {
    var date: Date
    var name: String
    var artwork: UIImage?
    var playedDate: Date
    
    init(date: Date? = nil, isPlaceholder: Bool = false) {
        self.date = date ?? Date()
        self.name = isPlaceholder ? "GBA Game" : SharedSettings.lastPlayedGameName
        self.artwork = isPlaceholder ? UIImage(named: "GBA") : SharedSettings.lastPlayedGameArtwork
        self.playedDate = isPlaceholder ? Date() : SharedSettings.lastPlayedGameDate
    }
}

struct RecentlyPlayedEntryView: View {
    var entry: RecentlyPlayedProvider.Entry

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let artwork = entry.artwork {
                Image(uiImage: artwork)
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
                    .overlay(
                        Image(uiImage: artwork)
                            .resizable()
                            .blur(radius: 20, opaque: true)
                            .mask(
                                LinearGradient(gradient: Gradient(stops: [
                                    Gradient.Stop(color: Color(white: 0, opacity: 0),
                                                  location: 0.6),
                                    Gradient.Stop(color: Color(white: 0, opacity: 0.8),
                                                  location: 0.7),
                                    Gradient.Stop(color: Color(white: 0, opacity: 1),
                                                  location: 0.8)
                                ]), startPoint: .top, endPoint: .bottom)
                            )
                    )
                    .overlay(
                        LinearGradient(gradient: Gradient(stops: [
                            Gradient.Stop(color: Color(white: 0, opacity: 0),
                                          location: 0.5),
                            Gradient.Stop(color: Color(white: 0, opacity: 0.25),
                                          location: 1)
                        ]), startPoint: .top, endPoint: .bottom)
                    )
            }
            VStack(alignment: .leading) {
                Text(entry.name)
                    .bold()
                    .font(.system(size: 13))
                    .foregroundColor(.white)
                Text("Played \(entry.playedDate.howLongAgo(from: entry.date))")
                    .font(.system(size: 11))
                    .foregroundColor(Color(white: 0.7))
            }
            .fontWidth(.condensed)
            .shadow(radius: 2)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .lineLimit(1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
    }
}

struct RecentlyPlayedWidget: Widget {
    let kind: String = "RecentlyPlayedWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: RecentlyPlayedProvider()) { entry in
            RecentlyPlayedEntryView(entry: entry)
                .containerBackground(.gray, for: .widget)
        }
        .configurationDisplayName("Recently Played")
        .description("Shows your most recently played game.")
        .supportedFamilies([.systemSmall])
        .contentMarginsDisabled()
    }
}
