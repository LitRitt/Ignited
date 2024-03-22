//
//  AnyFeature.swift
//  DeltaFeatures
//
//  Created by Riley Testut on 4/12/23.
//  Copyright © 2023 Riley Testut. All rights reserved.
//

import SwiftUI

public typealias HiddenPredicate = () -> Bool

public enum FeatureAttribute: CaseIterable, Comparable, CustomStringConvertible
{
    case permanent
    case hidden(when: HiddenPredicate)
    case pro
    case beta
    
    public var description: String
    {
        switch self
        {
        case .permanent: return "Permanent"
        case .hidden: return "Hidden"
        case .pro: return "Pro"
        case .beta: return "Beta"
        }
    }
    
    public var predicate: HiddenPredicate
    {
        switch self
        {
        case .hidden(let predicate): return predicate
        default: return {false}
        }
    }
    
    public static var allCases: [FeatureAttribute]
    {
        return [.permanent, .hidden(when: {false}), .pro, .beta]
    }
    
    public static func < (lhs: FeatureAttribute, rhs: FeatureAttribute) -> Bool
    {
        return lhs.description < rhs.description
    }
    
    public static func == (lhs: FeatureAttribute, rhs: FeatureAttribute) -> Bool
    {
        return lhs.description == rhs.description
    }
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
    var hidden: HiddenPredicate { get }
    
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
