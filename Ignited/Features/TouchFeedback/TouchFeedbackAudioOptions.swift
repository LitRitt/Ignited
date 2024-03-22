//
//  TouchFeedbackAudioOptions.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 4/29/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import SwiftUI

import Features

enum TouchFeedbackSound: String, CaseIterable, CustomStringConvertible
{
    case snap = "Snap"
    case tock = "Tock"
    case click = "Click"
    case beep = "Beep"
    
    var description: String
    {
        return self.rawValue
    }
}
    
extension TouchFeedbackSound
{
    var fileName: String
    {
        switch self
        {
        case .snap: return "snap"
        case .tock: return "tock"
        case .click: return "click"
        case .beep: return "beep"
        }
    }
    
    var fileExtension: String
    {
        switch self
        {
        case .tock, .snap, .click, .beep: return "mp3"
        }
    }
}

extension TouchFeedbackSound: LocalizedOptionValue
{
    var localizedDescription: Text {
        Text(self.description)
    }
}

struct TouchFeedbackAudioOptions
{
    @Option(name: "Sound",
            description: "Choose the sound to play.",
            values: TouchFeedbackSound.allCases)
    var sound: TouchFeedbackSound = .snap
    
    @Option(name: "Use Game Volume",
            description: "When enabled, sounds will play at the same volume as gameplay. When disabled, sounds will play at the volume specified below.")
    var useGameVolume: Bool = true
    
    @Option(name: "Volume",
            description: "Change how loud the button sounds should be.",
            range: 0.0...1.0,
            step: 0.05,
            unit: "%",
            isPercentage: true,
            attributes: [.hidden(when: {currentUseGameVolume})])
    var buttonVolume: Double = 1.0
    
    @Option(name: "Restore Defaults",
            description: "Reset all options to their default values.",
            detailView: { _ in
        Button("Restore Defaults") {
            PowerUserOptions.resetFeature(.touchAudio)
        }
        .font(.system(size: 17, weight: .bold, design: .default))
        .foregroundColor(.red)
        .displayInline()
    })
    var reset: Bool = false
}

extension TouchFeedbackAudioOptions
{
    static var currentUseGameVolume: Bool
    {
        return Settings.touchFeedbackFeatures.touchAudio.useGameVolume
    }
}
