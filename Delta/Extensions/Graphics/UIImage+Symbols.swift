//
//  UIImage+Symbols.swift
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
    
    func configureArtwork(_ accentColor: UIColor, isPaused: Bool = false, isFavorite: Bool = false) -> UIImage
    {
        let renderSize: CGSize
        
        if self.size.width > self.size.height
        { // Horizontal base image
            let ratio = self.size.width / self.size.height
            renderSize = CGSize(width: 100, height: 100 / ratio)
        }
        else
        { // Vertical base image
            let ratio = self.size.height / self.size.width
            renderSize = CGSize(width: 100 / ratio, height: 100)
        }
        
        let pauseImage = UIImage.symbolWithTemplate(name: "pause.fill", pointSize: 160, accentColor: accentColor)
        let pauseRenderSize: CGSize
        let ratio = pauseImage.size.height / pauseImage.size.width
        pauseRenderSize = CGSize(width: 45 / ratio, height: 45)
        let pauseOrigin = CGPoint(x: (renderSize.width - pauseRenderSize.width) / 2, y: (renderSize.height - pauseRenderSize.height) / 2)
        
        let favoriteImage = UIImage.symbolWithTemplate(name: "star.circle.fill", pointSize: 80, accentColor: accentColor)
        let favoriteRenderSize: CGSize
        favoriteRenderSize = CGSize(width: 20, height: 20)
        let favoriteOrigin = CGPoint(x: 5, y: 5)
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale
        let renderer = UIGraphicsImageRenderer(size: renderSize, format: format)
        
        return renderer.image { (context) in
            self.draw(in: CGRect(origin: .zero, size: renderSize))
            
            if isPaused
            {
                // Artwork Dimming
                context.cgContext.setFillColor(UIColor.black.withAlphaComponent(0.5).cgColor)
                context.cgContext.fill([CGRect(origin: .zero, size: renderSize)])
                
                // Pause Symbol
                context.cgContext.setShadow(offset: CGSize(width: 0, height: 0), blur: 30, color: accentColor.adjustBrightness(-0.2).cgColor)
                pauseImage.draw(in: CGRect(origin: pauseOrigin, size: pauseRenderSize))
                
                if isFavorite
                {
                    context.cgContext.setShadow(offset: CGSize(width: 0, height: 0), blur: 10, color: UIColor.black.withAlphaComponent(0.7).cgColor)
                    favoriteImage.draw(in: CGRect(origin: favoriteOrigin, size: favoriteRenderSize))
                }
            }
            else if isFavorite
            {
                context.cgContext.setShadow(offset: CGSize(width: 0, height: 0), blur: 10, color: UIColor.black.withAlphaComponent(0.7).cgColor)
                favoriteImage.draw(in: CGRect(origin: favoriteOrigin, size: favoriteRenderSize))
            }
        }
    }
}
