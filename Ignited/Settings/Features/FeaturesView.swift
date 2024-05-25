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
import DeltaCore

enum FeatureGroup: String, CaseIterable, CustomStringConvertible, Identifiable
{
    // Main Features
    case gameplay = "Gameplay"
    case standardSkin = "Standard Skins"
    case controllers = "Controllers and Skins"
    case airPlay = "AirPlay"
    case library = "Game Library"
    case userInterface = "User Interface"
    case touchFeedback = "Touch Feedback"
    case advanced = "Advanced"
    // Core Features
    case gbc = "Game Boy Color"
    case gba = "Game Boy Advance"
    
    var description: String {
        return self.rawValue
    }
    
    var id: String {
        return self.description
    }
    
    var container: FeatureContainer {
        switch self
        {
        case .gameplay: return Settings.gameplayFeatures
        case .standardSkin: return Settings.standardSkinFeatures
        case .controllers: return Settings.controllerFeatures
        case .airPlay: return Settings.airplayFeatures
        case .library: return Settings.libraryFeatures
        case .userInterface: return Settings.userInterfaceFeatures
        case .touchFeedback: return Settings.touchFeedbackFeatures
        case .advanced: return Settings.advancedFeatures
        case .gbc: return Settings.gbFeatures
        case .gba: return Settings.gbaFeatures
        }
    }
}

extension FeaturesView
{
    private class ViewModel: ObservableObject
    {
        private var featureContainer: FeatureContainer
        
        @Published
        var sortedFeatures: [any AnyFeature]
        
        init(featureContainer: FeatureContainer)
        {
            self.featureContainer = featureContainer
            self.sortedFeatures = featureContainer.allFeatures.filter { !$0.hidden() }
        }
        
        func updateSortedFeatures()
        {
            self.sortedFeatures = featureContainer.allFeatures.filter { !$0.hidden() }
        }
    }
}

struct FeaturesView: View
{
    @StateObject
    private var viewModel: ViewModel
    
    let settingsPublisher = NotificationCenter.default.publisher(for: .settingsDidChange)
    
    var body: some View {
        Form {
            ForEach(viewModel.sortedFeatures, id: \.key) { feature in
                section(for: feature)
            }
        }
        .listStyle(.insetGrouped)
        .onReceive(settingsPublisher, perform: { _ in
            self.viewModel.updateSortedFeatures()
        })
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
        
        var featuresView = FeaturesView(viewModel: featuresViewModel)
        
        let hostingController = UIHostingController(rootView: featuresView)
        hostingController.title = NSLocalizedString(featureGroup.description, comment: "")
        return hostingController
    }
}
