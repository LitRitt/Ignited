//
//  SoftwareControllerSkin.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 2/16/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import UIKit
import CoreGraphics
import AVFoundation

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
        case .genesis, .ms, .gg: return false
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
        let mappingSize = self.aspectRatio(for: traits, alt: alt) ?? .zero
        var buttonAreas = [CGRect]()
        
        for buttonArea in self.buttonAreas(for: traits)
        {
            buttonAreas.append(self.getAbsolute(buttonArea))
        }
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale
        let renderer = UIGraphicsImageRenderer(size: mappingSize, format: format)
        
        return renderer.image { (context) in
            let ctx = context.cgContext
            
            for input in self.softwareInputs()
            {
                var assetName = input.assetName
                var kind = input.kind
                
                var color = Settings.controllerFeatures.softwareSkin.color.uiColor
                var colorSecondary = Settings.controllerFeatures.softwareSkin.color.uiColorSecondary
                
                if self.gameType != .n64,
                   input.kind == .dPad,
                   Settings.controllerFeatures.softwareSkin.directionalInputType == .thumbstick
                {
                    assetName = SoftwareInput.thumbstick.assetName
                    kind = SoftwareInput.thumbstick.kind
                }
                
                if kind == .thumbstick
                {
                    color = color.withAlphaComponent(0.5)
                }
                
                ctx.saveGState()
                
                if Settings.controllerFeatures.softwareSkin.shadows,
                   kind != .thumbstick
                {
                    let opacity = Settings.controllerFeatures.softwareSkin.shadowOpacity
                    ctx.setShadow(offset: CGSize(width: 0, height: 3), blur: 9, color: UIColor.black.withAlphaComponent(opacity).cgColor)
                }
                
                switch Settings.controllerFeatures.softwareSkin.style
                {
                case .outline:
                    let image = UIImage.symbolWithTemplate(name: assetName, pointSize: 150, accentColor: color)
                    image.draw(in: input.frame(leftButtonArea: buttonAreas[0],
                                               rightButtonArea: buttonAreas[1],
                                               gameType: self.gameType))
                    ctx.restoreGState()
                    
                case .filled:
                    let image = UIImage.symbolWithTemplate(name: assetName + ".fill", pointSize: 150, accentColor: color)
                    image.draw(in: input.frame(leftButtonArea: buttonAreas[0],
                                               rightButtonArea: buttonAreas[1],
                                               gameType: self.gameType))
                    ctx.restoreGState()
                    
                case .both:
                    let filledImage = UIImage.symbolWithTemplate(name: assetName + ".fill", pointSize: 150, accentColor: color)
                    let outlineImage = UIImage.symbolWithTemplate(name: assetName, pointSize: 150, accentColor: colorSecondary)
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
        let buttonAreas = self.buttonAreas(for: traits)
        
        var items = [Skin.Item]()
        
        for input in self.softwareInputs() {
            switch input.kind
            {
            case .touchScreen:
                if let screens = self.screens(for: traits, alt: alt),
                   let screen = screens.first,
                   let screenFrame = screen.outputFrame
                {
                    let touchScreenFrame = CGRect(x: screenFrame.minX, y: screenFrame.midY, width: screenFrame.width, height: screenFrame.height / 2)
                    
                    items.append(Skin.Item(id: input.rawValue,
                                           kind: input.kind,
                                           inputs: input.inputs(self.gameType),
                                           frame: self.getAbsolute(touchScreenFrame),
                                           edges: input.edges,
                                           mappingSize: mappingSize))
                }
                
            default:
                var kind = input.kind
                
                if self.gameType != .n64,
                   kind == .dPad
                {
                    switch Settings.controllerFeatures.softwareSkin.directionalInputType
                    {
                    case .dPad: kind = .dPad
                    case .thumbstick: kind = .thumbstick
                    }
                }
                
                let frame = input.frame(leftButtonArea: self.getAbsolute(buttonAreas[0]),
                                        rightButtonArea: self.getAbsolute(buttonAreas[1]),
                                        gameType: self.gameType)
                
                if kind == .thumbstick
                {
                    let thumbstickSize = CGSize(width: (frame.width / 2) + 24, height: (frame.height / 2) + 24)
                    
                    items.append(Skin.Item(id: input.rawValue,
                                           kind: kind,
                                           inputs: input.inputs(self.gameType),
                                           frame: frame,
                                           edges: input.edges,
                                           mappingSize: mappingSize,
                                           thumbstickSize: thumbstickSize))
                }
                else
                {
                    items.append(Skin.Item(id: input.rawValue,
                                           kind: kind,
                                           inputs: input.inputs(self.gameType),
                                           frame: frame,
                                           edges: input.edges,
                                           mappingSize: mappingSize))
                }
            }
        }
        
        return items
    }
    
    public func screens(for traits: Skin.Traits, alt: Bool) -> [Skin.Screen]?
    {
        let mappingSize = self.aspectRatio(for: traits, alt: alt) ?? CGSize()
        
        let screenSize = self.screenSize()
        let safeArea = Settings.controllerFeatures.softwareSkin.safeArea
        let buttonAreas = self.buttonAreas(for: traits).map({ self.getAbsolute($0) })
        
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
            
            width = (rightButtonArea.minX - leftButtonArea.maxX) * 0.95
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
        
        return [Skin.Screen(id: "softwareControllerSkin.screen", outputFrame: self.getRelative(screenFrame))]
    }
    
    public func thumbstick(for item: Skin.Item, traits: Skin.Traits, preferredSize: Skin.Size, alt: Bool) -> (UIImage, CGSize)?
    {
        let frame = self.getAbsolute(item.frame)
        let thumbstickSize = CGSize(width: frame.width / 2, height: frame.height / 2)
        let thumbstickFrame = CGRect(origin: CGPoint(x: 12, y: 12), size: thumbstickSize)
        let renderSize = CGSize(width: thumbstickSize.width + 24, height: thumbstickSize.height + 24)
        let size = self.getRelative(renderSize)
        
        let assetName = "circle.circle"
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale
        let renderer = UIGraphicsImageRenderer(size: renderSize, format: format)
        
        let image = renderer.image { (context) in
            let ctx = context.cgContext
            
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
                let image = UIImage.symbolWithTemplate(name: assetName, pointSize: 150, accentColor: color)
                image.draw(in: thumbstickFrame)
                ctx.restoreGState()
                
            case .filled:
                let image = UIImage.symbolWithTemplate(name: assetName + ".fill", pointSize: 150, accentColor: color)
                image.draw(in: thumbstickFrame)
                ctx.restoreGState()
                
            case .both:
                let filledImage = UIImage.symbolWithTemplate(name: assetName + ".fill", pointSize: 150, accentColor: color)
                let outlineImage = UIImage.symbolWithTemplate(name: assetName, pointSize: 150, accentColor: colorSecondary)
                
                filledImage.draw(in: thumbstickFrame)
                ctx.restoreGState()
                outlineImage.draw(in: thumbstickFrame)
            }
        }
        
        return (image, size)
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
                CGRect(x: 0.02, y: 0.5, width: 0.46, height: 0.45),
                CGRect(x: 0.52, y: 0.5, width: 0.46, height: 0.45)
            ]
        case (.iphone, .edgeToEdge, .portrait):
            return [
                CGRect(x: 0.02, y: 0.5, width: 0.46, height: 0.45),
                CGRect(x: 0.52, y: 0.5, width: 0.46, height: 0.45)
            ]
        case (.iphone, .standard, .landscape):
            return [
                CGRect(x: 0.03, y: 0.02, width: 0.22, height: 0.96),
                CGRect(x: 0.75, y: 0.02, width: 0.22, height: 0.96)
            ]
        case (.iphone, .edgeToEdge, .landscape):
            return [
                CGRect(x: 0.05, y: 0.02, width: 0.2, height: 0.96),
                CGRect(x: 0.75, y: 0.02, width: 0.2, height: 0.96)
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
}

private extension SoftwareControllerSkin
{
    func getAbsolute(_ size: CGSize) -> CGSize
    {
        let mappingSize = SoftwareControllerSkin.deviceSize()
        let scaleTransform = CGAffineTransform(scaleX: mappingSize.width, y: mappingSize.height)
        
        return size.applying(scaleTransform)
    }
    
    func getAbsolute(_ rect: CGRect) -> CGRect
    {
        let mappingSize = SoftwareControllerSkin.deviceSize()
        let scaleTransform = CGAffineTransform(scaleX: mappingSize.width, y: mappingSize.height)
        
        return rect.applying(scaleTransform)
    }
    
    func getRelative(_ size: CGSize) -> CGSize
    {
        let mappingSize = SoftwareControllerSkin.deviceSize()
        let scaleTransform = CGAffineTransform(scaleX: 1 / mappingSize.width, y: 1 / mappingSize.height)
        
        return size.applying(scaleTransform)
    }
    
    func getRelative(_ rect: CGRect) -> CGRect
    {
        let mappingSize = SoftwareControllerSkin.deviceSize()
        let scaleTransform = CGAffineTransform(scaleX: 1 / mappingSize.width, y: 1 / mappingSize.height)
        
        return rect.applying(scaleTransform)
    }
}

extension CGRect
{
    func getSubRect(sections: CGFloat, index: CGFloat, size: CGFloat) -> CGRect
    {
        guard (index - 1) + size <= sections else { return self }
        
        let width = self.width
        let x = self.minX
        
        let sectionHeight = self.height / sections
        
        let height = sectionHeight * size
        let y = self.minY + ((index - 1) * sectionHeight)
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    func getInsetSquare(inset: CGFloat = 5) -> CGRect
    {
        let square = AVMakeRect(aspectRatio: CGSize(width: 1, height: 1), insideRect: self)
        
        return square.insetBy(dx: inset, dy: inset)
    }
    
    func getFourButtons(inset: CGFloat = 5) -> (top: CGRect, bottom: CGRect, left: CGRect, right: CGRect)
    {
        let square = self.getInsetSquare(inset: inset)
        
        let sectionWidth = square.width / 3
        let sectionHeight = square.height / 3
        
        let top = CGRect(x: square.minX + sectionWidth, y: square.minY, width: sectionWidth, height: sectionHeight)
        let bottom = CGRect(x: square.minX + sectionWidth, y: square.maxY - sectionHeight, width: sectionWidth, height: sectionHeight)
        let left = CGRect(x: square.minX, y: square.minY + sectionHeight, width: sectionWidth, height: sectionHeight)
        let right = CGRect(x: square.maxX - sectionWidth, y: square.minY + sectionHeight, width: sectionWidth, height: sectionHeight)
        
        return (top, bottom, left, right)
    }
    
    func getTwoButtons(inset: CGFloat = 5) -> (left: CGRect, right: CGRect)
    {
        let square = self.getInsetSquare(inset: inset)
        
        let sectionWidth = square.width * 0.45
        let sectionHeight = square.height * 0.45
        let midY = square.midY - (sectionHeight / 2)
        
        let left = CGRect(x: square.minX, y: midY + (sectionHeight * 0.3), width: sectionWidth, height: sectionHeight)
        let right = CGRect(x: square.maxX - sectionWidth, y: midY - (sectionHeight * 0.3), width: sectionWidth, height: sectionHeight)
        
        return (left, right)
    }
    
    func getTwoButtonsHorizontal() -> (left: CGRect, right: CGRect)
    {
        var width = self.width * 0.3
        var height = width
        
        if width > self.height * 0.8
        {
            height = self.height * 0.8
            width = height
        }
        
        let midX = self.midX - (width / 2)
        let y = self.minY + ((self.height - height) / 2)
        
        let left = CGRect(x: midX - (self.width / 4), y: y, width: width, height: height)
        let right = CGRect(x: midX + (self.width / 4), y: y, width: width, height: height)
        
        return (left, right)
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
    
    func inputs(_ gameType: GameType) -> DeltaCore.ControllerSkin.Item.Inputs
    {
        switch (self.kind, gameType)
        {
        case (.dPad, _):
            return .directional(up: AnyInput(stringValue: "up", intValue: nil, type: .controller(.controllerSkin), isContinuous: false),
                                down: AnyInput(stringValue: "down", intValue: nil, type: .controller(.controllerSkin), isContinuous: false),
                                left: AnyInput(stringValue: "left", intValue: nil, type: .controller(.controllerSkin), isContinuous: false),
                                right: AnyInput(stringValue: "right", intValue: nil, type: .controller(.controllerSkin), isContinuous: false))
            
        case (.touchScreen, _):
            return .touch(x: AnyInput(stringValue: "touchScreenX", intValue: nil, type: .controller(.controllerSkin), isContinuous: true),
                          y: AnyInput(stringValue: "touchScreenY", intValue: nil, type: .controller(.controllerSkin), isContinuous: true))
            
        case (.thumbstick, .n64):
            return .directional(up: AnyInput(stringValue: "analogStickUp", intValue: nil, type: .controller(.controllerSkin), isContinuous: true),
                                down: AnyInput(stringValue: "analogStickDown", intValue: nil, type: .controller(.controllerSkin), isContinuous: true),
                                left: AnyInput(stringValue: "analogStickLeft", intValue: nil, type: .controller(.controllerSkin), isContinuous: true),
                                right: AnyInput(stringValue: "analogStickRight", intValue: nil, type: .controller(.controllerSkin), isContinuous: true))
              
        case (.thumbstick, _):
            return .directional(up: AnyInput(stringValue: "up", intValue: nil, type: .controller(.controllerSkin), isContinuous: true),
                                down: AnyInput(stringValue: "down", intValue: nil, type: .controller(.controllerSkin), isContinuous: true),
                                left: AnyInput(stringValue: "left", intValue: nil, type: .controller(.controllerSkin), isContinuous: true),
                                right: AnyInput(stringValue: "right", intValue: nil, type: .controller(.controllerSkin), isContinuous: true))
            
        default: return .standard([AnyInput(stringValue: self.rawValue, intValue: nil, type: .controller(.controllerSkin))])
        }
    }
    
    func frame(leftButtonArea: CGRect, rightButtonArea: CGRect, gameType: GameType) -> CGRect
    {
        var input = self
        
        switch gameType
        {
        case .nes, .snes, .gbc, .gba, .ds:
            switch (Settings.controllerFeatures.softwareSkin.abxyLayout, input)
            {
            case (.xbox, .a), (.swapAB, .a): input = .b
            case (.xbox, .b), (.swapAB, .b): input = .a
            case (.xbox, .x), (.swapXY, .x): input = .y
            case (.xbox, .y), (.swapXY, .y): input = .x
            default: break
            }
            
        default: break
        }
        
        var frame = CGRect()
        
        switch input
        {
        case .dPad:
            switch gameType
            {
            case .gba, .gbc, .nes, .snes, .ds, .genesis, .ms, .gg:
                frame = leftButtonArea.getSubRect(sections: 4, index: 2, size: 2).getInsetSquare()
                
            case .n64:
                switch Settings.controllerFeatures.softwareSkin.n64Layout
                {
                case .swapLeft, .swapBoth:
                    frame = leftButtonArea.getSubRect(sections: 8, index: 2, size: 3).getInsetSquare(inset: 10)
                    
                default:
                    frame = leftButtonArea.getSubRect(sections: 8, index: 6, size: 3).getInsetSquare()
                }
                
            default: break
            }
            
        case .thumbstick:
            switch gameType
            {
            case .n64:
                switch Settings.controllerFeatures.softwareSkin.n64Layout
                {
                case .swapLeft, .swapBoth:
                    frame = leftButtonArea.getSubRect(sections: 8, index: 5, size: 4).getInsetSquare()
                    
                default:
                    frame = leftButtonArea.getSubRect(sections: 8, index: 2, size: 4).getInsetSquare(inset: 10)
                }
                
            default: break
            }
            
        case .a:
            switch gameType
            {
            case .gba, .gbc, .nes:
                frame = rightButtonArea.getSubRect(sections: 4, index: 2, size: 2).getTwoButtons().right
                
            case .snes, .ds:
                frame = rightButtonArea.getSubRect(sections: 4, index: 2, size: 2).getFourButtons().right
                
            case .n64:
                switch Settings.controllerFeatures.softwareSkin.n64Layout
                {
                case .swapRight, .swapBoth:
                    frame = rightButtonArea.getSubRect(sections: 8, index: 5, size: 4).getFourButtons().right
                    
                default:
                    frame = rightButtonArea.getSubRect(sections: 8, index: 2, size: 4).getFourButtons(inset: 10).right
                }
                
            default: break
            }
            
        case .b:
            switch gameType
            {
            case .gba, .gbc, .nes:
                frame = rightButtonArea.getSubRect(sections: 4, index: 2, size: 2).getTwoButtons().left
                
            case .snes, .ds:
                frame = rightButtonArea.getSubRect(sections: 4, index: 2, size: 2).getFourButtons().bottom
                
            case .n64:
                switch Settings.controllerFeatures.softwareSkin.n64Layout
                {
                case .swapRight, .swapBoth:
                    frame = rightButtonArea.getSubRect(sections: 8, index: 5, size: 4).getFourButtons().bottom
                    
                default:
                    frame = rightButtonArea.getSubRect(sections: 8, index: 2, size: 4).getFourButtons(inset: 10).bottom
                }
                
            default: break
            }
            
        case .x:
            switch gameType
            {
            case .snes, .ds:
                frame = rightButtonArea.getSubRect(sections: 4, index: 2, size: 2).getFourButtons().top
                
            default: break
            }
            
        case .y:
            switch gameType
            {
            case .snes, .ds:
                frame = rightButtonArea.getSubRect(sections: 4, index: 2, size: 2).getFourButtons().left
                
            default: break
            }
            
        case .z:
            switch gameType
            {
            case .n64:
                switch Settings.controllerFeatures.softwareSkin.n64Layout
                {
                case .swapRight, .swapBoth:
                    frame = rightButtonArea.getSubRect(sections: 8, index: 5, size: 4).getFourButtons().top
                    
                default:
                    frame = rightButtonArea.getSubRect(sections: 8, index: 2, size: 4).getFourButtons(inset: 10).top
                }
                
            default: break
            }
            
        case .l:
            switch gameType
            {
            case .gba, .snes, .ds:
                frame = leftButtonArea.getSubRect(sections: 4, index: 1, size: 1).getTwoButtonsHorizontal().left
                
            case .n64:
                frame = leftButtonArea.getSubRect(sections: 8, index: 1, size: 1).getTwoButtonsHorizontal().left
                
            default: break
            }
            
        case .r:
            switch gameType
            {
            case .gba, .snes, .ds:
                frame = rightButtonArea.getSubRect(sections: 4, index: 1, size: 1).getTwoButtonsHorizontal().right
                
            case .n64:
                frame = rightButtonArea.getSubRect(sections: 8, index: 1, size: 1).getTwoButtonsHorizontal().right
                
            default: break
            }
            
        case .cUp:
            switch gameType
            {
            case .n64:
                switch Settings.controllerFeatures.softwareSkin.n64Layout
                {
                case .swapRight, .swapBoth:
                    frame = rightButtonArea.getSubRect(sections: 8, index: 2, size: 3).getFourButtons(inset: 10).top
                    
                default:
                    frame = rightButtonArea.getSubRect(sections: 8, index: 6, size: 3).getFourButtons().top
                }
                
            default: break
            }
            
        case .cDown:
            switch gameType
            {
            case .n64:
                switch Settings.controllerFeatures.softwareSkin.n64Layout
                {
                case .swapRight, .swapBoth:
                    frame = rightButtonArea.getSubRect(sections: 8, index: 2, size: 3).getFourButtons(inset: 10).bottom
                    
                default:
                    frame = rightButtonArea.getSubRect(sections: 8, index: 6, size: 3).getFourButtons().bottom
                }
                
            default: break
            }
            
        case .cLeft:
            switch gameType
            {
            case .n64:
                switch Settings.controllerFeatures.softwareSkin.n64Layout
                {
                case .swapRight, .swapBoth:
                    frame = rightButtonArea.getSubRect(sections: 8, index: 2, size: 3).getFourButtons(inset: 10).left
                    
                default:
                    frame = rightButtonArea.getSubRect(sections: 8, index: 6, size: 3).getFourButtons().left
                }
                
            default: break
            }
            
        case .cRight:
            switch gameType
            {
            case .n64:
                switch Settings.controllerFeatures.softwareSkin.n64Layout
                {
                case .swapRight, .swapBoth:
                    frame = rightButtonArea.getSubRect(sections: 8, index: 2, size: 3).getFourButtons(inset: 10).right
                    
                default:
                    frame = rightButtonArea.getSubRect(sections: 8, index: 6, size: 3).getFourButtons().right
                }
                
            default: break
            }
            
        case .select:
            switch gameType
            {
            case .gba, .gbc, .nes, .snes, .ds:
                frame = leftButtonArea.getSubRect(sections: 4, index: 4, size: 1).getTwoButtonsHorizontal().right
                
            default: break
            }
            
        case .start:
            switch gameType
            {
            case .gba, .gbc, .nes, .snes, .ds:
                frame = rightButtonArea.getSubRect(sections: 4, index: 4, size: 1).getTwoButtonsHorizontal().left
                
            case .n64:
                switch Settings.controllerFeatures.softwareSkin.n64Layout
                {
                case .swapRight, .swapBoth:
                    frame = rightButtonArea.getSubRect(sections: 8, index: 5, size: 4).getFourButtons().left
                    
                default:
                    frame = rightButtonArea.getSubRect(sections: 8, index: 2, size: 4).getFourButtons(inset: 10).left
                }

            default: break
            }
            
        case .quickSettings:
            switch gameType
            {
            case .gba, .gbc, .nes, .snes, .ds:
                frame = rightButtonArea.getSubRect(sections: 4, index: 4, size: 1).getTwoButtonsHorizontal().right
                
            case .n64:
                frame = rightButtonArea.getSubRect(sections: 8, index: 1, size: 1).getTwoButtonsHorizontal().left
                
            default: break
            }
            
        case .menu:
            switch gameType
            {
            case .gba, .gbc, .nes, .snes, .ds:
                frame = leftButtonArea.getSubRect(sections: 4, index: 4, size: 1).getTwoButtonsHorizontal().left
                
            case .n64:
                frame = leftButtonArea.getSubRect(sections: 8, index: 1, size: 1).getTwoButtonsHorizontal().right
                
            default: break
            }
            
        default: break
        }
        
        return frame
    }
    
    var edges: [String: CGFloat]
    {
        switch self
        {
        case .touchScreen, .thumbstick: return [:]
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
        case .thumbstick: return "circle"
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
