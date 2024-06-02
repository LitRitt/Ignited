//
//  MostPlayedGameWidget.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 5/26/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import WidgetKit
import SwiftUI
import UIKit

struct MostPlayedProvider: TimelineProvider {
    func placeholder(in context: Context) -> MostPlayedEntry {
        return MostPlayedEntry()
    }
    
    func getSnapshot(in context: Context, completion: @escaping (MostPlayedEntry) -> Void) {
        completion(MostPlayedEntry())
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<MostPlayedEntry>) -> Void) {
        completion(Timeline(entries: [MostPlayedEntry()], policy: .atEnd))
    }
}

struct MostPlayedEntry: TimelineEntry {
    var date: Date
    var name: String?
    var artwork: UIImage?
    var playTime: Int?
    
    init() {
        self.date = Date()
        self.name = SharedSettings.mostPlayedGameName
        self.artwork = SharedSettings.mostPlayedGameArtwork
        self.playTime = SharedSettings.mostPlayedGameTime
    }
}

struct MostPlayedEntryView: View {
    var entry: MostPlayedProvider.Entry
    
    @Environment(\.widgetFamily) var family: WidgetFamily
    
    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall:
            MostPlayedEntryViewSmall(entry: entry)
        case .accessoryRectangular:
            MostPlayedEntryViewRectangular(entry: entry)
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

struct MostPlayedEntryViewSmall: View {
    var entry: MostPlayedProvider.Entry

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
                if let playTime = entry.playTime {
                    Text("Played for \(playTime.secondString)")
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

struct MostPlayedEntryViewRectangular: View {
    var entry: MostPlayedProvider.Entry

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
                if let playTime = entry.playTime {
                    Text("Played for \(playTime.secondString)")
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

struct MostPlayedWidget: Widget {
    let kind: String = "MostPlayedWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MostPlayedProvider()) { entry in
            MostPlayedEntryView(entry: entry)
                .containerBackground(.gray, for: .widget)
        }
        .configurationDisplayName("Most Played")
        .description("Shows your most played game's play time.")
        .supportedFamilies([.systemSmall, .accessoryRectangular])
        .contentMarginsDisabled()
    }
}
