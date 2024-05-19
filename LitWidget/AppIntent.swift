//
//  AppIntent.swift
//  LitWidget
//
//  Created by Chris Rittenhouse on 5/19/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Customize Widget"
    static var description = IntentDescription("Change how the widget looks and behaves.")

    @Parameter(title: "Favorite Emoji", default: "😃")
    var favoriteEmoji: String
}
