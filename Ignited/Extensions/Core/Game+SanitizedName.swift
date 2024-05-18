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
        return self.name.sanitize(with: .parenthesis)
    }
}

extension String
{
    public enum SanitizationStyle
    {
        case parenthesis
        
        var expression: any RegexComponent {
            switch self
            {
            case .parenthesis:
                return Regex {
                    "("
                    OneOrMore(.anyNonNewline)
                    ")"
                }
            }
        }
    }
    
    func sanitize(with style: SanitizationStyle) -> String
    {
        var sanitizedString = self
        
        sanitizedString = sanitizedString.replacing(style.expression, with: "")
        sanitizedString = sanitizedString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return sanitizedString
    }
}
