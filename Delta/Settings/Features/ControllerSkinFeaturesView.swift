//
//  ControllerSkinFeaturesView.swift
//  Delta
//
//  Created by Chris Rittenhouse on 6/28/23.
//  Copyright © 2023 Lit Development. All rights reserved.
//

import SwiftUI
import Combine

import Features

extension ControllerSkinFeaturesView
{
    private class ViewModel: ObservableObject
    {
        @Published
        var sortedFeatures: [any AnyFeature]
        
        init()
        {
            // Sort features alphabetically by name.
            self.sortedFeatures = ControllerSkinFeatures.shared.allFeatures.sorted { (featureA, featureB) in
                return String(describing: featureA.name) < String(describing: featureB.name)
            }
        }
    }
}

struct ControllerSkinFeaturesView: View
{
    @StateObject
    private var viewModel: ViewModel = ViewModel()
    
    var body: some View {
        Form {
            Section(content: {}, footer: {
                Text("These features change how you interact with your games.")
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

extension ControllerSkinFeaturesView
{
    static func makeViewController() -> UIHostingController<some View>
    {
        let featuresView = ControllerSkinFeaturesView()
        
        let hostingController = UIHostingController(rootView: featuresView)
        hostingController.title = NSLocalizedString("Controller Skin Features", comment: "")
        return hostingController
    }
}