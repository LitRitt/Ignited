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
    var attributes: [FeatureAttribute]
    
    @Binding
    var selectedValue: Bool

    public var body: some View {
        let pro = self.attributes.contains(where: {$0 == .pro})
        let beta = self.attributes.contains(where: {$0 == .beta})
        
        return Toggle(isOn: $selectedValue) {
            Text(name).addProLabel(pro).addBetaLabel(beta)
        }
            .toggleStyle(SwitchToggleStyle(tint: .accentColor))
            .displayInline()
    }
}
