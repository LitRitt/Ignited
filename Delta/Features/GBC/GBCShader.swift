//
//  GBCShader.swift
//  Delta
//
//  Created by Chris Rittenhouse on 5/19/23.
//  Copyright © 2023 Lit Development. All rights reserved.
//

import SwiftUI
import CoreImage

import Features

enum GBCShader: String, CaseIterable, CustomStringConvertible, Identifiable
{
    case grid = "Grid Overlay"
    
    var description: String {
        return self.rawValue
    }
    
    var id: String {
        return self.rawValue
    }
}

extension GBCShader: LocalizedOptionValue
{
    static var localizedNilDescription: Text {
        Text("None")
    }
    
    var localizedDescription: Text {
        Text(self.description)
    }
}

extension GBCShader
{
    var shader: CIFilter
    {
        switch self
        {
        case .grid: return GBCGridFilter()
        }
    }
}

struct GBCShaderOptions
{
    @Option(name: "Shader",
            description: "Select the shader to use.",
            values: GBCShader.allCases)
    var type: GBCShader?
    
    @Option(name: "Image Scale", description: "Change how much the game image should be upscaled before applying the shader. More upscaling gives a more detailed shader, but can possibly cause lag and excess battery drain.", detailView: { value in
        VStack {
            HStack {
                Text("Image Scale: \(value.wrappedValue)x")
                Spacer()
            }
            HStack {
                Text("3x")
                Slider(value: value, in: 3...5, step: 1)
                Text("5x")
            }
        }.displayInline()
    })
    var scale: Double = 3
}
