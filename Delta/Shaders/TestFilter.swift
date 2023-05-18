//
//  TestFilter.swift
//  Delta
//
//  Created by Chris Rittenhouse on 5/16/23.
//  Copyright © 2023 Lit Development. All rights reserved.
//

import CoreImage

public class GBCFilter: CIFilter
{
    public static let kernel = CIKernel(source: """
kernel vec4 GBCFilter(sampler src)
{
    vec2 resolution = samplerSize(src);
    resolution.x /= 160;
    resolution.y /= 144;
    vec4 color = sample(src, samplerCoord(src));
    vec2 uv = destCoord() / resolution;
    vec2 cuv = floor(uv) + 0.5;
    vec2 di = abs(uv.xy - cuv.xy);
    float d = 1 - ((di.x + di.y) * 0.7);
    color.x = clamp(color.x * d, 0.0, 1.0);
    color.y = clamp(color.y * d, 0.0, 1.0);
    color.z = clamp(color.z * d, 0.0, 1.0);
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

public class GBAFilter: CIFilter
{
    public static let kernel = CIKernel(source: """
kernel vec4 GBCFilter(sampler src)
{
    vec2 resolution = samplerSize(src);
    resolution.x /= 240;
    resolution.y /= 160;
    vec4 color = sample(src, samplerCoord(src));
    vec2 uv = destCoord() / resolution;
    vec2 cuv = floor(uv) + 0.5;
    vec2 di = abs(uv.xy - cuv.xy);
    float d = 1 - ((di.x + di.y) * 0.7);
    color.x = clamp(color.x * d, 0.0, 1.0);
    color.y = clamp(color.y * d, 0.0, 1.0);
    color.z = clamp(color.z * d, 0.0, 1.0);
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

