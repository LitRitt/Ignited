//
//  FeaturesView.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 11/18/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import SwiftUI
import Combine

import Features

enum FeatureGroup: String, CaseIterable, CustomStringConvertible
{
    // Main Features
    case gameplay = "Gameplay"
    case controllers = "Controllers"
    case library = "Library"
    case userInterface = "User Interface"
    case touchFeedback = "Touch Feedback"
    case advanced = "Advanced"
    // Core Features
    case n64 = "Nintendo 64"
    case gbc = "Game Boy Color"
    
    var description: String {
        return self.rawValue
    }
    
    var container: FeatureContainer {
        switch self
        {
        case .gameplay: return Settings.gameplayFeatures
        case .controllers: return Settings.controllerFeatures
        case .library: return Settings.libraryFeatures
        case .userInterface: return Settings.userInterfaceFeatures
        case .touchFeedback: return Settings.touchFeedbackFeatures
        case .advanced: return Settings.advancedFeatures
        case .n64: return Settings.n64Features
        case .gbc: return Settings.gbcFeatures
        }
    }
}

extension FeaturesView
{
    private class ViewModel: ObservableObject
    {
        @Published
        var sortedFeatures: [any AnyFeature]
        
        init(featureContainer: FeatureContainer)
        {
            self.sortedFeatures = featureContainer.allFeatures.filter { !$0.hidden }
        }
    }
}

struct FeaturesView: View
{
    @StateObject
    private var viewModel: ViewModel
    
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

extension FeaturesView
{
    static func makeViewController(featureGroup: FeatureGroup) -> UIHostingController<some View>
    {
        let featuresViewModel = ViewModel(featureContainer: featureGroup.container)
        
        let featuresView = FeaturesView(viewModel: featuresViewModel)
        
        let hostingController = UIHostingController(rootView: featuresView)
        hostingController.title = NSLocalizedString(featureGroup.description, comment: "")
        return hostingController
    }
}
