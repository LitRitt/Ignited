//
//  SaveStatesOptions.swift
//  Delta
//
//  Created by Chris Rittenhouse on 11/9/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import SwiftUI

import Features

struct SaveStatesOptions
{
    @Option
    var autoLoad: Bool = true
    
    @Option
    var autoSave: Bool = true
}
