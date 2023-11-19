//
//  Bundle+AppIconImage.swift
//  Delta
//
//  Created by Chris Rittenhouse on 6/7/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import UIKit

extension Bundle
{
    static func appIcon(_ altIcon: AppIcon = .normal) -> UIImage? {
        guard let appIcons = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any] else { return nil }
        
        switch altIcon
        {
        case .normal:
            guard let primaryAppIcon = appIcons["CFBundlePrimaryIcon"] as? [String: Any],
                  let appIconFiles = primaryAppIcon["CFBundleIconFiles"] as? [String],
                  let appIcon = appIconFiles.first else { return nil }
            
            return UIImage(named:appIcon)
            
        default:
            guard let alternateAppIcons = appIcons["CFBundleAlternateIcons"] as? [String: Any],
                  let alternateAppIcon = alternateAppIcons[altIcon.assetName] as? [String: Any],
                  let appIconFiles = alternateAppIcon["CFBundleIconFiles"] as? [String],
                  let appIcon = appIconFiles.first else { return nil }
            
            return UIImage(named:appIcon)
        }
    }
    
    static func appIcon(forTheme themeIcon: ThemeColor = .orange) -> UIImage? {
        guard let appIcons = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any] else { return nil }
        
        switch themeIcon
        {
        case .orange:
            guard let primaryAppIcon = appIcons["CFBundlePrimaryIcon"] as? [String: Any],
                  let appIconFiles = primaryAppIcon["CFBundleIconFiles"] as? [String],
                  let appIcon = appIconFiles.first else { return nil }
            
            return UIImage(named:appIcon)
            
        default:
            guard let alternateAppIcons = appIcons["CFBundleAlternateIcons"] as? [String: Any],
                  let alternateAppIcon = alternateAppIcons[themeIcon.assetName] as? [String: Any],
                  let appIconFiles = alternateAppIcon["CFBundleIconFiles"] as? [String],
                  let appIcon = appIconFiles.first else { return nil }
            
            return UIImage(named:appIcon)
        }
    }
}
