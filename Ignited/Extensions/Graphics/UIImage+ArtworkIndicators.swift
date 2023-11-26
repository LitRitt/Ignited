//
//  UIImage+ArtworkIndicators.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 11/20/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import UIKit

import DeltaCore

extension UIImage
{
    func drawArtworkIndicators(_ accentColor: UIColor, isPaused: Bool = false, isFavorite: Bool = false, borderWidth: CGFloat = 2, boundSize: CGFloat = 100, for gameType: GameType? = nil) -> UIImage
    {
        let renderSize: CGSize
        var forcedRatio: CGFloat = 1
        let originalRatio: CGFloat = self.size.width / self.size.height

        if let gameType = gameType
        {
            forcedRatio = System(gameType: gameType)?.artworkAspectRatio ?? 1
        }
        
        if originalRatio > 1
        { // Horizontal base image
            let ratio =  Settings.libraryFeatures.artwork.forceAspect ? (forcedRatio < 1 ? 1 / forcedRatio : forcedRatio) : originalRatio
            renderSize = CGSize(width: boundSize, height: boundSize / ratio)
        }
        else
        { // Vertical base image
            let ratio = Settings.libraryFeatures.artwork.forceAspect ? (forcedRatio > 1 ? 1 / forcedRatio : forcedRatio) : originalRatio
            renderSize = CGSize(width: boundSize * ratio, height: boundSize)
        }
        
        let pauseImage = UIImage.symbolWithTemplate(name: "pause.fill", pointSize: boundSize * 0.45, accentColor: accentColor)
        let pauseRenderSize: CGSize
        let pauseImageRatio = pauseImage.size.height / pauseImage.size.width
        pauseRenderSize = CGSize(width: boundSize * 0.45 / pauseImageRatio, height: boundSize * 0.45)
        let pauseOrigin = CGPoint(x: (renderSize.width - pauseRenderSize.width) / 2, y: (renderSize.height - pauseRenderSize.height) / 2)
        
        let favoriteImage = UIImage.symbolWithTemplate(name: "star.circle.fill", pointSize: boundSize * 0.2, accentColor: accentColor.adjustBrightness(-0.6))
        let favoriteRenderSize = CGSize(width: boundSize * 0.2, height: boundSize * 0.2)
        let favoriteOrigin = CGPoint(x: boundSize * 0.05, y: boundSize * 0.05)
        let starRenderSize = CGSize(width: favoriteRenderSize.width - (borderWidth * 2), height: favoriteRenderSize.height - (borderWidth * 2))
        let starOrigin = CGPoint(x: favoriteOrigin.x + borderWidth, y: favoriteOrigin.y + borderWidth)
        
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
                ctx.setFillColor(accentColor.cgColor)
                ctx.setShadow(offset: .zero, blur: boundSize * 0.1, color: accentColor.adjustBrightness(-0.5).cgColor)
                ctx.fillEllipse(in: CGRect(origin: favoriteOrigin, size: favoriteRenderSize))
                
                ctx.restoreGState()
                
                favoriteImage.draw(in: CGRect(origin: starOrigin, size: starRenderSize))
            }
        }
    }
}
