//
//  SoftwareControllerSkin.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 2/16/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import UIKit
import CoreGraphics

import DeltaCore

public struct SoftwareControllerSkin
{
    public typealias Skin = DeltaCore.ControllerSkin
    
    public var name: String { "SoftwareControllerSkin" }
    public var identifier: String
    public var gameType: GameType
    
    public var isDebugModeEnabled: Bool { false }
    public var hasAltRepresentations: Bool { false }
    
    public init(gameType: GameType)
    {
        self.identifier = "com.ignited.SoftwareControllerSkin." + gameType.description
        self.gameType = gameType
    }
    
    static public func supportsGameType(_ gameType: GameType) -> Bool
    {
        switch gameType
        {
        case .n64, .ds, .genesis, .ms, .gg: return false
        default: return true
        }
    }
    
    static public var extendedEdges: [String: CGFloat]
    {[
        "top": Settings.controllerFeatures.softwareSkin.extendedEdges,
        "bottom": Settings.controllerFeatures.softwareSkin.extendedEdges,
        "left": Settings.controllerFeatures.softwareSkin.extendedEdges,
        "right": Settings.controllerFeatures.softwareSkin.extendedEdges
    ]}
}

extension SoftwareControllerSkin: ControllerSkinProtocol
{
    public func image(for traits: Skin.Traits, preferredSize: Skin.Size, alt: Bool) -> UIImage?
    {
        let mappingSize = self.aspectRatio(for: traits, alt: alt) ?? CGSize()
        let scaleTransform = CGAffineTransform(scaleX: mappingSize.width, y: mappingSize.height)
        var buttonAreas = [CGRect]()
        
        for buttonArea in self.buttonAreas(for: traits)
        {
            buttonAreas.append(buttonArea.applying(scaleTransform))
        }
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale
        let renderer = UIGraphicsImageRenderer(size: mappingSize, format: format)
        
        return renderer.image { (context) in
            let ctx = context.cgContext
            
            if Settings.controllerFeatures.softwareSkin.shadows
            {
                let opacity = Settings.controllerFeatures.softwareSkin.shadowOpacity
                ctx.setShadow(offset: CGSize(width: 0, height: 3), blur: 9, color: UIColor.black.withAlphaComponent(opacity).cgColor)
            }
            
            for input in self.softwareInputs()
            {
                var imageName: String = ""
                
                switch input
                {
                case .dPad: imageName = "dpad"
                case .a: imageName = "a.circle"
                case .b: imageName = "b.circle"
                case .c: imageName = "c.circle"
                case .x: imageName = "x.circle"
                case .y: imageName = "y.circle"
                case .z: imageName = "z.circle"
                case .l: imageName = "l.square"
                case .r: imageName = "r.square"
                case .cUp: imageName = "arrowtriangle.up.circle"
                case .cDown: imageName = "arrowtriangle.down.circle"
                case .cLeft: imageName = "arrowtriangle.left.circle"
                case .cRight: imageName = "arrowtriangle.right.circle"
                case .start: imageName = "plus.circle"
                case .select: imageName = "minus.circle"
                case .menu: imageName = "ellipsis.circle"
                case .quickSettings: imageName = "gearshape.circle"
                default: break
                }
                
                if Settings.controllerFeatures.softwareSkin.style == .filled
                {
                    imageName += ".fill"
                }
                
                let color: UIColor
                
                switch Settings.controllerFeatures.softwareSkin.color
                {
                case .white: color = UIColor.white
                case .theme: color = UIColor.themeColor
                case .custom: color = UIColor(Settings.controllerFeatures.softwareSkin.customColor)
                }
                
                let image = UIImage.symbolWithTemplate(name: imageName, pointSize: 150, accentColor: color)
                image.draw(in: input.frame(leftButtonArea: buttonAreas[0],
                                           rightButtonArea: buttonAreas[1],
                                           gameType: self.gameType))
            }
            
        }
    }
    
