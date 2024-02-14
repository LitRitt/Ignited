//
//  AnyFeature.swift
//  DeltaFeatures
//
//  Created by Riley Testut on 4/12/23.
//  Copyright © 2023 Riley Testut. All rights reserved.
//

import SwiftUI

public enum FeatureAttribute: String, CaseIterable
{
    case permanent = "Permanent"
    case hidden = "Hidden"
    case pro = "Pro"
    case beta = "Beta"
}

@dynamicMemberLookup
public protocol AnyFeature<Options>: ObservableObject, Identifiable
{
    associatedtype Options = EmptyOptions
    
    var name: LocalizedStringKey { get }
    var description: LocalizedStringKey?  { get }
    var attributes: [FeatureAttribute] { get }
    
    var pro: Bool { get }
    var beta: Bool { get }
    var permanent: Bool { get }
    var hidden: Bool { get }
    
    var key: String  { get }
    var settingsKey: SettingsName { get }
    
    var isEnabled: Bool { get set }
    
    var allOptions: [any AnyOption] { get }
    
    subscript<T>(dynamicMember keyPath: KeyPath<Options, T>) -> T { get set }
}

extension AnyFeature
{
    public var id: String { self.key }
}

// Don't expose `key` setter via AnyFeature protocol.
internal protocol _AnyFeature: AnyFeature
{
    var key: String { get set }
}
