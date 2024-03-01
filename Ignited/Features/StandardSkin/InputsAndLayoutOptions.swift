//
//  InputsAndLayoutOptions.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 3/1/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import Features

import SwiftUI

enum StandardSkinDirectionalInputType: String, CaseIterable, CustomStringConvertible, LocalizedOptionValue
{
    case dPad = "D-Pad"
    case thumbstick = "Thumbstick"
    
    var description: String {
        return self.rawValue
    }
    
    var localizedDescription: Text {
        return Text(description)
    }
}

enum StandardSkinABXYLayout: String, CaseIterable, CustomStringConvertible, LocalizedOptionValue
{
    case nintendo = "Nintendo"
    case xbox = "Xbox"
    case swapAB = "Swap A/B"
    case swapXY = "Swap X/Y"
    
    var description: String {
        return self.rawValue
    }
    
    var localizedDescription: Text {
        return Text(description)
    }
}

enum StandardSkinN64FaceLayout: String, CaseIterable, CustomStringConvertible, LocalizedOptionValue
{
    case none = "Default"
    case swapLeft = "Swap Stick/D-Pad"
    case swapRight = "Swap Buttons/C"
    case swapBoth = "Swap Both"
    
    var description: String {
        return self.rawValue
    }
    
    var localizedDescription: Text {
        return Text(description)
    }
}

enum StandardSkinN64ShoulderLayout: String, CaseIterable, CustomStringConvertible, LocalizedOptionValue
{
    case none = "Default"
    case swapZL = "Swap Z/L"
    case swapZR = "Swap Z/R"
    
    var description: String {
        return self.rawValue
    }
    
    var localizedDescription: Text {
        return Text(description)
    }
}

enum StandardSkinGenesisFaceLayout: String, CaseIterable, CustomStringConvertible, LocalizedOptionValue
{
    case button3 = "3 Button"
    case button6 = "6 Button"
    
    var description: String {
        return self.rawValue
    }
    
    var localizedDescription: Text {
        return Text(description)
    }
}

struct InputsAndLayoutOptions
{
    @Option(name: "Custom Button 1",
            description: "Choose an input to use for custom button 1. Not available on N64.",
            values: [ActionInput.fastForward, ActionInput.quickSave, ActionInput.quickLoad, ActionInput.screenshot, ActionInput.restart])
    var customButton1: ActionInput = .fastForward
    
    @Option(name: "Custom Button 2",
            description: "Choose an input to use for custom button 2. Not available on N64.",
            values: [ActionInput.fastForward, ActionInput.quickSave, ActionInput.quickLoad, ActionInput.screenshot, ActionInput.restart])
    var customButton2: ActionInput = .quickSave
    
    @Option(name: "Directional Input",
            description: "Choose which input type to use for directional inputs. Does not affect N64.",
            values: StandardSkinDirectionalInputType.allCases)
    var directionalInputType: StandardSkinDirectionalInputType = .dPad
    
    @Option(name: "A,B,X,Y Layout",
            description: "Choose which layout to use for A, B, X, and Y inputs. Does not affect N64 or Sega systems.",
            values: StandardSkinABXYLayout.allCases)
    var abxyLayout: StandardSkinABXYLayout = .nintendo
    
    @Option(name: "N64 Face Layout",
            description: "Choose which layout to use for N64 face inputs. Swaps the top and bottom input groups on either or both sides.",
            values: StandardSkinN64FaceLayout.allCases)
    var n64FaceLayout: StandardSkinN64FaceLayout = .none
    
    @Option(name: "N64 Shoulder Layout",
            description: "Choose which layout to use for N64 shoulder inputs. Swaps the Z button with either L or R.",
            values: StandardSkinN64ShoulderLayout.allCases)
    var n64ShoulderLayout: StandardSkinN64ShoulderLayout = .none
    
    @Option(name: "Genesis Face Layout",
            description: "Choose which layout to use for Genesis face inputs. Change between the 3 button and 6 button layout.",
            values: StandardSkinGenesisFaceLayout.allCases)
    var genesisFaceLayout: StandardSkinGenesisFaceLayout = .button3
    
    @Option(name: "Extended Edges",
            description: "Change the value to use for extended edges on inputs. Extended edges increase the area around an input that will activate that input when touched.",
            range: 0...20,
            step: 1,
            unit: "pt")
    var extendedEdges: Double = 10
    
    @Option(name: "Restore Defaults",
            description: "Reset all options to their default values.",
            detailView: { _ in
        Button("Restore Defaults") {
            PowerUserOptions.resetFeature(.inputsAndLayout)
        }
        .font(.system(size: 17, weight: .bold, design: .default))
        .foregroundColor(.red)
        .displayInline()
    })
    var reset: Bool = false
}

