//
//  DSAirPlayOptions.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 6/30/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import SwiftUI

import Features
import DeltaCore

extension TouchControllerSkin.LayoutAxis: OptionValue {}

struct DSAirPlayOptions
{
    @Option
    var topScreenOnly: Bool = true

    @Option
    var layoutAxis: TouchControllerSkin.LayoutAxis = .vertical
}
