//
//  N64GraphicsOptions.swift
//  Delta
//
//  Created by Chris Rittenhouse on 6/11/23.
//  Copyright © 2023 Lit Development. All rights reserved.
//

import SwiftUI

import Features

enum GraphicsAPI: String, CaseIterable, CustomStringConvertible
{
    case openGLES2 = "OpenGL ES 2"
    case openGLES3 = "OpenGL ES 3"
    
    var description: String {
        return self.rawValue
    }
    
    var api: EAGLRenderingAPI {
        switch self
        {
        case .openGLES2: return .openGLES2
        case .openGLES3: return .openGLES3
        }
    }
}

extension GraphicsAPI: LocalizedOptionValue
{
    var localizedDescription: Text {
        Text(self.description)
    }
}

struct N64GraphicsOptions
{
    @Option(name: "Graphics API",
            description: "Changing the graphics API will affect how graphics are rendered. OpenGL ES 2 is the default, and all games should run when using it. OpenGL ES 3 can solve graphical issues like white or black boxes in the HUD of some games, but may cause other games to crash. If unsure, use OpenGL ES 2.",
            values: GraphicsAPI.allCases)
    var graphicsAPI: GraphicsAPI = .openGLES2
}
