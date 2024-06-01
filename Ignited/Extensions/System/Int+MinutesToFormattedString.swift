//
//  Int+MinutesToFormattedString.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 5/26/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import Foundation

extension Int {
    private func formattedString(for timeUnit: TimeUnit) -> String {
        func getFormattedTime(_ length: Double, with timeUnit: TimeUnit) -> String {
            if length == 1 {
                return "\(Int(length)) \(timeUnit.rawValue)"
            } else {
                return "\(Int(length)) \(timeUnit.rawValue)s"
            }
        }
        
        var seconds = Double(self)
        if timeUnit == .minute || timeUnit == .hour || timeUnit == .day {
            seconds *= 60
        }
        if timeUnit == .hour || timeUnit == .day {
            seconds *= 60
        }
        if timeUnit == .day {
            seconds *= 24
        }
        if seconds < 59 {
            return getFormattedTime(seconds, with: .second)
        } else {
            let minutes = (seconds / 60.0).rounded(.up)
            if minutes < 60 {
                return getFormattedTime(minutes, with: .minute)
            } else {
                let hours = (minutes / 60.0).rounded(.down)
                if hours < 24 {
                    return getFormattedTime(hours, with: .hour)
                } else {
                    let days = (hours / 24.0).rounded(.down)
                    return getFormattedTime(days, with: .day)
                }
            }
        }
    }
    
    var secondString: String {
        self.formattedString(for: .second)
    }
}

extension UInt32 {
    var secondString: String {
        Int(self).secondString
    }
}
