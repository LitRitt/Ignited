//
//  FeaturesView.swift
//  Delta
//
//  Created by Chris Rittenhouse on 4/29/23.
//  Copyright © 2023 Lit Development. All rights reserved.
//

import SwiftUI
import Combine

import Features

extension FeaturesView
{
    private class ViewModel: ObservableObject
    {
        @Published
        var sortedFeatures: [any AnyFeature]
        
        init()
        {
            // Sort features alphabetically by name.
            self.sortedFeatures = Features.shared.allFeatures.sorted { (featureA, featureB) in
                return String(describing: featureA.name) < String(describing: featureB.name)
            }
        }
    }
}

struct FeaturesView: View
{
    @StateObject
    private var viewModel: ViewModel = ViewModel()
    
    var body: some View {
        Form {
            Section(content: {}, footer: {
                Text("These features have been added by contributors to the open-source Delta project on GitHub and are currently being tested.\n\nYou may encounter bugs when using these features.")
                    .font(.subheadline)
            })
            
            ForEach(viewModel.sortedFeatures, id: \.key) { feature in
                section(for: feature)
            }
        }
        .listStyle(.insetGrouped)
    }

    // Cannot open existential if return type uses concrete type T in non-covariant position (e.g. Box<T>).
    // So instead we erase return type to AnyView.
    private func section<T: AnyFeature>(for feature: T) -> AnyView
    {
        let section = FeatureSection(feature: feature)
        return AnyView(section)
    }
}

extension FeaturesView
{
    static func makeViewController() -> UIHostingController<some View>
    {
        let featuresView = FeaturesView()
        
        let hostingController = UIHostingController(rootView: featuresView)
        hostingController.title = NSLocalizedString("Features", comment: "")
        return hostingController
    }
}

private struct FeatureSection<T: AnyFeature>: View
{
    @ObservedObject
    var feature: T
    
    var body: some View {
        Section {
            NavigationLink(destination: FeatureDetailView(feature: feature)) {
                HStack {
                    Text(feature.name)
                    Spacer()
                    
                    if feature.isEnabled
                    {
                        Text("On")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }  footer: {
            if let description = feature.description
            {
                Text(description)
            }
        }
    }
}
