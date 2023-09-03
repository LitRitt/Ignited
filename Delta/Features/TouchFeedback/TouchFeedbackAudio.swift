//
//  TouchFeedbackAudio.swift
//  Delta
//
//  Created by Chris Rittenhouse on 4/29/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import SwiftUI

import Features

enum TouchFeedbackSound: String, CaseIterable, CustomStringConvertible
{
    case tock = "Tock"
    case snap = "Snap"
    case click = "Click"
    case beep = "Beep"
    case button1 = "Button 1"
    
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
        case .tock: return "tock"
        case .snap: return "snap"
        case .click: return "click"
        case .beep: return "beep"
        case .button1: return "button1"
        }
    }
    
    var hasReleaseSound: Bool
    {
        switch self
        {
        case .tock, .snap, .click, .beep: return false
        case .button1: return true
        }
    }
    
    var fileExtension: String
    {
        switch self
        {
        case .tock, .snap, .click, .beep, .button1: return "mp3"
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
    @Option(name: "Sound", description: "Choose the sound to play.", values: TouchFeedbackSound.allCases)
    var sound: TouchFeedbackSound = .button1
    
    @Option(name: "Play on Button Release", description: "Play a sound on button release as well as button press. Some sounds have different press and release sounds and some don't.")
    var playOnRelease: Bool = true
    
    @Option(name: "Use Game Volume", description: "When enabled, sounds will play at the same volume as gameplay. When disabled, sounds will play at the volume specified below.")
    var useGameVolume: Bool = true
    
    @Option(name: "Volume", description: "Change how loud the button sounds should be.", detailView: { value in
        VStack {
            HStack {
                Text("Volume: \(value.wrappedValue * 100, specifier: "%.f")%")
                Spacer()
            }
            HStack {
                Text("0%")
                Slider(value: value, in: 0.0...1.0, step: 0.05)
                Text("100%")
            }
        }.displayInline()
    })
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
    var resetTouchAudio: Bool = false
}
