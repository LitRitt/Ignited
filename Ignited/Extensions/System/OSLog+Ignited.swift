//
//  OSLog+Ignited.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 5/18/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import OSLog

extension OSLog.Category
{
    static let database = "Database"
}

extension Logger
{
    static let ignitedSubsystem = "com.litritt.Ignited"

    static let database = Logger(subsystem: ignitedSubsystem, category: OSLog.Category.database)
}

extension OSLogEntryLog.Level
{
    var localizedName: String {
        switch self
        {
        case .undefined: NSLocalizedString("Undefined", comment: "")
        case .debug: NSLocalizedString("Debug", comment: "")
        case .info: NSLocalizedString("Info", comment: "")
        case .notice: NSLocalizedString("Notice", comment: "")
        case .error: NSLocalizedString("Error", comment: "")
        case .fault: NSLocalizedString("Fault", comment: "")
        @unknown default: NSLocalizedString("Unknown", comment: "")
        }
    }
}
