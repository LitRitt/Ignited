//
//  LoadControllerSkinImageOperation.swift
//  Delta
//
//  Created by Riley Testut on 10/28/16.
//  Copyright © 2016 Riley Testut. All rights reserved.
//

import UIKit

import DeltaCore

import Roxas

extension LoadControllerSkinImageOperation
{
    enum Error: Swift.Error
    {
        case doesNotExist
        case unsupportedTraits
    }
}

class ControllerSkinImageCacheKey: NSObject
{
    let controllerSkin: ControllerSkin
    let traits: DeltaCore.ControllerSkin.Traits
    let size: DeltaCore.ControllerSkin.Size
    
    override var hash: Int {
        return self.controllerSkin.hashValue ^ self.traits.hashValue ^ self.size.hashValue
    }
    
    init(controllerSkin: ControllerSkin, traits: DeltaCore.ControllerSkin.Traits, size: DeltaCore.ControllerSkin.Size)
    {
        self.controllerSkin = controllerSkin
        self.traits = traits
        self.size = size
        
        super.init()
    }
    
    override func isEqual(_ object: Any?) -> Bool
    {
        guard let object = object as? ControllerSkinImageCacheKey else { return false }
        return self.controllerSkin == object.controllerSkin && self.traits == object.traits && self.size == object.size
    }
}

class LoadControllerSkinImageOperation: RSTLoadOperation<UIImage, ControllerSkinImageCacheKey>
{
    let controllerSkin: ControllerSkin
    let traits: DeltaCore.ControllerSkin.Traits
    let size: DeltaCore.ControllerSkin.Size
    
    init(controllerSkin: ControllerSkin, traits: DeltaCore.ControllerSkin.Traits, size: DeltaCore.ControllerSkin.Size)
    {
        self.controllerSkin = controllerSkin
        self.traits = traits
        self.size = size
        
        let cacheKey = ControllerSkinImageCacheKey(controllerSkin: controllerSkin, traits: traits, size: size)
        super.init(cacheKey: cacheKey)
    }
    
    override func loadResult(completion: @escaping (UIImage?, Swift.Error?) -> Void)
    {
        let alt = Settings.advancedFeatures.skinDebug.useAlt
        
        let skinImage: UIImage
        
        if Settings.advancedFeatures.skinDebug.unsupportedSkins
        {
            guard let image = self.controllerSkin.anyImage(for: self.traits, preferredSize: self.size, alt: alt) else {
                completion(nil, Error.doesNotExist)
                return
            }
            
            skinImage = image
        }
        else
        {
            guard let traits = self.controllerSkin.supportedTraits(for: self.traits, alt: alt) else {
                completion(nil, Error.unsupportedTraits)
                return
            }
            
            guard let image = self.controllerSkin.image(for: traits, preferredSize: self.size, alt: alt) else {
                completion(nil, Error.doesNotExist)
                return
            }
            
            skinImage = image
        }
        
        // Force decompression of image
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: 1), true, 1.0)
        skinImage.draw(at: CGPoint.zero)
        UIGraphicsEndImageContext()
        
        completion(skinImage, nil)
    }
}
