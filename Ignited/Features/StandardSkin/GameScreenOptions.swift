//
//  GameScreenOptions.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 3/1/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import DeltaCore
import Features

import SwiftUI

extension DeltaCore.GameViewStyle: CustomStringConvertible, LocalizedOptionValue
{
    public var description: String {
        return self.rawValue
    }
    
    public var localizedDescription: Text {
        return Text(description)
    }
}

enum GameScreenSize: String, CaseIterable, CustomStringConvertible, LocalizedOptionValue
{
    case fitInputs = "Fit Inputs"
    case fitDevice = "Fit Device"
    case fillDevice = "Fill Device"
    
    var description: String {
        return self.rawValue
    }
    
    var localizedDescription: Text {
        return Text(description)
    }
}

struct GameScreenOptions
{
    @Option(name: "Screen Style",
            description: "Choose the style to use for game screens.",
            values: DeltaCore.GameViewStyle.allCases)
    var style: DeltaCore.GameViewStyle = .floatingRounded
    
    @Option(name: "Landscape Screen Size",
            description: "Choose the size to use for game screens in landscape.",
            values: GameScreenSize.allCases)
    var landscapeSize: GameScreenSize = .fitInputs
    
    @Option(name: "DS Top Screen Size",
            description: "Change the size of the top screen on DS. A higher percentage makes the top screen bigger and the bottom screen smaller.",
            range: 0.2...0.8,
            step: 0.05,
            unit: "%",
            isPercentage: true)
    var dsTopScreenSize: Double = 0.5
    
    @Option(name: "Notch/Island Unsafe Area",
            description: "Adjust the unsafe area to avoid screens being drawn underneath an iPhone's notch or dynamic island.",
            range: 0...60,
            step: 1,
            unit: "pt",
            attributes: [.hidden(when: {hideUnsafeArea})])
    var unsafeArea: Double = 40
    
    @Option(name: "Restore Defaults",
            description: "Reset all options to their default values.",
            detailView: { _ in
        Button("Restore Defaults") {
            PowerUserOptions.resetFeature(.gameScreen)
        }
        .font(.system(size: 17, weight: .bold, design: .default))
        .foregroundColor(.red)
        .displayInline()
    })
    var reset: Bool = false
}

extension GameScreenOptions
{
    static var hideUnsafeArea: Bool
    {
        guard let topViewController = UIApplication.shared.topViewController(),
              let window = topViewController.view.window else
        {
            return false
        }
        
        let traits = DeltaCore.ControllerSkin.Traits.defaults(for: window)
        
        return !(traits.device == .iphone && traits.displayType == .edgeToEdge)
    }
}
