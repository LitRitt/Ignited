//
//  CGColor+rgb.swift
//  Delta
//
//  Created by Chris Rittenhouse on 5/12/23.
//  Copyright © 2023 Lit Development. All rights reserved.
//

import SwiftUI

extension CGColor {

    func rgb() -> UInt32 {
        guard let components = components else { return 0 }
        
        let red = UInt32(components[0] * 255)
        let green = UInt32(components[1] * 255)
        let blue = UInt32(components[2] * 255)
        
        let rgb: UInt32 = (red << 16) + (green << 8) + blue
        
        return rgb
    }
}
