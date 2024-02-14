//
//  OptionColorPickerView.swift
//  Features
//
//  Created by Chris Rittenhouse on 1/29/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import SwiftUI

// Type must be public, but not its properties.
public struct OptionColorPickerView<Value: LocalizedOptionValue>: View
{
    var name: LocalizedStringKey
    var transparency: Bool
    var attributes: [FeatureAttribute]
    
    @Binding
    var selectedValue: Color

    public var body: some View {
        ColorPicker(selection: $selectedValue, supportsOpacity: transparency) {
            proLabel
        }
        .displayInline()
    }
    
    var proLabel: some View {
        let pro = self.attributes.contains(where: {$0 == .pro})
        let beta = self.attributes.contains(where: {$0 == .beta})
        
        return Text(name).addProLabel(pro).addBetaLabel(beta)
    }
}
