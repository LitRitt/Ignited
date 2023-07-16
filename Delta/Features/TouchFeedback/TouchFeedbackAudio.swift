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
    @Option(name: "Sound", description: "Choose the sound to play.", values: TouchFeedbackSound.allCases)
    var sound: TouchFeedbackSound = .tock
    
    @Option(name: "Restore Defaults", description: "Reset all options to their default values.", detailView: { value in
        Toggle(isOn: value) {
            Text("Restore Defaults")
                .font(.system(size: 17, weight: .bold, design: .default))
                .foregroundColor(.red)
        }
        .toggleStyle(SwitchToggleStyle(tint: .red))
        .displayInline()
    })
    var resetTouchAudio: Bool = false
}