    public func items(for traits: Skin.Traits, alt: Bool) -> [Skin.Item]?
    {
        let mappingSize = self.aspectRatio(for: traits, alt: alt) ?? .zero
        let scaleTransform = CGAffineTransform(scaleX: mappingSize.width, y: mappingSize.height)
        let buttonAreas = self.buttonAreas(for: traits)
        
        return self.softwareInputs().map {
            Skin.Item(id: $0.rawValue,
                      kind: $0.kind,
                      inputs: $0.inputs,
                      frame: $0.frame(leftButtonArea: buttonAreas[0].applying(scaleTransform),
                                      rightButtonArea: buttonAreas[1].applying(scaleTransform),
                                      gameType: self.gameType),
                      edges: $0.edges, mappingSize: mappingSize)
        }
    }
    
    public func screens(for traits: Skin.Traits, alt: Bool) -> [Skin.Screen]?
    {
        let mappingSize = self.aspectRatio(for: traits, alt: alt) ?? CGSize()
        let scaleTransform = CGAffineTransform(scaleX: 1.0 / mappingSize.width, y: 1.0 / mappingSize.height)
        
        let screenSize = self.screenSize()
        let buttonAreas = self.buttonAreas(for: traits)
        
        let screenFrame: CGRect
        
        switch traits.orientation
        {
        case .portrait:
            let screenHeight = mappingSize.width * (screenSize.height / screenSize.width)
            let buttonArea = buttonAreas[0]
            let screenAreaMaxY = buttonArea.minY * mappingSize.height
            let screenY = (screenAreaMaxY - screenHeight) / 2
            screenFrame = CGRect(x: 0, y: screenY, width: mappingSize.width, height: screenHeight)
            
        case .landscape:
            let leftButtonArea = buttonAreas[0]
            let rightButtonArea = buttonAreas[1]
            let screenWidth = (rightButtonArea.minX - leftButtonArea.maxX) * mappingSize.width * 0.95
            let screenHeight = screenWidth * (screenSize.height / screenSize.width)
            let screenY = (mappingSize.height - screenHeight) / 2
            let screenX = (mappingSize.width - screenWidth) / 2
            screenFrame = CGRect(x: screenX, y: screenY, width: screenWidth, height: screenHeight)
        }
        
        var screens = [Skin.Screen]()
        
        screens.append(Skin.Screen(id: "softwareControllerSkin.screen", outputFrame: screenFrame.applying(scaleTransform)))
        // Add second screen for DS
        
        if traits.orientation == .landscape,
           Settings.controllerFeatures.softwareSkin.fullscreenLandscape
        {
            return nil
        }
        
        return screens
    }
    
    public func thumbstick(for item: Skin.Item, traits: Skin.Traits, preferredSize: Skin.Size, alt: Bool) -> (UIImage, CGSize)?
    {
        return nil
    }
    
    public func aspectRatio(for traits: Skin.Traits, alt: Bool) -> CGSize?
    {
        return SoftwareControllerSkin.deviceSize()
    }
    
    public func supports(_ traits: Skin.Traits, alt: Bool) -> Bool
    {
        return true
    }
    
    public func isTranslucent(for traits: Skin.Traits, alt: Bool) -> Bool?
    {
        return Settings.controllerFeatures.softwareSkin.translucentInputs
    }
    
    public func backgroundBlur(for traits: Skin.Traits, alt: Bool) -> Bool?
    {
        return true
    }
    
    public func anyImage(for traits: Skin.Traits, preferredSize: Skin.Size, alt: Bool) -> UIImage?
    {
        return nil
    }
    
    public func contentSize(for traits: Skin.Traits, alt: Bool) -> CGSize?
    {
        return nil
    }
    
    public func previewSize(for traits: Skin.Traits, alt: Bool) -> CGSize?
    {
        return nil
    }
    
    public func anyPreviewSize(for traits: Skin.Traits, alt: Bool) -> CGSize?
    {
        return nil
    }
}

