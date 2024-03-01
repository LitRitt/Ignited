//
//  CGSize+RelativeAndAbsolute.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 3/1/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import CoreGraphics
import UIKit

public extension CGSize
{
    func getAbsolute() -> CGSize
    {
        return self.applying(CGAffineTransform(scaleX: UIScreen.main.bounds.width, y: UIScreen.main.bounds.height))
    }
    
    func getRelative() -> CGSize
    {
        return self.applying(CGAffineTransform(scaleX: 1 / UIScreen.main.bounds.width, y: 1 / UIScreen.main.bounds.height))
    }
}
