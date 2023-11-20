//
//  UIImage+SymbolTemplates.swift
//  Delta
//
//  Created by Chris Rittenhouse on 11/10/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import UIKit

extension UIImage
{
    static func symbolWithTemplate(name: String, pointSize: CGFloat = 30, accentColor: UIColor = UIColor.themeColor) -> UIImage?
    {
        return UIImage(systemName: name, withConfiguration: UIImage.SymbolConfiguration(pointSize: pointSize))?.withTintColor(accentColor, renderingMode: .alwaysTemplate)
    }
    
    static func makePlaceholder(size: CGFloat = 100) -> UIImage
    {
        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size), format: format)
        
        return renderer.image { (context) in
            let ctx = context.cgContext
            
            let rect = CGRect(origin: .zero, size: CGSize(width: size, height: size))
            ctx.setFillColor(UIColor.systemBackground.cgColor)
            ctx.fill(rect)
            
            if let image = UIImage.symbolWithTemplate(name: "questionmark", pointSize: size * 0.6, accentColor: UIColor.label)
            {
                let imageWidth = (size * 0.6) * (image.size.width / image.size.height)
                image.draw(in: CGRect(x: (size - imageWidth) / 2, y: size * 0.2, width: imageWidth, height: size * 0.6))
            }
        }
    }
}
