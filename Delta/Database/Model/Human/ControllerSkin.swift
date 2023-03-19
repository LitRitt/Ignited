//
//  ControllerSkin.swift
//  Delta
//
//  Created by Riley Testut on 8/30/16.
//  Copyright (c) 2016 Riley Testut. All rights reserved.
//

import Foundation

import DeltaCore
import Harmony

extension ControllerSkinConfigurations
{
    init(traits: DeltaCore.ControllerSkin.Traits)
    {
        switch (traits.displayType, traits.orientation)
        {
        case (.standard, .portrait): self = .standardPortrait
        case (.standard, .landscape): self = .standardLandscape
        case (.edgeToEdge, .portrait): self = .edgeToEdgePortrait
        case (.edgeToEdge, .landscape): self = .edgeToEdgeLandscape
        case (.splitView, .portrait): self = .splitViewPortrait
        case (.splitView, .landscape): self = .splitViewLandscape
        }
    }
}

@objc(ControllerSkin)
public class ControllerSkin: _ControllerSkin
{
    public var fileURL: URL {
        let fileURL = self.isStandard ? self.controllerSkin!.fileURL : DatabaseManager.controllerSkinsDirectoryURL(for: self.gameType).appendingPathComponent(self.filename)
        return fileURL
    }
    
    public var isDebugModeEnabled: Bool {
        return self.controllerSkin?.isDebugModeEnabled ?? false
    }
    
    public var hasAltRepresentations: Bool {
        return self.controllerSkin?.hasAltRepresentations ?? false
    }
    
    private lazy var controllerSkin: DeltaCore.ControllerSkin? = {
        let controllerSkin = self.isStandard ? DeltaCore.ControllerSkin.standardControllerSkin(for: self.gameType) : DeltaCore.ControllerSkin(fileURL: self.fileURL)
        return controllerSkin
    }()
    
    public override func awakeFromFetch()
    {
        super.awakeFromFetch()
        
        // Kinda hacky, but we initialize controllerSkin on fetch to ensure it is initialized on the correct thread
        // We could solve this by wrapping controllerSkin.getter in performAndWait block, but this can lead to a deadlock
        _ = self.controllerSkin
    }
}

extension ControllerSkin: ControllerSkinProtocol
{
    public func supports(_ traits: DeltaCore.ControllerSkin.Traits, alt: Bool) -> Bool
    {
        return self.controllerSkin?.supports(traits, alt: alt) ?? false
    }
    
    public func image(for traits: DeltaCore.ControllerSkin.Traits, preferredSize: DeltaCore.ControllerSkin.Size, alt: Bool) -> UIImage?
    {
        return self.controllerSkin?.image(for: traits, preferredSize: preferredSize, alt: alt)
    }
    
    public func thumbstick(for item: DeltaCore.ControllerSkin.Item, traits: DeltaCore.ControllerSkin.Traits, preferredSize: DeltaCore.ControllerSkin.Size, alt: Bool) -> (UIImage, CGSize)?
    {
        return self.controllerSkin?.thumbstick(for: item, traits: traits, preferredSize: preferredSize, alt: alt)
    }
    
    public func items(for traits: DeltaCore.ControllerSkin.Traits, alt: Bool) -> [DeltaCore.ControllerSkin.Item]?
    {
        return self.controllerSkin?.items(for: traits, alt: alt)
    }
    
    public func isTranslucent(for traits: DeltaCore.ControllerSkin.Traits, alt: Bool) -> Bool?
    {
        return self.controllerSkin?.isTranslucent(for: traits, alt: alt)
    }
    
    public func screens(for traits: DeltaCore.ControllerSkin.Traits, alt: Bool) -> [DeltaCore.ControllerSkin.Screen]?
    {
        return self.controllerSkin?.screens(for: traits, alt: alt)
    }
    
    public func aspectRatio(for traits: DeltaCore.ControllerSkin.Traits, alt: Bool) -> CGSize?
    {
        return self.controllerSkin?.aspectRatio(for: traits, alt: alt)
    }
    
    public func previewSize(for traits: DeltaCore.ControllerSkin.Traits, alt: Bool) -> CGSize?
    {
        return self.controllerSkin?.previewSize(for: traits, alt: alt)
    }
}

extension ControllerSkin: Syncable
{
    public static var syncablePrimaryKey: AnyKeyPath {
        return \ControllerSkin.identifier
    }
    
    public var syncableKeys: Set<AnyKeyPath> {
        return [\ControllerSkin.filename, \ControllerSkin.gameType, \ControllerSkin.name, \ControllerSkin.supportedConfigurations]
    }
    
    public var syncableFiles: Set<File> {
        return [File(identifier: "skin", fileURL: self.fileURL)]
    }
    
    public var isSyncingEnabled: Bool {
        return !self.isStandard
    }
    
    public var syncableLocalizedName: String? {
        return self.name
    }
}
