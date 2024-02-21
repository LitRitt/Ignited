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
        case .n64, .genesis, .ms, .gg: return false
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
            
            for input in self.softwareInputs()
            {
                ctx.saveGState()
                
                if Settings.controllerFeatures.softwareSkin.shadows
                {
                    let opacity = Settings.controllerFeatures.softwareSkin.shadowOpacity
                    ctx.setShadow(offset: CGSize(width: 0, height: 3), blur: 9, color: UIColor.black.withAlphaComponent(opacity).cgColor)
                }
                
                let color = Settings.controllerFeatures.softwareSkin.color.uiColor
                let colorSecondary = Settings.controllerFeatures.softwareSkin.color.uiColorSecondary
                
                switch Settings.controllerFeatures.softwareSkin.style
                {
                case .outline:
                    let image = UIImage.symbolWithTemplate(name: input.assetName, pointSize: 150, accentColor: color)
                    image.draw(in: input.frame(leftButtonArea: buttonAreas[0],
                                               rightButtonArea: buttonAreas[1],
                                               gameType: self.gameType))
                    ctx.restoreGState()
                    
                case .filled:
                    let image = UIImage.symbolWithTemplate(name: input.assetName + ".fill", pointSize: 150, accentColor: color)
                    image.draw(in: input.frame(leftButtonArea: buttonAreas[0],
                                               rightButtonArea: buttonAreas[1],
                                               gameType: self.gameType))
                    ctx.restoreGState()
                    
                case .both:
                    let filledImage = UIImage.symbolWithTemplate(name: input.assetName + ".fill", pointSize: 150, accentColor: color)
                    let outlineImage = UIImage.symbolWithTemplate(name: input.assetName, pointSize: 150, accentColor: colorSecondary)
                    let frame = input.frame(leftButtonArea: buttonAreas[0],
                                            rightButtonArea: buttonAreas[1],
                                            gameType: self.gameType)
                    
                    filledImage.draw(in: frame)
                    ctx.restoreGState()
                    outlineImage.draw(in: frame)
                }
            }
        }
    }
    
    public func items(for traits: Skin.Traits, alt: Bool) -> [Skin.Item]?
    {
        let mappingSize = self.aspectRatio(for: traits, alt: alt) ?? .zero
        let scaleTransform = CGAffineTransform(scaleX: mappingSize.width, y: mappingSize.height)
        let buttonAreas = self.buttonAreas(for: traits)
        
        var items = [Skin.Item]()
        
        for input in self.softwareInputs() {
            if input.kind == .touchScreen
            {
                if let screens = self.screens(for: traits, alt: alt),
                   let screen = screens.first,
                   let screenFrame = screen.outputFrame
                {
                    let touchScreenFrame = CGRect(x: screenFrame.minX, y: screenFrame.midY, width: screenFrame.width, height: screenFrame.height / 2)
                    
                    items.append(Skin.Item(id: input.rawValue,
                                           kind: input.kind,
                                           inputs: input.inputs,
                                           frame: touchScreenFrame.applying(scaleTransform),
                                           edges: input.edges,
                                           mappingSize: mappingSize))
                }
            }
            else
            {
                items.append(Skin.Item(id: input.rawValue,
                                       kind: input.kind,
                                       inputs: input.inputs,
                                       frame: input.frame(leftButtonArea: buttonAreas[0].applying(scaleTransform),
                                                       rightButtonArea: buttonAreas[1].applying(scaleTransform),
                                                       gameType: self.gameType),
                                       edges: input.edges,
                                       mappingSize: mappingSize))
            }
        }
        
        return items
    }
    
    public func screens(for traits: Skin.Traits, alt: Bool) -> [Skin.Screen]?
    {
        let mappingSize = self.aspectRatio(for: traits, alt: alt) ?? CGSize()
        let scaleUpTransform = CGAffineTransform(scaleX: mappingSize.width, y: mappingSize.height)
        let scaleDownTransform = CGAffineTransform(scaleX: 1.0 / mappingSize.width, y: 1.0 / mappingSize.height)
        
        let screenSize = self.screenSize()
        let safeArea = Settings.controllerFeatures.softwareSkin.safeArea
        let buttonAreas = self.buttonAreas(for: traits).map({ $0.applying(scaleUpTransform) })
        
        var width: CGFloat = 0
        var height: CGFloat = 0
        var x: CGFloat = 0
        var y: CGFloat = 0
        
        switch traits.orientation
        {
        case .portrait:
            let availableHeight = min(buttonAreas[0].minY, buttonAreas[1].minY)
            height = mappingSize.width * (screenSize.height / screenSize.width)
            
            if (traits.device, traits.displayType) == (.iphone, .edgeToEdge),
               height > (availableHeight - safeArea) * 0.95
            {
                height = (availableHeight - safeArea) * 0.95
                width = height * (screenSize.width / screenSize.height)
                x = (mappingSize.width - width) / 2
                y = safeArea
            }
            else if height > availableHeight * 0.95
            {
                height = availableHeight * 0.95
                width = height * (screenSize.width / screenSize.height)
                x = (mappingSize.width - width) / 2
            }
            else
            {
                width = mappingSize.width
                y = (availableHeight - height) / 2
            }
            
        case .landscape:
            let leftButtonArea = buttonAreas[0]
            let rightButtonArea = buttonAreas[1]
            
            width = (rightButtonArea.minX - leftButtonArea.maxX) * mappingSize.width * 0.95
            height = width * (screenSize.height / screenSize.width)
            
            if height > mappingSize.height || Settings.controllerFeatures.softwareSkin.fullscreenLandscape
            {
                height = mappingSize.height
                width = height * (screenSize.width / screenSize.height)
            }
            else
            {
                y = (mappingSize.height - height) / 2
            }
            
            x = (mappingSize.width - width) / 2
        }
        
        let screenFrame = CGRect(x: x, y: y, width: width, height: height)
        
        return [Skin.Screen(id: "softwareControllerSkin.screen", outputFrame: screenFrame.applying(scaleDownTransform))]
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
        switch (traits.device, traits.displayType, traits.orientation)
        {
        case (_, .splitView, _): return false
        case (.tv, _, _): return false
        default: return true
        }
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
                CGRect(x: 0.03, y: 0.55, width: 0.44, height: 0.4),
                CGRect(x: 0.53, y: 0.55, width: 0.44, height: 0.4)
            ]
        case (.iphone, .edgeToEdge, .portrait):
            return [
                CGRect(x: 0.03, y: 0.55, width: 0.44, height: 0.4),
                CGRect(x: 0.53, y: 0.55, width: 0.44, height: 0.4)
            ]
        case (.iphone, .standard, .landscape):
            return [
                CGRect(x: 0, y: 0.05, width: 0.2, height: 0.9),
                CGRect(x: 0.8, y: 0.05, width: 0.2, height: 0.9)
            ]
        case (.iphone, .edgeToEdge, .landscape):
            return [
                CGRect(x: 0.05, y: 0.05, width: 0.2, height: 0.9),
                CGRect(x: 0.75, y: 0.05, width: 0.2, height: 0.9)
            ]
        case (.ipad, .standard, .portrait):
            return [
                CGRect(x: 0.05, y: 0.6, width: 0.28, height: 0.35),
                CGRect(x: 0.67, y: 0.6, width: 0.28, height: 0.35)
            ]
        case (.ipad, .standard, .landscape):
            return [
                CGRect(x: 0.03, y: 0.4, width: 0.2, height: 0.55),
                CGRect(x: 0.77, y: 0.4, width: 0.2, height: 0.55)
            ]
        default: return [.zero, .zero]
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
    
    var assetName: String
    {
        switch self
        {
        case .dPad: return "dpad"
        case .a: return "a.circle"
        case .b: return "b.circle"
        case .c: return "c.circle"
        case .x: return "x.circle"
        case .y: return "y.circle"
        case .z: return "z.circle"
        case .l: return "l.square"
        case .r: return "r.square"
        case .cUp: return "arrowtriangle.up.circle"
        case .cDown: return "arrowtriangle.down.circle"
        case .cLeft: return "arrowtriangle.left.circle"
        case .cRight: return "arrowtriangle.right.circle"
        case .start: return "plus.circle"
        case .select: return "minus.circle"
        case .menu: return "ellipsis.circle"
        case .quickSettings: return "gearshape.circle"
        default: return ""
        }
    }
}
