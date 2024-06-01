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
        return MostPlayedEntry(isPlaceholder: true)
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
    var name: String
    var artwork: UIImage?
    var playTime: Int
    
    init(isPlaceholder: Bool = false) {
        self.date = Date()
        self.name = isPlaceholder ? "GBA Game" : SharedSettings.mostPlayedGameName
        self.artwork = isPlaceholder ? UIImage(named: "GBA") : SharedSettings.mostPlayedGameArtwork
        self.playTime = isPlaceholder ? 925 : SharedSettings.mostPlayedGameTime
    }
}

struct MostPlayedEntryView: View {
    var entry: MostPlayedProvider.Entry

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
                Text("Played for \(entry.playTime.formattedString(for: .minute))")
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

struct MostPlayedWidget: Widget {
    let kind: String = "MostPlayedWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MostPlayedProvider()) { entry in
            MostPlayedEntryView(entry: entry)
                .containerBackground(.gray, for: .widget)
        }
        .configurationDisplayName("Most Played")
        .description("Shows your most played game's play time.")
        .supportedFamilies([.systemSmall])
        .contentMarginsDisabled()
    }
}
