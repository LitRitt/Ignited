//
//  FeatureSectionView.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 5/2/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import SwiftUI

import Features

struct FeatureSection<T: AnyFeature>: View
{
    @ObservedObject
    var feature: T
    
    var body: some View {
        Section {
            if feature.allOptions.isEmpty
            {
                if feature.pro && !PurchaseManager.shared.hasUnlockedPro
                {
                    HStack {
                        Text(feature.name).addProLabel().addBetaLabel(feature.beta)
                        Spacer()
                    }.contentShape(Rectangle())
                        .onTapGesture {
                            ToastView.show(NSLocalizedString("Ignited Pro is required for this feature", comment: ""), onEdge: .bottom)
                    }
                }
                else
                {
                    Toggle(isOn: $feature.isEnabled) {
                        Text(feature.name).addProLabel(feature.pro).addBetaLabel(feature.beta)
                    }.toggleStyle(SwitchToggleStyle(tint: .accentColor))
                }
            }
            else
            {
                if feature.pro && !PurchaseManager.shared.hasUnlockedPro
                {
                    HStack {
                        Text(feature.name).addProLabel().addBetaLabel(feature.beta)
                        Spacer()
                    }.contentShape(Rectangle())
                        .onTapGesture {
                            ToastView.show(NSLocalizedString("Ignited Pro is required for this feature", comment: ""), onEdge: .bottom)
                    }
                }
                else
                {
                    NavigationLink(destination: FeatureDetailView(feature: feature)) {
                        if !feature.permanent {
                            Toggle(isOn: $feature.isEnabled) {
                                Text(feature.name).addProLabel(feature.pro).addBetaLabel(feature.beta)
                            }.toggleStyle(SwitchToggleStyle(tint: .accentColor))
                        } else {
                            Text(feature.name).addProLabel(feature.pro).addBetaLabel(feature.beta)
                        }
                    }
                }
            }
        } footer: {
            if let description = feature.description
            {
                Text(description)
            }
        }
    }
}

private struct FeatureDetailView<Feature: AnyFeature>: View
{
    @ObservedObject
    var feature: Feature
    
    @State
    var reload: Bool = false
    
    let settingsPublisher = NotificationCenter.default.publisher(for: .settingsDidChange)
    
    var body: some View {
        Form {
            ForEach(feature.allOptions.filter { !$0.hidden() }, id: \.key) { option in
                if let optionView = optionView(option)
                {
                    Section {
                        optionView
                    } footer: {
                        if let description = option.description
                        {
                            Text(description)
                        }
                    }
                }
            }
        }
        .onReceive(settingsPublisher, perform: { _ in
            reload.toggle()
        })
    }
    
    // Cannot open existential if return type uses concrete type T in non-covariant position (e.g. Box<T>).
    // So instead we erase return type to AnyView.
    private func optionView<T: AnyOption>(_ option: T) -> AnyView?
    {
        guard let view = OptionRow(option: option) else { return nil }
        return AnyView(view)
    }
}

private struct OptionRow<Option: AnyOption, DetailView: View>: View where DetailView == Option.DetailView
{
    let name: LocalizedStringKey
    let value: any LocalizedOptionValue
    let detailView: DetailView
    let pro: Bool
    let beta: Bool
    
    let option: Option
    
    @State
    private var displayInline: Bool = false
    
    init?(option: Option)
    {
        // Only show if option has a name, localizable value, and detailView.
        guard
            let name = option.name,
            let value = option.value as? any LocalizedOptionValue,
            let detailView = option.detailView()
        else { return nil }
        
        self.name = name
        self.value = value
        self.detailView = detailView
        self.pro = option.pro
        self.beta = option.beta
        
        self.option = option
    }
    
    var body: some View {
        VStack {
            let detailView = detailView
                .environment(\.managedObjectContext, DatabaseManager.shared.viewContext)
                .environment(\.featureOption, option)
            
            if pro && !PurchaseManager.shared.hasUnlockedPro
            {
                HStack {
                    Text(name).addProLabel().addBetaLabel(beta)
                    Spacer()
                }.contentShape(Rectangle())
                    .onTapGesture {
                        ToastView.show(NSLocalizedString("Ignited Pro is required for this option", comment: ""), onEdge: .bottom)
                }
            }
            else
            {
                if displayInline
                {
                    // Display entire view inline.
                    detailView
                }
                else
                {
                    let wrappedDetailView = Form {
                        detailView
                    }
                    
                    NavigationLink(destination: wrappedDetailView) {
                        HStack {
                            Text(name).addProLabel(pro).addBetaLabel(beta)
                            Spacer()
                            
                            value.localizedDescription
                                .foregroundColor(.secondary)
                        }
                    }
                    .overlay(
                        // Hack to ensure displayInline preference is in View hierarchy.
                        detailView
                            .hidden()
                            .frame(width: 0, height: 0)
                    )
                }
            }
        }
        .onPreferenceChange(DisplayInlineKey.self) { displayInline in
            self.displayInline = displayInline
        }
    }
}

