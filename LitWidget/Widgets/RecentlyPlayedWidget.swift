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
        return RecentlyPlayedEntry()
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
    var name: String?
    var artwork: UIImage?
    var playedDate: Date?
    
    init(date: Date? = nil) {
        self.date = date ?? Date()
        self.name = SharedSettings.lastPlayedGameName
        self.artwork = SharedSettings.lastPlayedGameArtwork
        self.playedDate = SharedSettings.lastPlayedGameDate
    }
}

struct RecentlyPlayedEntryView: View {
    var entry: RecentlyPlayedProvider.Entry
    
    @Environment(\.widgetFamily) var family: WidgetFamily
    
    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall:
            RecentlyPlayedEntryViewSmall(entry: entry)
        case .accessoryRectangular:
            RecentlyPlayedEntryViewRectangular(entry: entry)
        case .systemMedium:
            EmptyView()
        case .systemLarge:
            EmptyView()
        case .systemExtraLarge:
            EmptyView()
        case .accessoryCircular:
            EmptyView()
        case .accessoryInline:
            EmptyView()
        @unknown default:
            EmptyView()
        }
    }
}

struct RecentlyPlayedEntryViewSmall: View {
    var entry: RecentlyPlayedProvider.Entry

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let artwork = entry.artwork ?? UIImage(named: "GBA") {
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
                            Gradient.Stop(color: Color(white: 0, opacity: 0.4),
                                          location: 1)
                        ]), startPoint: .top, endPoint: .bottom)
                    )
            }
            VStack(alignment: .leading) {
                Text(entry.name ?? "No Games Played")
                    .bold()
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                if let playedDate = entry.playedDate {
                    Text("Played \(playedDate.howLongAgo(from: entry.date))")
                        .font(.system(size: 12))
                        .foregroundColor(Color(white: 0.9))
                } else {
                    Text("Tap to play!")
                        .font(.system(size: 12))
                        .foregroundColor(Color(white: 0.9))
                }
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

struct RecentlyPlayedEntryViewRectangular: View {
    var entry: RecentlyPlayedProvider.Entry

    var body: some View {
        HStack(alignment: .center) {
            if let artwork = UIImage(named: "Flame") {
                Image(uiImage: artwork)
                    .resizable()
                    .frame(width: 36, height: 50)
            }
            VStack(alignment: .leading) {
                Text(entry.name ?? "No Games Played")
                    .bold()
                    .lineLimit(3)
                if let playedDate = entry.playedDate {
                    Text("Played \(playedDate.howLongAgo(from: entry.date))")
                        .font(.caption)
                } else {
                    Text("Tap to play!")
                        .font(.caption)
                }
            }
        }
        .fontWidth(.condensed)
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
        .supportedFamilies([.systemSmall, .accessoryRectangular])
        .contentMarginsDisabled()
    }
}
