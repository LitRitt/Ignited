//
//  Array+LocalizedOptionValue.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 3/23/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import SwiftUI

import Features

extension Array: LocalizedOptionValue where Element: LocalizedOptionValue
{
    public var localizedDescription: Text {
        if Element.self == String.self
        {
            return Text("Edit")
        }
        else if Element.self == Double.self
        {
            return Text("Speeds")
        }
        else
        {
            return Text("Values")
        }
    }
}
