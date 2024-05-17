//
//  SwipeGestureOptions.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 5/17/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import SwiftUI

import Features

struct SwipeGestureOptions
{
    @Option(name: "Swipe Right Gesture",
            description: "Choose an action to do when performing a right swipe gesture.",
            values: [ActionInput.fastForward, ActionInput.quickSave, ActionInput.quickLoad, ActionInput.screenshot, ActionInput.statusBar, ActionInput.quickSettings, ActionInput.toggleAltRepresentations])
    var right: ActionInput? = .fastForward
    
    @Option(name: "Swipe Left Gesture",
            description: "Choose an action to do when performing a left swipe gesture.",
            values: [ActionInput.fastForward, ActionInput.quickSave, ActionInput.quickLoad, ActionInput.screenshot, ActionInput.statusBar, ActionInput.quickSettings, ActionInput.toggleAltRepresentations])
    var left: ActionInput? = .screenshot
    
    @Option(name: "Swipe Up Gesture",
            description: "Choose an action to do when performing an up swipe gesture.",
            values: [ActionInput.fastForward, ActionInput.quickSave, ActionInput.quickLoad, ActionInput.screenshot, ActionInput.statusBar, ActionInput.quickSettings, ActionInput.toggleAltRepresentations])
    var up: ActionInput? = .statusBar
    
    @Option(name: "Swipe Down Gesture",
            description: "Choose an action to do when performing a down swipe gesture.",
            values: [ActionInput.fastForward, ActionInput.quickSave, ActionInput.quickLoad, ActionInput.screenshot, ActionInput.statusBar, ActionInput.quickSettings, ActionInput.toggleAltRepresentations])
    var down: ActionInput? = .quickSave
    
    @Option(name: "Restore Defaults",
            description: "Reset all options to their default values.",
            detailView: { _ in
        Button("Restore Defaults") {
            PowerUserOptions.resetFeature(.swipeGestures)
        }
        .font(.system(size: 17, weight: .bold, design: .default))
        .foregroundColor(.red)
        .displayInline()
    })
    var reset: Bool = false
}
