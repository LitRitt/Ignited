//
//  ToastNotificationOptions.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 4/25/23.
//  Copyright © 2023 Riley Testut. All rights reserved.
//

import SwiftUI

import Features

struct ToastNotificationOptions
{
    @Option(name: "Duration", description: "Change how long toasts should be shown.", detailView: { value in
        VStack {
            HStack {
                Text("Duration: \(value.wrappedValue, specifier: "%.1f")s")
                Spacer()
            }
            HStack {
                Text("0.5s")
                Slider(value: value, in: 0.5...5.0, step: 0.5)
                Text("5s")
            }
        }.displayInline()
    })
    var duration: Double = 1.5
    
    @Option(name: "Game Restarted",
            description: "Show toasts when restarting the game.")
    var restart: Bool = true
    
    @Option(name: "Game Data Saved",
            description: "Show toasts when performing an in game save.")
    var gameSave: Bool = false
    
    @Option(name: "Saved Save State",
            description: "Show toasts when saving a save state.")
    var stateSave: Bool = true
    
    @Option(name: "Loaded Save State",
            description: "Show toasts when loading a save state.")
    var stateLoad: Bool = true
    
    @Option(name: "Fast Forward Toggled",
            description: "Show toasts when toggling fast forward.")
    var fastForward: Bool = true
    
    @Option(name: "Microphone Toggled",
            description: "Show toasts when toggling the microphone.")
    var microphone: Bool = true
    
    @Option(name: "Status Bar Toggled",
            description: "Show toasts when toggling showing the status bar.")
    var statusBar: Bool = true
    
    @Option(name: "Rotation Lock Toggled",
            description: "Show toasts when toggling rotation lock.")
    var rotationLock: Bool = true
    
    @Option(name: "Screenshot Captured",
            description: "Show toasts when capturing a game screenshot.")
    var screenshot: Bool = true
    
    @Option(name: "Color Palette Changed",
            description: "Show toasts when changing color palettes.")
    var palette: Bool = true
    
    @Option(name: "Background Blur Toggled",
            description: "Show toasts when toggling the background blur.")
    var backgroundBlur: Bool = true
    
    @Option(name: "Alternate Skin Toggled",
            description: "Show toasts when toggling the controller alternate skin.")
    var altSkin: Bool = true
    
    @Option(name: "Debug Mode",
            description: "Show toasts when performing debug actions.")
    var debug: Bool = true
    
    @Option(name: "Restore Defaults",
            description: "Reset all options to their default values.",
            detailView: { _ in
        Button("Restore Defaults") {
            PowerUserOptions.resetFeature(.toastNotifications)
        }
        .font(.system(size: 17, weight: .bold, design: .default))
        .foregroundColor(.red)
        .displayInline()
    })
    var reset: Bool = false
}
