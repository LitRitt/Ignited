//
//  CGRect+ButtonLocations.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 3/1/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import CoreGraphics
import AVFoundation

public extension CGRect
{
    func getSubRect(sections: CGFloat, index: CGFloat, size: CGFloat) -> CGRect
    {
        guard (index - 1) + size <= sections else { return self }
        
        let width = self.width
        let x = self.minX
        
        let sectionHeight = self.height / sections
        
        let height = sectionHeight * size
        let y = self.minY + ((index - 1) * sectionHeight)
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    func getInsetSquare(inset: CGFloat = 5) -> CGRect
    {
        let square = AVMakeRect(aspectRatio: CGSize(width: 1, height: 1), insideRect: self)
        
        return square.insetBy(dx: inset, dy: inset)
    }
    
    func getFourButtons(inset: CGFloat = 5) -> (top: CGRect, bottom: CGRect, left: CGRect, right: CGRect)
    {
        let square = self.getInsetSquare(inset: inset)
        
        let sectionWidth = square.width / 3
        let sectionHeight = square.height / 3
        
        let top = CGRect(x: square.minX + sectionWidth, y: square.minY, width: sectionWidth, height: sectionHeight)
        let bottom = CGRect(x: square.minX + sectionWidth, y: square.maxY - sectionHeight, width: sectionWidth, height: sectionHeight)
        let left = CGRect(x: square.minX, y: square.minY + sectionHeight, width: sectionWidth, height: sectionHeight)
        let right = CGRect(x: square.maxX - sectionWidth, y: square.minY + sectionHeight, width: sectionWidth, height: sectionHeight)
        
        return (top, bottom, left, right)
    }
    
    func getTwoButtons(inset: CGFloat = 5) -> (left: CGRect, right: CGRect)
    {
        let square = self.getInsetSquare(inset: inset)
        
        let sectionWidth = square.width * 0.45
        let sectionHeight = square.height * 0.45
        let midY = square.midY - (sectionHeight / 2)
        
        let left = CGRect(x: square.minX, y: midY + (sectionHeight * 0.3), width: sectionWidth, height: sectionHeight)
        let right = CGRect(x: square.maxX - sectionWidth, y: midY - (sectionHeight * 0.3), width: sectionWidth, height: sectionHeight)
        
        return (left, right)
    }
    
    func getTwoButtonsHorizontal() -> (left: CGRect, right: CGRect)
    {
        var width = self.width * 0.3
        var height = width
        
        if width > self.height * 0.8
        {
            height = self.height * 0.8
            width = height
        }
        
        let midX = self.midX - (width / 2)
        let y = self.minY + ((self.height - height) / 2)
        
        let left = CGRect(x: midX - (self.width / 4), y: y, width: width, height: height)
        let right = CGRect(x: midX + (self.width / 4), y: y, width: width, height: height)
        
        return (left, right)
    }
    
    func getThreeButton() -> (left: CGRect, middle: CGRect, right: CGRect)
    {
        var width = self.width * 0.3
        var height = width
        
        if width > self.height * 0.6
        {
            height = self.height * 0.6
            width = height
        }
        
        let midX = self.midX - (width / 2)
        let y = self.minY + ((self.height - height) / 2)
        
        let left = CGRect(x: midX - (self.width * 0.35), y: y + (self.height * 0.2), width: width, height: height)
        let middle = CGRect(x: midX, y: y, width: width, height: height)
        let right = CGRect(x: midX + (self.width * 0.35), y: y - (self.height * 0.2), width: width, height: height)
        
        return (left, middle, right)
    }
}
