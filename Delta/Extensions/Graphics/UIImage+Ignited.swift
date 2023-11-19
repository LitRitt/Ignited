//
//  UIImage+Ignited.swift
//  Delta
//
//  Created by Chris Rittenhouse on 11/10/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import UIKit

extension UIImage
{
    static func symbolWithTemplate(name: String, pointSize: CGFloat = 30, accentColor: UIColor = UIColor.themeColor) -> UIImage
    {
        let configuration = SymbolConfiguration(pointSize: pointSize)
        
        guard let symbolImage = UIImage(systemName: name, withConfiguration: configuration),
              let cgImage = symbolImage.cgImage
        else {
            return UIImage()
        }
        
        let image = UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .up).withRenderingMode(.alwaysTemplate)
        
        guard let configuredImage = image.applyingSymbolConfiguration(configuration) else { return image }
        
        return configuredImage.withTintColor(accentColor)
    }
    
    func configureArtwork(_ accentColor: UIColor, isPaused: Bool = false, isFavorite: Bool = false, neverPlayed: Bool = false, boundSize: CGFloat = 100) -> UIImage
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
        
        let neverPlayedRenderSize = CGSize(width: boundSize * 0.16, height: boundSize * 0.16)
        let neverPlayedOrigin = CGPoint(x: renderSize.width - ((boundSize * 0.07) + neverPlayedRenderSize.width), y: boundSize * 0.07)
        
        let favoriteImage = UIImage.symbolWithTemplate(name: "star.circle.fill", pointSize: boundSize * 0.2, accentColor: accentColor)
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
            
            if neverPlayed
            {
                ctx.setFillColor(accentColor.adjustBrightness(-0.4).cgColor)
                ctx.setShadow(offset: CGSize(width: 0, height: 0), blur: boundSize * 0.08, color: accentColor.adjustBrightness(-0.5).cgColor)
                ctx.fillEllipse(in: CGRect(origin: neverPlayedOrigin, size: neverPlayedRenderSize))
                
                ctx.restoreGState()
                ctx.saveGState()
                
                ctx.setFillColor(accentColor.adjustBrightness(0.15).cgColor)
                ctx.fillEllipse(in: CGRect(x: neverPlayedOrigin.x + 2, y: neverPlayedOrigin.y + 2, width: neverPlayedRenderSize.width - 4, height: neverPlayedRenderSize.height - 4))
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
    
    static func makePlaceholder() -> UIImage
    {
        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 100, height: 100), format: format)
        
        return renderer.image { (context) in
            let ctx = context.cgContext
            
            let rect = CGRect(origin: .zero, size: CGSize(width: 100, height: 100))
            ctx.setFillColor(UIColor.systemBackground.cgColor)
            ctx.fill(rect)
            
            if let image = UIImage(systemName: "questionmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 60))?.withTintColor(UIColor.label, renderingMode: .alwaysTemplate)
            {
                let imageWidth = 60 * (image.size.width / image.size.height)
                image.draw(in: CGRect(x: (100 - imageWidth) / 2, y: 20, width: imageWidth, height: 60))
            }
        }
    }
}
