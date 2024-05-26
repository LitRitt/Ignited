//
//  Int+MinutesToFormattedString.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 5/26/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import Foundation

extension Int {
    func formattedString(for timeUnit: TimeUnit) -> String {
        func getFormattedTime(_ length: Double, with timeUnit: TimeUnit) -> String {
            if length == 1 {
                return "\(Int(length)) \(timeUnit.rawValue)"
            } else {
                return "\(Int(length)) \(timeUnit.rawValue)s"
            }
        }
        
        var minutes = Double(self)
        if timeUnit == .hour || timeUnit == .day {
            minutes *= 60
        }
        if timeUnit == .day {
            minutes *= 24
        }
        
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

extension UInt32 {
    func formattedString(for timeUnit: TimeUnit) -> String {
        func getFormattedTime(_ length: Double, with timeUnit: TimeUnit) -> String {
            if length == 1 {
                return "\(Int(length)) \(timeUnit.rawValue)"
            } else {
                return "\(Int(length)) \(timeUnit.rawValue)s"
            }
        }
        
        var minutes = Double(self)
        if timeUnit == .hour || timeUnit == .day {
            minutes *= 60
        }
        if timeUnit == .day {
            minutes *= 24
        }
        
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