extension SoftwareControllerSkin
{
    private func buttonAreas(for traits: Skin.Traits) -> [CGRect]
    {
        switch (traits.device, traits.displayType, traits.orientation)
        {
        case (.iphone, .standard, .portrait):
            return [
                CGRect(x: 0.03, y: 0.6, width: 0.44, height: 0.4),
                CGRect(x: 0.53, y: 0.6, width: 0.44, height: 0.4)
            ]
        case (.iphone, .edgeToEdge, .portrait):
            return [
                CGRect(x: 0.03, y: 0.55, width: 0.44, height: 0.4),
                CGRect(x: 0.53, y: 0.55, width: 0.44, height: 0.4)
            ]
        case (.iphone, .standard, .landscape):
            return [
                CGRect(x: 0, y: 0.03, width: 0.2, height: 0.94),
                CGRect(x: 0.8, y: 0.03, width: 0.2, height: 0.94)
            ]
        case (.iphone, .edgeToEdge, .landscape):
            return [
                CGRect(x: 0.05, y: 0.03, width: 0.2, height: 0.94),
                CGRect(x: 0.75, y: 0.03, width: 0.2, height: 0.94)
            ]
        default: return []
        }
    }
    
    public static func deviceSize() -> CGSize
    {
        return CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }
    
    private func screenSize() -> CGSize
    {
        guard let deltaCore = Delta.core(for: self.gameType) else {
            return CGSize()
        }
        
        return deltaCore.videoFormat.dimensions
    }
    
    private func softwareInputs() -> [SoftwareInput]
    {
        switch self.gameType
        {
        case .gba: return [.dPad, .a, .b, .l, .r, .start, .select, .menu, .quickSettings]
        case .gbc, .nes: return [.dPad, .a, .b, .start, .select, .menu, .quickSettings]
        case .snes: return [.dPad, .a, .b, .x, .y, .l, .r, .start, .select, .menu, .quickSettings]
        case .ds: return [.dPad, .a, .b, .x, .y, .l, .r, .start, .select, .touchScreen, .menu, .quickSettings]
        case .n64: return [.dPad, .thumbstick, .cUp, .cDown, .cLeft, .cRight, .a, .b, .l, .r, .z, .start, .menu, .quickSettings]
        default: return []
        }
    }
}

public enum SoftwareInput: String, CaseIterable
{
    case dPad
    case a
    case b
    case c
    case x
    case y
    case z
    case l
    case r
    case thumbstick
    case cUp
    case cDown
    case cLeft
    case cRight
    case start
    case select
    case mode
    case touchScreen
    case menu
    case quickSettings
    
    var kind: DeltaCore.ControllerSkin.Item.Kind
    {
        switch self
        {
        case .dPad: return .dPad
        case .thumbstick: return .thumbstick
        case .touchScreen: return .touchScreen
        default: return .button
        }
    }
    
    var inputs: DeltaCore.ControllerSkin.Item.Inputs
    {
        switch self.kind
        {
        case .dPad: return .directional(up: AnyInput(stringValue: "up", intValue: nil, type: .controller(.controllerSkin), isContinuous: false),
                                        down: AnyInput(stringValue: "down", intValue: nil, type: .controller(.controllerSkin), isContinuous: false),
                                        left: AnyInput(stringValue: "left", intValue: nil, type: .controller(.controllerSkin), isContinuous: false),
                                        right: AnyInput(stringValue: "right", intValue: nil, type: .controller(.controllerSkin), isContinuous: false))
            
        case .touchScreen: return .touch(x: AnyInput(stringValue: "touchScreenX", intValue: nil, type: .controller(.controllerSkin), isContinuous: true),
                                         y: AnyInput(stringValue: "touchScreenY", intValue: nil, type: .controller(.controllerSkin), isContinuous: true))
            
//        case .thumbstick: TODO: Thumbstick inputs
            
        default: return .standard([AnyInput(stringValue: self.rawValue, intValue: nil, type: .controller(.controllerSkin))])
        }
    }
    
