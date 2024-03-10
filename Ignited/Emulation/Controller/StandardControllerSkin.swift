//
//  StandardControllerSkin.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 2/16/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import UIKit
import CoreGraphics
import AVFoundation

import DeltaCore

public struct StandardControllerSkin
{
    public typealias Skin = DeltaCore.ControllerSkin
    
    public var name: String { "StandardControllerSkin" }
    public var identifier: String
    public var gameType: GameType
    
    public var inputMappingMode: Bool
    public var isDebugModeEnabled: Bool { false }
    public var hasAltRepresentations: Bool {
        return self.gameType == .ds
    }
    
    public init?(for gameType: GameType, inputMappingMode: Bool = false)
    {
        self.identifier = "com.ignited.StandardControllerSkin." + gameType.description
        self.gameType = gameType
        
        self.inputMappingMode = inputMappingMode
    }
    
    static public var extendedEdges: [String: CGFloat]
    {[
        "top": Settings.standardSkinFeatures.inputsAndLayout.extendedEdges,
        "bottom": Settings.standardSkinFeatures.inputsAndLayout.extendedEdges,
        "left": Settings.standardSkinFeatures.inputsAndLayout.extendedEdges,
        "right": Settings.standardSkinFeatures.inputsAndLayout.extendedEdges
    ]}
}

