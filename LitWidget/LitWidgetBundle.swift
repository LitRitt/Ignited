//
//  LitWidgetBundle.swift
//  LitWidget
//
//  Created by Chris Rittenhouse on 5/19/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import WidgetKit
import SwiftUI

@main
struct LitWidgetBundle: WidgetBundle {
    var body: some Widget {
        MostPlayedWidget()
        RecentlyPlayedWidget()
        GameCountWidget()
    }
}
