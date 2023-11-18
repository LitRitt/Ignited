//
//  AdvancedFeaturesView.swift
//  Delta
//
//  Created by Chris Rittenhouse on 5/1/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import SwiftUI
import Combine

import Features

extension AdvancedFeaturesView
{
    private class ViewModel: ObservableObject
    {
        @Published
        var sortedFeatures: [any AnyFeature]
        
        init()
        {
            // Sort features alphabetically by name.
            let sortedFeatures = Settings.advancedFeatures.allFeatures.sorted { (featureA, featureB) in
                return String(describing: featureA.name) < String(describing: featureB.name)
            }
            
            self.sortedFeatures = sortedFeatures.filter { !$0.hidden }
        }
    }
}

struct AdvancedFeaturesView: View
{
    @StateObject
    private var viewModel: ViewModel = ViewModel()
    
    var body: some View {
        Form {
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

extension AdvancedFeaturesView
{
    static func makeViewController() -> UIHostingController<some View>
    {
        let featuresView = AdvancedFeaturesView()
        
        let hostingController = UIHostingController(rootView: featuresView)
        hostingController.title = NSLocalizedString("Advanced", comment: "")
        return hostingController
    }
}
