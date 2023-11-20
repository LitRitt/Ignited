//
//  UIImage+ArtworkIndicators.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 11/20/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import UIKit

extension UIImage
{
    func drawArtworkIndicators(_ accentColor: UIColor, isPaused: Bool = false, isFavorite: Bool = false, boundSize: CGFloat = 100) -> UIImage
    {
        let renderSize: CGSize
        
        if self.size.width > self.size.height
        { // Horizontal base image
            let ratio = self.size.width / self.size.height
            renderSize = CGSize(width: boundSize, height: boundSize / ratio)
        }
        else
        { // Vertical base image
            let ratio = self.size.height / self.size.width
            renderSize = CGSize(width: boundSize / ratio, height: boundSize)
        }
        
        let pauseImage = UIImage.symbolWithTemplate(name: "pause.fill", pointSize: boundSize * 0.45, accentColor: accentColor)
        let pauseRenderSize: CGSize
        let ratio = pauseImage.size.height / pauseImage.size.width
        pauseRenderSize = CGSize(width: boundSize * 0.45 / ratio, height: boundSize * 0.45)
        let pauseOrigin = CGPoint(x: (renderSize.width - pauseRenderSize.width) / 2, y: (renderSize.height - pauseRenderSize.height) / 2)
        
        let favoriteImage = UIImage.symbolWithTemplate(name: "star.circle.fill", pointSize: boundSize * 0.2, accentColor: accentColor) ?? UIImage()
        let favoriteRenderSize = CGSize(width: boundSize * 0.2, height: boundSize * 0.2)
        let favoriteOrigin = CGPoint(x: boundSize * 0.05, y: boundSize * 0.05)
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale
        let renderer = UIGraphicsImageRenderer(size: renderSize, format: format)
        
        return renderer.image { (context) in
            let ctx = context.cgContext
            
            self.draw(in: CGRect(origin: .zero, size: renderSize))
            
            ctx.saveGState()
            
            if isPaused
            {
                // Artwork Dimming
                ctx.setFillColor(UIColor.black.withAlphaComponent(0.3).cgColor)
                ctx.fill([CGRect(origin: .zero, size: renderSize)])
                
                // Pause Symbol
                ctx.setShadow(offset: .zero, blur: boundSize * 0.3, color: accentColor.adjustBrightness(-0.5).cgColor)
                pauseImage.draw(in: CGRect(origin: pauseOrigin, size: pauseRenderSize))
            }
            
            if isFavorite
            {
                ctx.setFillColor(accentColor.adjustBrightness(-0.5).cgColor)
                ctx.setShadow(offset: .zero, blur: boundSize * 0.1, color: accentColor.adjustBrightness(-0.5).cgColor)
                ctx.fillEllipse(in: CGRect(origin: favoriteOrigin, size: favoriteRenderSize))
                
                ctx.restoreGState()
                
                ctx.setFillColor(accentColor.adjustBrightness(0.1).cgColor)
                favoriteImage.draw(in: CGRect(origin: favoriteOrigin, size: favoriteRenderSize))
            }
        }
    }
}
