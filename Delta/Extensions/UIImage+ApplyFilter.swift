//
//  UIImage+ApplyFilter.swift
//  Delta
//
//  Created by Chris Rittenhouse on 3/23/23.
//  Copyright © 2023 Lit Development. All rights reserved.
//

import UIKit

extension UIImage
{
    func applyFilter(filter: CIFilter) -> UIImage
    {
        let convertedImage = CIImage(image: self) as! CIImage
        
        filter.setValue(convertedImage, forKey: kCIInputImageKey)
        
        let filteredImage = filter.outputImage as! CIImage
        
        let extent = convertedImage.extent
        
        UIGraphicsBeginImageContextWithOptions(extent.size, false, 0)
        UIImage(ciImage: filteredImage).draw(in: CGRect(x: 0, y: 0, width: extent.width, height: extent.height))
        let drawnImage = UIGraphicsGetImageFromCurrentImageContext() as! UIImage
        UIGraphicsEndImageContext()
        
        return drawnImage
    }
}
