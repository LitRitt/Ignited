//
//  Shaders.swift
//  Delta
//
//  Created by Chris Rittenhouse on 5/16/23.
//  Copyright © 2023 Lit Development. All rights reserved.
//

import CoreImage

public class GBCGridFilter: CIFilter
{
    public static let kernel = CIKernel(source: """
kernel vec4 GridFilter(sampler src)
{
    vec2 resolution = samplerSize(src);
    resolution.x /= 160;
    resolution.y /= 144;
    vec4 color = sample(src, samplerCoord(src));
    vec2 uv = destCoord() / resolution;
    vec2 cuv = floor(uv);
    vec2 di = abs(uv.xy - cuv.xy);
    float max_di = max(di.x, di.y);
    bool shade = max_di >= 0.8;
    float d = shade ? (1 - (max_di * 0.5)) : 1.0;
    color.xyz = clamp(color.xyz * d, 0.0, 1.0);
    return color;
}
""")!
    
    @objc public dynamic var inputImage : CIImage?
    
    public override var outputImage : CIImage!
    {
        guard let inputImage = self.inputImage else { return nil }
        
        let arguments = [(inputImage)] as [Any]
        
        let extent = inputImage.extent
        return Self.kernel.apply(extent: extent, roiCallback: {(index, rect) in return rect}, arguments: arguments)
    }
}

public class GBAGridFilter: CIFilter
{
    public static let kernel = CIKernel(source: """
kernel vec4 GridFilter(sampler src)
{
    vec2 resolution = samplerSize(src);
    resolution.x /= 240;
    resolution.y /= 160;
    vec4 color = sample(src, samplerCoord(src));
    vec2 uv = destCoord() / resolution;
    vec2 cuv = floor(uv);
    vec2 di = abs(uv.xy - cuv.xy);
    float max_di = max(di.x, di.y);
    bool shade = max_di >= 0.8;
    float d = shade ? (1 - (max_di * 0.5)) : 1.0;
    color.xyz = clamp(color.xyz * d, 0.0, 1.0);
    return color;
}
""")!
    
    @objc public dynamic var inputImage : CIImage?
    
    public override var outputImage : CIImage!
    {
        guard let inputImage = self.inputImage else { return nil }
        
        let arguments = [(inputImage)] as [Any]
        
        let extent = inputImage.extent
        return Self.kernel.apply(extent: extent, roiCallback: {(index, rect) in return rect}, arguments: arguments)
    }
}