extension StandardControllerSkin: ControllerSkinProtocol
{
    public func items(for traits: Skin.Traits, alt: Bool) -> [Skin.Item]?
    {
        let mappingSize = self.aspectRatio(for: traits, alt: alt) ?? .zero
        let buttonAreas = self.buttonAreas(for: traits)
        let isSplitView = traits.displayType == .splitView
        
        var items = [Skin.Item]()
        
        for input in self.softwareInputs() {
            switch input.kind
            {
            case .touchScreen:
                if let screens = self.screens(for: traits, alt: alt),
                   let screen = screens.last,
                   let screenFrame = screen.outputFrame
                {
                    items.append(Skin.Item(id: input.description(self.gameType, isSplitView: isSplitView),
                                           kind: input.kind,
                                           inputs: input.inputs(self.gameType, isSplitView: isSplitView),
                                           frame: screenFrame.getAbsolute(for: traits, inputMappingMode: self.inputMappingMode),
                                           edges: input.edges,
                                           mappingSize: mappingSize))
                }
                
            default:
                var kind = input.kind
                
                if self.gameType != .n64,
                   kind == .dPad
                {
                    switch Settings.standardSkinFeatures.inputsAndLayout.directionalInputType
                    {
                    case .dPad: kind = .dPad
                    case .thumbstick: kind = .thumbstick
                    }
                }
                
                let frame = input.frame(leftButtonArea: buttonAreas[0].getAbsolute(for: traits, inputMappingMode: self.inputMappingMode),
                                            rightButtonArea: buttonAreas[1].getAbsolute(for: traits, inputMappingMode: self.inputMappingMode),
                                            gameType: self.gameType)
                
                if kind == .thumbstick
                {
                    let thumbstickSize = CGSize(width: (frame.width / 2) + 24, height: (frame.height / 2) + 24)
                    
                    items.append(Skin.Item(id: input.description(self.gameType, isSplitView: isSplitView),
                                           kind: kind,
                                           inputs: input.inputs(self.gameType, isSplitView: isSplitView),
                                           frame: frame,
                                           edges: input.edges,
                                           mappingSize: mappingSize,
                                           thumbstickSize: thumbstickSize))
                }
                else
                {
                    items.append(Skin.Item(id: input.description(self.gameType, isSplitView: isSplitView),
                                           kind: kind,
                                           inputs: input.inputs(self.gameType, isSplitView: isSplitView),
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
        guard !self.inputMappingMode else {
            let screenFrame = CGRect(x: 0, y: 0.07, width: 1, height: 0.2)
            
            return [Skin.Screen(id: "standardControllerSkin.screen", outputFrame: screenFrame, style: self.screenStyle())]
        }
        
        let buttonAreas = self.buttonAreas(for: traits).map({ $0.getAbsolute(for: traits, inputMappingMode: self.inputMappingMode) })
        let leftButtonArea = buttonAreas[0]
        let rightButtonArea = buttonAreas[1]
        
        let mappingSize = self.aspectRatio(for: traits, alt: alt) ?? .zero
        let safeArea = self.unsafeArea(for: traits, alt: alt) ?? 0
        
        var screenArea: CGRect
        
        switch (traits.displayType, traits.orientation)
        {
        case (.splitView, _):
            let screenAreaWidth = rightButtonArea.minX - leftButtonArea.maxX
            
            screenArea = CGRect(x: leftButtonArea.maxX, y: 0, width: screenAreaWidth, height: mappingSize.height)
            
        case (_, .portrait):
            var screenAreaHeight = min(leftButtonArea.minY, rightButtonArea.minY)
            var screenAreaY = 0.0
            
            if traits.device == .iphone,
               traits.displayType == .edgeToEdge
            {
                screenAreaHeight -= safeArea
                screenAreaY = safeArea
            }
            
            screenArea = CGRect(x: 0, y: screenAreaY, width: mappingSize.width, height: screenAreaHeight)
            
        case (_, .landscape):
            let screenAreaWidth = rightButtonArea.minX - leftButtonArea.maxX
            
            if Settings.standardSkinFeatures.gameScreen.fullscreenLandscape
            {
                screenArea = CGRect(origin: .zero, size: mappingSize)
            }
            else
            {
                screenArea = CGRect(x: leftButtonArea.maxX, y: 0, width: screenAreaWidth, height: mappingSize.height)
            }
        }
        
        if self.screenStyle() == .floating
        {
            screenArea = screenArea.insetBy(dx: 10, dy: 10)
        }
        
        switch self.gameType
        {
        case .ds:
            let aspectRatio = CGSize(width: self.screenSize().width, height: self.screenSize().height / 2)
            let topScreenInputFrame = CGRect(origin: .zero, size: aspectRatio)
            let bottomScreenInputFrame = CGRect(origin: CGPoint(x: 0, y: aspectRatio.height), size: aspectRatio)
            
            let topScreenHeight = screenArea.height * Settings.standardSkinFeatures.gameScreen.dsTopScreenSize
            var topScreenArea = CGRect(x: screenArea.minX, y: screenArea.minY, width: screenArea.width, height: topScreenHeight)
            
            let bottomScreenHeight = screenArea.height - topScreenHeight
            var bottomScreenArea = CGRect(x: screenArea.minX, y: screenArea.minY + topScreenHeight, width: screenArea.width, height: bottomScreenHeight)
            
            if self.screenStyle() == DeltaCore.GameViewStyle.floating
            {
                topScreenArea = topScreenArea.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 0))
                bottomScreenArea = bottomScreenArea.inset(by: UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0))
            }
            
            let topScreenFrame = AVMakeRect(aspectRatio: aspectRatio, insideRect: topScreenArea).getRelative(for: traits, inputMappingMode: self.inputMappingMode)
            let bottomScreenFrame = AVMakeRect(aspectRatio: aspectRatio, insideRect: bottomScreenArea).getRelative(for: traits, inputMappingMode: self.inputMappingMode)
            
            let bottomScreenSplitViewFrame = AVMakeRect(aspectRatio: aspectRatio, insideRect: screenArea).getRelative(for: traits, inputMappingMode: self.inputMappingMode)
            
            switch (traits.displayType, alt)
            {
            case (.splitView, _):
                return [
                    Skin.Screen(id: "standardControllerSkin.topScreen", inputFrame: topScreenInputFrame, placement: .app, style: self.screenStyle()),
                    Skin.Screen(id: "standardControllerSkin.bottomScreen", inputFrame: bottomScreenInputFrame, outputFrame: bottomScreenSplitViewFrame, isTouchScreen: true, style: self.screenStyle())
                ]
                
            case (_, false):
                return [
                    Skin.Screen(id: "standardControllerSkin.topScreen", inputFrame: topScreenInputFrame, outputFrame: topScreenFrame, style: self.screenStyle()),
                    Skin.Screen(id: "standardControllerSkin.bottomScreen", inputFrame: bottomScreenInputFrame, outputFrame: bottomScreenFrame, isTouchScreen: true, style: self.screenStyle())
                ]
                
            case (_, true):
                return [
                    Skin.Screen(id: "standardControllerSkin.topScreen", inputFrame: topScreenInputFrame, outputFrame: bottomScreenFrame, style: self.screenStyle()),
                    Skin.Screen(id: "standardControllerSkin.bottomScreen", inputFrame: bottomScreenInputFrame, outputFrame: topScreenFrame, isTouchScreen: true, style: self.screenStyle())
                ]
                
            }
            
        default:
            let screenFrame = AVMakeRect(aspectRatio: self.screenSize(), insideRect: screenArea).getRelative(for: traits, inputMappingMode: self.inputMappingMode)
            
            switch (traits.device, traits.displayType)
            {
            case (_, .splitView):
                return [Skin.Screen(id: "standardControllerSkin.screen", placement: .app, style: self.screenStyle())]
                
            case (.tv, _):
                return nil
                
            default:
                return [Skin.Screen(id: "standardControllerSkin.screen", outputFrame: screenFrame, style: self.screenStyle())]
            }
        }
    }
    
    public func image(for traits: Skin.Traits, preferredSize: Skin.Size, alt: Bool) -> UIImage?
    {
        let mappingSize = self.aspectRatio(for: traits, alt: alt) ?? .zero
        var buttonAreas = [CGRect]()
        let isSplitView = traits.displayType == .splitView
        
        for buttonArea in self.buttonAreas(for: traits)
        {
            buttonAreas.append(buttonArea.getAbsolute(for: traits, inputMappingMode: self.inputMappingMode))
        }
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale
        let renderer = UIGraphicsImageRenderer(size: mappingSize, format: format)
        
        return renderer.image { (context) in
            let ctx = context.cgContext
            
            for input in self.softwareInputs()
            {
                var assetName = input.assetName(self.gameType, isSplitView: isSplitView)
                var kind = input.kind
                
                var color = Settings.standardSkinFeatures.styleAndColor.color.uiColor
                var colorSecondary = Settings.standardSkinFeatures.styleAndColor.color.uiColorSecondary
                
                if self.gameType != .n64,
                   input.kind == .dPad,
                   Settings.standardSkinFeatures.inputsAndLayout.directionalInputType == .thumbstick
                {
                    assetName = SoftwareInput.thumbstick.assetName(self.gameType)
                    kind = SoftwareInput.thumbstick.kind
                }
                
                if kind == .thumbstick
                {
                    color = color.withAlphaComponent(0.5)
                }
                
                ctx.saveGState()
                
                if Settings.standardSkinFeatures.styleAndColor.shadows,
                   kind != .thumbstick
                {
                    let opacity = Settings.standardSkinFeatures.styleAndColor.shadowOpacity
                    ctx.setShadow(offset: CGSize(width: 0, height: 3), blur: 9, color: UIColor.black.withAlphaComponent(opacity).cgColor)
                }
                
                switch Settings.standardSkinFeatures.styleAndColor.style
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
    
    public func thumbstick(for item: Skin.Item, traits: Skin.Traits, preferredSize: Skin.Size, alt: Bool) -> (UIImage, CGSize)?
    {
        let frame = item.frame.getAbsolute(for: traits, inputMappingMode: self.inputMappingMode)
        let thumbstickSize = CGSize(width: frame.width / 2, height: frame.height / 2)
        let thumbstickFrame = CGRect(origin: CGPoint(x: 12, y: 12), size: thumbstickSize)
        let renderSize = CGSize(width: thumbstickSize.width + 24, height: thumbstickSize.height + 24)
        let size = renderSize.getRelative(for: traits, inputMappingMode: self.inputMappingMode)
        
        let assetName = "circle.circle"
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale
        let renderer = UIGraphicsImageRenderer(size: renderSize, format: format)
        
        let image = renderer.image { (context) in
            let ctx = context.cgContext
            
            ctx.saveGState()
                
            if Settings.standardSkinFeatures.styleAndColor.shadows
            {
                let opacity = Settings.standardSkinFeatures.styleAndColor.shadowOpacity
                ctx.setShadow(offset: CGSize(width: 0, height: 3), blur: 9, color: UIColor.black.withAlphaComponent(opacity).cgColor)
            }
            
            let color = Settings.standardSkinFeatures.styleAndColor.color.uiColor
            let colorSecondary = Settings.standardSkinFeatures.styleAndColor.color.uiColorSecondary
            
            switch Settings.standardSkinFeatures.styleAndColor.style
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
        guard !self.inputMappingMode else {
            return CGSize(width: 414, height: 736)
        }
        
        switch (traits.displayType, traits.orientation)
        {
        case (.splitView, .portrait): return CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * Settings.standardSkinFeatures.inputsAndLayout.splitViewPortraitSize)
        case (.splitView, .landscape): return CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * Settings.standardSkinFeatures.inputsAndLayout.splitViewLandscapeSize)
        default: return CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        }
    }
    
    public func supports(_ traits: Skin.Traits, alt: Bool) -> Bool
    {
        return true
    }
    
    public func isTranslucent(for traits: Skin.Traits, alt: Bool) -> Bool?
    {
        return Settings.standardSkinFeatures.styleAndColor.translucentInputs
    }
    
    public func anyImage(for traits: Skin.Traits, preferredSize: Skin.Size, alt: Bool) -> UIImage?
    {
        return self.image(for: traits, preferredSize: preferredSize, alt: alt)
    }
    
    public func contentSize(for traits: Skin.Traits, alt: Bool) -> CGSize?
    {
        return nil
    }
    
    public func previewSize(for traits: Skin.Traits, alt: Bool) -> CGSize?
    {
        return CGSize(width: 400, height: 200)
    }
    
    public func anyPreviewSize(for traits: Skin.Traits, alt: Bool) -> CGSize?
    {
        return self.previewSize(for: traits, alt: alt)
    }
    
    public func unsafeArea(for traits: Skin.Traits, alt: Bool) -> CGFloat?
    {
        guard traits.device == .iphone,
              traits.displayType == .edgeToEdge else {
            return 0
        }
        
        return CGFloat(Settings.standardSkinFeatures.gameScreen.unsafeArea)
    }
}

extension StandardControllerSkin
{
    private func buttonAreas(for traits: Skin.Traits) -> [CGRect]
    {
        guard !self.inputMappingMode else {
            return [
                CGRect(x: 0.01, y: 0.35, width: 0.48, height: 0.65),
                CGRect(x: 0.51, y: 0.35, width: 0.48, height: 0.65)
            ]
        }
        
        var buttonAreas: [CGRect] = [.zero, .zero]
        
        switch (traits.device, traits.displayType, traits.orientation)
        {
        case (.iphone, .standard, .portrait):
            buttonAreas = [
                CGRect(x: 0.02, y: 0.5, width: 0.46, height: 0.48),
                CGRect(x: 0.52, y: 0.5, width: 0.46, height: 0.48)
            ]
        case (.iphone, .edgeToEdge, .portrait):
            buttonAreas = [
                CGRect(x: 0.02, y: 0.5, width: 0.46, height: 0.45),
                CGRect(x: 0.52, y: 0.5, width: 0.46, height: 0.45)
            ]
        case (.iphone, .standard, .landscape):
            buttonAreas = [
                CGRect(x: 0.02, y: 0.02, width: 0.23, height: 0.96),
                CGRect(x: 0.75, y: 0.02, width: 0.23, height: 0.96)
            ]
        case (.iphone, .edgeToEdge, .landscape):
            buttonAreas = [
                CGRect(x: 0.05, y: 0.02, width: 0.2, height: 0.96),
                CGRect(x: 0.75, y: 0.02, width: 0.2, height: 0.96)
            ]
        case (.ipad, .standard, .portrait):
            buttonAreas = [
                CGRect(x: 0.05, y: 0.6, width: 0.28, height: 0.35),
                CGRect(x: 0.67, y: 0.6, width: 0.28, height: 0.35)
            ]
        case (.ipad, .standard, .landscape):
            buttonAreas = [
                CGRect(x: 0.03, y: 0.4, width: 0.2, height: 0.55),
                CGRect(x: 0.77, y: 0.4, width: 0.2, height: 0.55)
            ]
        case (.ipad, .splitView, .portrait):
            buttonAreas = [
                CGRect(x: 0.02, y: 0.02, width: 0.25, height: 0.96),
                CGRect(x: 0.73, y: 0.02, width: 0.25, height: 0.96)
            ]
        case (.ipad, .splitView, .landscape):
            buttonAreas = [
                CGRect(x: 0.02, y: 0.02, width: 0.2, height: 0.96),
                CGRect(x: 0.78, y: 0.02, width: 0.2, height: 0.96)
            ]
        default: break
        }
        
        switch self.gameType
        {
        case .gbc, .nes, .genesis, .ms, .gg:
            if !self.customButtonsEnabled()
            {
                buttonAreas = buttonAreas.map({
                    $0.getSubRect(sections: 4, index: 2, size: 3)
                })
            }
            
        default: break
        }
        
        return buttonAreas
    }
    
    private func softwareInputs() -> [SoftwareInput]
    {
        var inputs = [SoftwareInput]()
        
        switch self.gameType
        {
        case .gba: inputs = [.dPad, .a, .b, .l, .r, .start, .select, .menu]
        case .gbc, .nes: inputs = [.dPad, .a, .b, .start, .select, .menu]
        case .snes: inputs = [.dPad, .a, .b, .x, .y, .l, .r, .start, .select, .menu]
        case .ds: inputs = [.dPad, .a, .b, .x, .y, .l, .r, .start, .select, .touchScreen, .menu]
        case .n64: inputs = [.dPad, .thumbstick, .cUp, .cDown, .cLeft, .cRight, .a, .b, .l, .r, .z, .start, .menu]
        case .genesis where Settings.standardSkinFeatures.inputsAndLayout.genesisFaceLayout == .button3: inputs = [.dPad, .a, .b, .c, .start, .mode, .menu]
        case .genesis where Settings.standardSkinFeatures.inputsAndLayout.genesisFaceLayout == .button6: inputs = [.dPad, .a, .b, .c, .x, .y, .z, .start, .mode, .menu]
        case .ms, .gg: inputs = [.dPad, .b, .c, .start, .menu]
        default: break
        }
        
        guard !self.inputMappingMode else {
            return inputs
        }
        
        inputs.append(.quickSettings)
        
        if self.gameType != .n64
        {
            if Settings.standardSkinFeatures.inputsAndLayout.customButton1 != .null
            {
                inputs.append(.custom1)
            }
            if Settings.standardSkinFeatures.inputsAndLayout.customButton2 != .null
            {
                inputs.append(.custom2)
            }
        }
        
        return inputs
    }
    
    private func screenSize() -> CGSize
    {
        guard let deltaCore = Delta.core(for: self.gameType) else {
            return CGSize()
        }
        
        return deltaCore.videoFormat.dimensions
    }
    
    private func screenStyle() -> DeltaCore.GameViewStyle
    {
        guard !self.inputMappingMode else {
            return .flat
        }
        
        return Settings.standardSkinFeatures.gameScreen.style
    }
    
    public func hasTouchScreen(for traits: Skin.Traits) -> Bool
    {
        return self.gameType == .ds
    }
    
    public func customButtonsEnabled() -> Bool
    {
        return Settings.standardSkinFeatures.inputsAndLayout.customButton1 != .null || Settings.standardSkinFeatures.inputsAndLayout.customButton2 != .null
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
    case toggleAltRepresentations
    case custom1
    case custom2
    
    public func description(_ gameType: GameType, isSplitView: Bool = false) -> String
    {
        switch self
        {
        case .custom1:
            switch Settings.standardSkinFeatures.inputsAndLayout.customButton1
            {
            case .fastForward: return "fastForward"
            case .quickSave: return "quickSave"
            case .quickLoad: return "quickLoad"
            case .screenshot: return "screenshot"
            case .restart: return "restart"
            default: return ""
            }
            
        case .custom2:
            if Settings.standardSkinFeatures.inputsAndLayout.dsScreenSwap, gameType == .ds, !isSplitView
            {
                return "toggleAltRepresentations"
            }
            else
            {
                switch Settings.standardSkinFeatures.inputsAndLayout.customButton2
                {
                case .fastForward: return "fastForward"
                case .quickSave: return "quickSave"
                case .quickLoad: return "quickLoad"
                case .screenshot: return "screenshot"
                case .restart: return "restart"
                default: return ""
                }
            }
            
        default: return self.rawValue
        }
    }
    
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
    
    func inputs(_ gameType: GameType, isSplitView: Bool = false) -> DeltaCore.ControllerSkin.Item.Inputs
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
            
        default: return .standard([AnyInput(stringValue: self.description(gameType, isSplitView: isSplitView), intValue: nil, type: .controller(.controllerSkin))])
        }
    }
    
    func frame(leftButtonArea: CGRect, rightButtonArea: CGRect, gameType: GameType) -> CGRect
    {
        var input = self
        
        switch gameType
        {
        case .nes, .snes, .gbc, .gba, .ds:
            switch (Settings.standardSkinFeatures.inputsAndLayout.abxyLayout, input)
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
            case .gbc, .nes, .genesis, .ms, .gg:
                if self.customButtonsEnabled()
                {
                    frame = leftButtonArea.getSubRect(sections: 4, index: 2, size: 2).getInsetSquare()
                }
                else
                {
                    frame = leftButtonArea.getSubRect(sections: 3, index: 1, size: 2).getInsetSquare()
                }
                
            case .gba, .snes, .ds:
                frame = leftButtonArea.getSubRect(sections: 4, index: 2, size: 2).getInsetSquare()
                
            case .n64:
                switch Settings.standardSkinFeatures.inputsAndLayout.n64FaceLayout
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
                switch Settings.standardSkinFeatures.inputsAndLayout.n64FaceLayout
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
            case .gbc, .nes:
                if self.customButtonsEnabled()
                {
                    frame = rightButtonArea.getSubRect(sections: 4, index: 2, size: 2).getTwoButtons().right
                }
                else
                {
                    frame = rightButtonArea.getSubRect(sections: 3, index: 1, size: 2).getTwoButtons().right
                }
                
            case .gba:
                frame = rightButtonArea.getSubRect(sections: 4, index: 2, size: 2).getTwoButtons().right
                
            case .snes, .ds:
                frame = rightButtonArea.getSubRect(sections: 4, index: 2, size: 2).getFourButtons().right
                
            case .genesis:
                switch Settings.standardSkinFeatures.inputsAndLayout.genesisFaceLayout
                {
                case .button3:
                    if self.customButtonsEnabled()
                    {
                        frame = rightButtonArea.getSubRect(sections: 4, index: 2, size: 2).getThreeButton().left
                    }
                    else
                    {
                        frame = rightButtonArea.getSubRect(sections: 3, index: 1, size: 2).getThreeButton().left
                    }
                    
                case .button6:
                    if self.customButtonsEnabled()
                    {
                        frame = rightButtonArea.getSubRect(sections: 4, index: 3, size: 1).getThreeButton().left
                    }
                    else
                    {
                        frame = rightButtonArea.getSubRect(sections: 3, index: 2, size: 1).getThreeButton().left
                    }
                }
                
            case .gba, .gbc, .nes:
                frame = rightButtonArea.getSubRect(sections: 4, index: 2, size: 2).getTwoButtons().right
                
            case .snes, .ds:
                frame = rightButtonArea.getSubRect(sections: 4, index: 2, size: 2).getFourButtons().right
                
            case .genesis:
                switch Settings.standardSkinFeatures.inputsAndLayout.genesisFaceLayout
                {
                case .button3:
                    frame = rightButtonArea.getSubRect(sections: 4, index: 2, size: 2).getThreeButton().left
                    
                case .button6:
                    frame = rightButtonArea.getSubRect(sections: 4, index: 3, size: 1).getThreeButton().left
                }
                
            case .n64:
                switch Settings.standardSkinFeatures.inputsAndLayout.n64FaceLayout
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
            case .gbc, .nes, .ms, .gg:
                if self.customButtonsEnabled()
                {
                    frame = rightButtonArea.getSubRect(sections: 4, index: 2, size: 2).getTwoButtons().left
                }
                else
                {
                    frame = rightButtonArea.getSubRect(sections: 3, index: 1, size: 2).getTwoButtons().left
                }
                
            case .gba:
                frame = rightButtonArea.getSubRect(sections: 4, index: 2, size: 2).getTwoButtons().left
                
            case .snes, .ds:
                frame = rightButtonArea.getSubRect(sections: 4, index: 2, size: 2).getFourButtons().bottom
                
            case .genesis:
                switch Settings.standardSkinFeatures.inputsAndLayout.genesisFaceLayout
                {
                case .button3:
                    if self.customButtonsEnabled()
                    {
                        frame = rightButtonArea.getSubRect(sections: 4, index: 2, size: 2).getThreeButton().middle
                    }
                    else
                    {
                        frame = rightButtonArea.getSubRect(sections: 3, index: 1, size: 2).getThreeButton().middle
                    }
                    
                case .button6:
                    if self.customButtonsEnabled()
                    {
                        frame = rightButtonArea.getSubRect(sections: 4, index: 3, size: 1).getThreeButton().middle
                    }
                    else
                    {
                        frame = rightButtonArea.getSubRect(sections: 3, index: 2, size: 1).getThreeButton().middle
                    }
                }
                
            case .n64:
                switch Settings.standardSkinFeatures.inputsAndLayout.n64FaceLayout
                {
                case .swapRight, .swapBoth:
                    frame = rightButtonArea.getSubRect(sections: 8, index: 5, size: 4).getFourButtons().bottom
                    
                default:
                    frame = rightButtonArea.getSubRect(sections: 8, index: 2, size: 4).getFourButtons(inset: 10).bottom
                }
                
            default: break
            }
            
        case .c:
            switch gameType
            {
            case .ms, .gg:
                if self.customButtonsEnabled()
                {
                    frame = rightButtonArea.getSubRect(sections: 4, index: 2, size: 2).getTwoButtons().right
                }
                else
                {
                    frame = rightButtonArea.getSubRect(sections: 3, index: 1, size: 2).getTwoButtons().right
                }
                
            case .genesis:
                switch Settings.standardSkinFeatures.inputsAndLayout.genesisFaceLayout
                {
                case .button3:
                    if self.customButtonsEnabled()
                    {
                        frame = rightButtonArea.getSubRect(sections: 4, index: 2, size: 2).getThreeButton().right
                    }
                    else
                    {
                        frame = rightButtonArea.getSubRect(sections: 3, index: 1, size: 2).getThreeButton().right
                    }
                    
                case .button6:
                    if self.customButtonsEnabled()
                    {
                        frame = rightButtonArea.getSubRect(sections: 4, index: 3, size: 1).getThreeButton().right
                    }
                    else
                    {
                        frame = rightButtonArea.getSubRect(sections: 3, index: 2, size: 1).getThreeButton().right
                    }
                }
                
            default: break
            }
            
        case .x:
            switch gameType
            {
            case .snes, .ds:
                frame = rightButtonArea.getSubRect(sections: 4, index: 2, size: 2).getFourButtons().top
                
            case .genesis:
                switch Settings.standardSkinFeatures.inputsAndLayout.genesisFaceLayout
                {
                case .button3: break
                    
                case .button6:
                    if self.customButtonsEnabled()
                    {
                        frame = rightButtonArea.getSubRect(sections: 4, index: 2, size: 1).getThreeButton().left
                    }
                    else
                    {
                        frame = rightButtonArea.getSubRect(sections: 3, index: 1, size: 1).getThreeButton().left
                    }
                }
                
            default: break
            }
            
        case .y:
            switch gameType
            {
            case .snes, .ds:
                frame = rightButtonArea.getSubRect(sections: 4, index: 2, size: 2).getFourButtons().left
                
            case .genesis:
                switch Settings.standardSkinFeatures.inputsAndLayout.genesisFaceLayout
                {
                case .button3: break
                    
                case .button6:
                    if self.customButtonsEnabled()
                    {
                        frame = rightButtonArea.getSubRect(sections: 4, index: 2, size: 1).getThreeButton().middle
                    }
                    else
                    {
                        frame = rightButtonArea.getSubRect(sections: 3, index: 1, size: 1).getThreeButton().middle
                    }
                }
                
            default: break
            }
            
        case .z:
            switch gameType
            {
            case .n64:
                switch (Settings.standardSkinFeatures.inputsAndLayout.n64ShoulderLayout, Settings.standardSkinFeatures.inputsAndLayout.n64FaceLayout)
                {
                case (.swapZL, _):
                    frame = leftButtonArea.getSubRect(sections: 8, index: 1, size: 1).getTwoButtonsHorizontal().left
                    
                case (.swapZR, _):
                    frame = rightButtonArea.getSubRect(sections: 8, index: 1, size: 1).getTwoButtonsHorizontal().right
                    
                case (_, .swapRight), (_, .swapBoth):
                    frame = rightButtonArea.getSubRect(sections: 8, index: 5, size: 4).getFourButtons().top
                    
                default:
                    frame = rightButtonArea.getSubRect(sections: 8, index: 2, size: 4).getFourButtons(inset: 10).top
                }
                
            case .genesis:
                switch Settings.standardSkinFeatures.inputsAndLayout.genesisFaceLayout
                {
                case .button3: break
                    
                case .button6:
                    if self.customButtonsEnabled()
                    {
                        frame = rightButtonArea.getSubRect(sections: 4, index: 2, size: 1).getThreeButton().right
                    }
                    else
                    {
                        frame = rightButtonArea.getSubRect(sections: 3, index: 1, size: 1).getThreeButton().right
                    }
                }
                
            default: break
            }
            
        case .l:
            switch gameType
            {
            case .gba, .snes, .ds:
                frame = leftButtonArea.getSubRect(sections: 4, index: 1, size: 1).getTwoButtonsHorizontal().left
                
            case .n64:
                switch (Settings.standardSkinFeatures.inputsAndLayout.n64ShoulderLayout, Settings.standardSkinFeatures.inputsAndLayout.n64FaceLayout)
                {
                case (.swapZL, .swapBoth), (.swapZL, .swapRight):
                    frame = rightButtonArea.getSubRect(sections: 8, index: 5, size: 4).getFourButtons().top
                    
                case (.swapZL, _):
                    frame = rightButtonArea.getSubRect(sections: 8, index: 2, size: 4).getFourButtons(inset: 10).top
                    
                default:
                    frame = leftButtonArea.getSubRect(sections: 8, index: 1, size: 1).getTwoButtonsHorizontal().left
                }
                
            default: break
            }
            
        case .r:
            switch gameType
            {
            case .gba, .snes, .ds:
                frame = rightButtonArea.getSubRect(sections: 4, index: 1, size: 1).getTwoButtonsHorizontal().right
                
            case .n64:
                switch (Settings.standardSkinFeatures.inputsAndLayout.n64ShoulderLayout, Settings.standardSkinFeatures.inputsAndLayout.n64FaceLayout)
                {
                case (.swapZR, .swapBoth), (.swapZR, .swapRight):
                    frame = rightButtonArea.getSubRect(sections: 8, index: 5, size: 4).getFourButtons().top
                    
                case (.swapZR, _):
                    frame = rightButtonArea.getSubRect(sections: 8, index: 2, size: 4).getFourButtons(inset: 10).top
                    
                default:
                    frame = rightButtonArea.getSubRect(sections: 8, index: 1, size: 1).getTwoButtonsHorizontal().right
                }
                
            default: break
            }
            
        case .cUp:
            switch gameType
            {
            case .n64:
                switch Settings.standardSkinFeatures.inputsAndLayout.n64FaceLayout
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
                switch Settings.standardSkinFeatures.inputsAndLayout.n64FaceLayout
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
                switch Settings.standardSkinFeatures.inputsAndLayout.n64FaceLayout
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
                switch Settings.standardSkinFeatures.inputsAndLayout.n64FaceLayout
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
            case .gbc, .nes:
                if self.customButtonsEnabled()
                {
                    frame = leftButtonArea.getSubRect(sections: 4, index: 4, size: 1).getTwoButtonsHorizontal().right
                }
                else
                {
                    frame = leftButtonArea.getSubRect(sections: 3, index: 3, size: 1).getTwoButtonsHorizontal().right
                }
                
            case .gba, .snes, .ds:
                frame = leftButtonArea.getSubRect(sections: 4, index: 4, size: 1).getTwoButtonsHorizontal().right
                
            default: break
            }
            
        case .start:
            switch gameType
            {
            case .gbc, .nes, .genesis, .ms, .gg:
                if self.customButtonsEnabled()
                {
                    frame = rightButtonArea.getSubRect(sections: 4, index: 4, size: 1).getTwoButtonsHorizontal().left
                }
                else
                {
                    frame = rightButtonArea.getSubRect(sections: 3, index: 3, size: 1).getTwoButtonsHorizontal().left
                }
                
            case .gba, .snes, .ds:
                frame = rightButtonArea.getSubRect(sections: 4, index: 4, size: 1).getTwoButtonsHorizontal().left
                
            case .n64:
                switch Settings.standardSkinFeatures.inputsAndLayout.n64FaceLayout
                {
                case .swapRight, .swapBoth:
                    frame = rightButtonArea.getSubRect(sections: 8, index: 5, size: 4).getFourButtons().left
                    
                default:
                    frame = rightButtonArea.getSubRect(sections: 8, index: 2, size: 4).getFourButtons(inset: 10).left
                }

            default: break
            }
            
        case .mode:
            switch gameType
            {
            case .genesis:
                if self.customButtonsEnabled()
                {
                    frame = leftButtonArea.getSubRect(sections: 4, index: 4, size: 1).getTwoButtonsHorizontal().right
                }
                else
                {
                    frame = leftButtonArea.getSubRect(sections: 3, index: 3, size: 1).getTwoButtonsHorizontal().right
                }
                
            default: break
            }
            
        case .quickSettings:
            switch gameType
            {
            case .gbc, .nes, .genesis, .ms, .gg:
                if self.customButtonsEnabled()
                {
                    frame = rightButtonArea.getSubRect(sections: 4, index: 4, size: 1).getTwoButtonsHorizontal().right
                }
                else
                {
                    frame = rightButtonArea.getSubRect(sections: 3, index: 3, size: 1).getTwoButtonsHorizontal().right
                }
                
            case .gba, .snes, .ds:
                frame = rightButtonArea.getSubRect(sections: 4, index: 4, size: 1).getTwoButtonsHorizontal().right
                
            case .n64:
                frame = rightButtonArea.getSubRect(sections: 8, index: 1, size: 1).getTwoButtonsHorizontal().left
                
            default: break
            }
            
        case .menu:
            switch gameType
            {
            case .gbc, .nes, .genesis, .ms, .gg:
                if self.customButtonsEnabled()
                {
                    frame = leftButtonArea.getSubRect(sections: 4, index: 4, size: 1).getTwoButtonsHorizontal().left
                }
                else
                {
                    frame = leftButtonArea.getSubRect(sections: 3, index: 3, size: 1).getTwoButtonsHorizontal().left
                }
                
            case .gba, .snes, .ds:
                frame = leftButtonArea.getSubRect(sections: 4, index: 4, size: 1).getTwoButtonsHorizontal().left
                
            case .n64:
                frame = leftButtonArea.getSubRect(sections: 8, index: 1, size: 1).getTwoButtonsHorizontal().right
                
            default: break
            }
            
        case .custom1:
            switch gameType
            {
            case .gba, .snes, .ds:
                frame = leftButtonArea.getSubRect(sections: 4, index: 1, size: 1).getTwoButtonsHorizontal().right
                
            case .gbc, .nes, .genesis, .ms, .gg:
                frame = leftButtonArea.getSubRect(sections: 4, index: 1, size: 1).getTwoButtonsHorizontal().left
                
            default: break
            }
            
        case .custom2:
            switch gameType
            {
            case .gba, .snes, .ds:
                frame = rightButtonArea.getSubRect(sections: 4, index: 1, size: 1).getTwoButtonsHorizontal().left
                
            case .gbc, .nes, .genesis, .ms, .gg:
                frame = rightButtonArea.getSubRect(sections: 4, index: 1, size: 1).getTwoButtonsHorizontal().right
                
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
        case .touchScreen, .toggleAltRepresentations, .thumbstick: return [:]
        default: return StandardControllerSkin.extendedEdges
        }
    }
    
    func assetName(_ gameType: GameType, isSplitView: Bool = false) -> String
    {
        switch self
        {
        case .dPad: return "dpad"
        case .a: return "a.circle"
        case .b:
            switch gameType
            {
            case .ms, .gg: return "1.circle"
            default: return "b.circle"
            }
            
        case .c:
            switch gameType
            {
            case .ms, .gg: return "2.circle"
            default: return "c.circle"
            }
            
        case .x: return "x.circle"
        case .y: return "y.circle"
        case .z:
            switch Settings.standardSkinFeatures.inputsAndLayout.n64ShoulderLayout
            {
            case .swapZL where gameType == .n64, .swapZR where gameType == .n64: return "z.square"
            default: return "z.circle"
            }
            
        case .l:
            switch Settings.standardSkinFeatures.inputsAndLayout.n64ShoulderLayout
            {
            case .swapZL where gameType == .n64: return "l.circle"
            default: return "l.square"
            }
            
        case .r:
            switch Settings.standardSkinFeatures.inputsAndLayout.n64ShoulderLayout
            {
            case .swapZR where gameType == .n64: return "r.circle"
            default: return "r.square"
            }
            
        case .thumbstick: return "circle"
        case .cUp: return "arrowtriangle.up.circle"
        case .cDown: return "arrowtriangle.down.circle"
        case .cLeft: return "arrowtriangle.left.circle"
        case .cRight: return "arrowtriangle.right.circle"
        case .start:
            switch gameType
            {
            case .ms, .gg, .genesis, .n64: return "s.circle"
            default: return "plus.circle"
            }
            
        case .select: return "minus.circle"
        case .mode: return "m.circle"
        case .menu: return "ellipsis.circle"
        case .toggleAltRepresentations: return "arrow.up.arrow.down.circle"
        case .quickSettings:
            switch Settings.gameplayFeatures.quickSettings.buttonReplacement
            {
            case .fastForward: return "forward.circle"
            case .quickSave: return "arrow.down.to.line.circle"
            case .quickLoad: return "arrow.up.to.line.circle"
            case .screenshot: return "camera.circle"
            case .restart: return "backward.end.circle"
            default: return "gearshape.circle"
            }
            
        case .custom1:
            switch Settings.standardSkinFeatures.inputsAndLayout.customButton1
            {
            case .fastForward: return "forward.circle"
            case .quickSave: return "arrow.down.to.line.circle"
            case .quickLoad: return "arrow.up.to.line.circle"
            case .screenshot: return "camera.circle"
            case .restart: return "backward.end.circle"
            default: return ""
            }
            
        case .custom2:
            if Settings.standardSkinFeatures.inputsAndLayout.dsScreenSwap, gameType == .ds, !isSplitView
            {
                return "arrow.up.arrow.down.circle"
            }
            else
            {
                switch Settings.standardSkinFeatures.inputsAndLayout.customButton2
                {
                case .fastForward: return "forward.circle"
                case .quickSave: return "arrow.down.to.line.circle"
                case .quickLoad: return "arrow.up.to.line.circle"
                case .screenshot: return "camera.circle"
                case .restart: return "backward.end.circle"
                default: return ""
                }
            }
            
        default: return ""
        }
    }
    
    func customButtonsEnabled() -> Bool
    {
        return Settings.standardSkinFeatures.inputsAndLayout.customButton1 != .null || Settings.standardSkinFeatures.inputsAndLayout.customButton2 != .null
    }
}
