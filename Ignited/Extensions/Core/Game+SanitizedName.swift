//
//  Game+SanitizedName.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 5/18/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import RegexBuilder

import DeltaCore

extension Game
{
    var sanitizedName: String
    {
        var sanitizedGameName = self.name
        
        let regex = Regex {
            "("
            OneOrMore(.anyNonNewline)
            ")"
        }
        
        sanitizedGameName = sanitizedGameName.replacing(regex, with: "")
        sanitizedGameName = sanitizedGameName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return sanitizedGameName
    }
}