    func frame(leftButtonArea: CGRect, rightButtonArea: CGRect, gameType: GameType) -> CGRect
    {
        var width: CGFloat = 0
        var height: CGFloat = 0
        var x: CGFloat = 0
        var y: CGFloat = 0
        
        switch self
        {
        case .dPad:
            switch gameType
            {
            case .gba, .gbc, .nes, .snes, .ds:
                width = leftButtonArea.width
                height = width
                x = leftButtonArea.minX
                y = leftButtonArea.midY - (height / 2)
                
            default: break
            }
            
        case .a:
            switch gameType
            {
            case .gba, .gbc, .nes:
                width = rightButtonArea.width * 0.45
                height = width
                x = rightButtonArea.maxX - width
                y = rightButtonArea.midY - (height / 2)
                y -= (height * 0.3)
                
            case .snes, .ds:
                width = rightButtonArea.width * (1/3)
                height = width
                x = rightButtonArea.maxX - width
                y = rightButtonArea.midY - (height / 2)
                
            default: break
            }
            
        case .b:
            switch gameType
            {
            case .gba, .gbc, .nes:
                width = rightButtonArea.width * 0.45
                height = width
                x = rightButtonArea.minX
                y = rightButtonArea.midY - (height / 2)
                y += (height * 0.3)
                
            case .snes, .ds:
                width = rightButtonArea.width * (1/3)
                height = width
                x = rightButtonArea.midX - (width / 2)
                y = rightButtonArea.midY + (height / 2)
                
            default: break
            }
            
        case .x:
            switch gameType
            {
            case .snes, .ds:
                width = rightButtonArea.width * (1/3)
                height = width
                x = rightButtonArea.midX - (width / 2)
                y = rightButtonArea.midY - (height * 3 / 2)
                
            default: break
            }
            
        case .y:
            switch gameType
            {
            case .snes, .ds:
                width = rightButtonArea.width * (1/3)
                height = width
                x = rightButtonArea.minX
                y = rightButtonArea.midY - (height / 2)
                
            default: break
            }
            
        case .l:
            switch gameType
            {
            case .gba, .snes, .ds:
                width = leftButtonArea.width * 0.3
                height = width
                x = leftButtonArea.minX + (leftButtonArea.width * 0.2)
                y = leftButtonArea.minY
                
            default: break
            }
            
        case .r:
            switch gameType
            {
            case .gba, .snes, .ds:
                width = rightButtonArea.width * 0.3
                height = width
                x = rightButtonArea.maxX - (leftButtonArea.width * 0.2) - width
                y = rightButtonArea.minY
                
            default: break
            }
            
        case .select:
            switch gameType
            {
            case .gba, .gbc, .nes, .snes, .ds:
                width = leftButtonArea.width * 0.3
                height = width
                x = leftButtonArea.maxX - width - (leftButtonArea.width * 0.1)
                y = leftButtonArea.maxY - height
                
            default: break
            }
            
        case .start:
            switch gameType
            {
            case .gba, .gbc, .nes, .snes, .ds:
                width = rightButtonArea.width * 0.3
                height = width
                x = rightButtonArea.minX + (rightButtonArea.width * 0.1)
                y = rightButtonArea.maxY - height
                
            default: break
            }
            
        case .quickSettings:
            switch gameType
            {
            case .gba, .gbc, .nes, .snes, .ds:
                width = rightButtonArea.width * 0.3
                height = width
                x = rightButtonArea.maxX - width - (rightButtonArea.width * 0.1)
                y = rightButtonArea.maxY - height
                
            default: break
            }
            
        case .menu:
            switch gameType
            {
            case .gba, .gbc, .nes, .snes, .ds:
                width = leftButtonArea.width * 0.3
                height = width
                x = leftButtonArea.minX + (leftButtonArea.width * 0.1)
                y = leftButtonArea.maxY - height
                
            default: break
            }
            
        default: break
        }
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    var edges: [String: CGFloat]
    {
        switch self
        {
        case .touchScreen: return [:]
        default: return SoftwareControllerSkin.extendedEdges
        }
    }
}
