//
//  TouchFeedbackAudio.swift
//  Delta
//
//  Created by Chris Rittenhouse on 4/29/23.
//  Copyright © 2023 Lit Development. All rights reserved.
//

import SwiftUI

import Features

enum TouchFeedbackSound: String, CaseIterable, CustomStringConvertible
{
    case snap = "Snap"
    case bit8 = "8-Bit"
    
    var description: String
    {
        return self.rawValue
    }
}

extension TouchFeedbackSound: LocalizedOptionValue
{
    var localizedDescription: Text {
        Text(self.description)
    }
    
    static var localizedNilDescription: Text {
        Text("System Click")
    }
}

struct TouchFeedbackAudioOptions
{
    @Option(name: "Sound", description: "Choose the sound to play.", values: TouchFeedbackSound.allCases)
    var sound: TouchFeedbackSound?
    
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
