//
//  OptionToggleView.swift
//  DeltaFeatures
//
//  Created by Riley Testut on 4/11/23.
//  Copyright © 2023 Riley Testut. All rights reserved.
//

import SwiftUI

// Type must be public, but not its properties.
public struct OptionToggleView: View
{
    var name: LocalizedStringKey
    var pro: Bool
    
    @Binding
    var selectedValue: Bool

    public var body: some View {
        Toggle(isOn: $selectedValue) {
            Text(name) + Text(pro ? " (PRO)" : "").foregroundColor(.accentColor).bold()
        }
            .toggleStyle(SwitchToggleStyle(tint: .accentColor))
            .displayInline()
    }
}
