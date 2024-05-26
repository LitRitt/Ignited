//
//  Date+Formatting.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 5/24/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import Foundation

enum TimeUnit: String {
    case minute = "minute"
    case hour = "hour"
    case day = "day"
}

extension Date {
    func howLongAgo(from date: Date) -> String {
        func getFormattedTime(_ length: Double, with timeUnit: TimeUnit) -> String {
            if length == 1 {
                return "\(Int(length)) \(timeUnit.rawValue) ago"
            } else {
                return "\(Int(length)) \(timeUnit.rawValue)s ago"
            }
        }
        
        let distance = abs(self.distance(to: date))
        let minutes = (distance / 60.0).rounded(.up)
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
