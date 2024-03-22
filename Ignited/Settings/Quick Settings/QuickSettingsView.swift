//
//  QuickSettingsView.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 5/14/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import SwiftUI

import Features
import DeltaCore

struct QuickSettingsView: View
{
    private var gameViewController: GameViewController
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Button("Main Menu") {
                        self.gameViewController.performMainMenuAction()
                    }.font(.system(size: 18, weight: .bold, design: .default))
                        .foregroundColor(.red)
                    Spacer()
                    Button("Pause Menu") {
                        self.gameViewController.performPauseAction()
                    }.font(.system(size: 18, weight: .bold, design: .default))
                }.buttonStyle(.bordered)
                    .padding(.top, 16)
                    .padding(.leading, 16)
                    .padding(.trailing, 16)
                
                List {
                    Section {
                        HStack {
                            VStack {
                                Button {
                                    self.gameViewController.performScreenshotAction()
                                } label: {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 30))
                                        .frame(width: 40, height: 40)
                                }
                                Text("Screenshot")
                                    .font(.caption)
                            }
                            Spacer()
                            VStack {
                                Button {
                                    self.gameViewController.performQuickSaveAction()
                                } label: {
                                    Image(systemName: "tray.and.arrow.down.fill")
                                        .font(.system(size: 30))
                                        .frame(width: 40, height: 40)
                                }
                                Text("Quick Save")
                                    .font(.caption)
                            }
                            Spacer()
                            VStack {
                                Button {
                                    self.gameViewController.performQuickLoadAction()
                                } label: {
                                    Image(systemName: "tray.and.arrow.up.fill")
                                        .font(.system(size: 30))
                                        .frame(width: 40, height: 40)
                                }
                                Text("Quick Load")
                                    .font(.caption)
                            }
                        }.buttonStyle(.borderless)
                    } header: {
                        Text("Quick Actions")
                    }
                    
                    Section {
                        ForEach(self.quickFeatures(for: self.gameViewController.game?.type)) { group in
                            NavigationLink(group.description, value: group)
                                .navigationDestination(for: FeatureGroup.self) { group in
                                    QuickFeaturesView.makeView(featureGroup: group)
                                }
                        }
                    } header: {
                        Text("Quick Settings")
                    }
                }.listStyle(.insetGrouped)
            }
        }.onDisappear() {
            NotificationCenter.default.post(name: .unwindFromSettings, object: nil, userInfo: [:])
        }.navigationTitle("Quick Settings")
    }
}

extension QuickSettingsView
{
    static func makeViewController(gameViewController: GameViewController) -> UIHostingController<some View>
    {
        let view = QuickSettingsView(gameViewController: gameViewController)
        
        let hostingController = UIHostingController(rootView: view)
        
        return hostingController
    }
    
    func quickFeatures(for gameType: GameType?) -> [FeatureGroup]
    {
        var features: [FeatureGroup] = [.gameplay, .standardSkin, .controllers, .touchFeedback, .airPlay, .userInterface]
        
        if let gameType = gameType,
           gameType == System.gbc.gameType
        {
            features.append(.gbc)
        }
        
        return features
    }
}

extension QuickFeaturesView
{
    private class QuickFeaturesViewModel: ObservableObject
    {
        @Published
        var sortedFeatures: [any AnyFeature]
        
        init(featureContainer: FeatureContainer)
        {
            self.sortedFeatures = featureContainer.allFeatures.filter { !$0.hidden() }
        }
    }
}

struct QuickFeaturesView: View
{
    @StateObject
    private var viewModel: QuickFeaturesViewModel
    
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

extension QuickFeaturesView
{
    static func makeView(featureGroup: FeatureGroup) -> some View
    {
        let featuresViewModel = QuickFeaturesViewModel(featureContainer: featureGroup.container)
        
        let featuresView = QuickFeaturesView(viewModel: featuresViewModel)
        
        return featuresView
    }
}


