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
    static func symbolWithTemplate(name: String, size: CGFloat = 30) -> UIImage
    {
        let configuration = SymbolConfiguration(pointSize: size)
        
        guard let symbolImage = UIImage(systemName: name, withConfiguration: configuration),
              let cgImage = symbolImage.cgImage
        else {
            return UIImage()
        }
        
        let image = UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .up).withRenderingMode(.alwaysTemplate)
        
        guard let configuredImage = image.applyingSymbolConfiguration(configuration) else { return image }
        
        return configuredImage
    }
}
