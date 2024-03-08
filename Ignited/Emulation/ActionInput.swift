//
//  ActionInput.swift
//  Ignited
//
//  Created by Riley Testut on 8/28/17.
//  Copyright © 2017 Riley Testut. All rights reserved.
//

import DeltaCore

public extension GameControllerInputType
{
    static let action = GameControllerInputType("com.rileytestut.Delta.input.action")
}

enum ActionInput: String
{
    case null
    case restart
    case quickSave
    case quickLoad
    case screenshot
    case statusBar
    case quickSettings
    case fastForward
    case toggleFastForward
    case toggleAltRepresentations
}

extension ActionInput: Input
{
    var type: InputType {
        return .controller(.action)
    }
}
