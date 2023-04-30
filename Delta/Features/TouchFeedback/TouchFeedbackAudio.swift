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
}
