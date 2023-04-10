//
//  Bundle+BuildNumber.swift
//  Delta
//
//  Created by Chris Rittenhouse on 4/10/23.
//  Copyright © 2023 Lit Development. All rights reserved.
//

import Foundation

extension Bundle {
    var versionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    var buildNumber: Int? {
        return Int(infoDictionary?["CFBundleVersion"] as! String) ?? 1
    }
}
