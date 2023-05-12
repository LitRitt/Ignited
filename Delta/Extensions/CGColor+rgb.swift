//
//  CGColor+RGB.swift
//  Delta
//
//  Created by Chris Rittenhouse on 5/12/23.
//  Copyright © 2023 Lit Development. All rights reserved.
//

import SwiftUI

extension CGColor
{
    func rgb() -> UInt32
    {
        guard let colorSpace = CGColorSpace(name: CGColorSpace.displayP3),
              let cgColor = self.converted(to: colorSpace, intent: .defaultIntent, options: nil),
              let rgba = cgColor.components,
                  rgba.count == 4 else { return 0 }
        
        let red = UInt32(rgba[0] * 255)
        let green = UInt32(rgba[1] * 255)
        let blue = UInt32(rgba[2] * 255)
        
        let rgb: UInt32 = (red << 16) + (green << 8) + blue
        
        return rgb
    }
}
