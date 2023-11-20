//
//  Color+FromRGB.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 5/12/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import SwiftUI

extension Color
{
    init(fromRGB rgb: UInt32)
    {
        let red = Double((rgb >> 16) & 0xff) / 255.0
        let green = Double((rgb >> 8) & 0xff) / 255.0
        let blue = Double(rgb & 0xff) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}
