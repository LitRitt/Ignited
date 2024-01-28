//
//  OptionPickerView.swift
//  Delta
//
//  Created by Riley Testut on 4/10/23.
//  Copyright © 2023 Riley Testut. All rights reserved.
//

import SwiftUI

// Type must be public, but not its properties.
public struct OptionPickerView<Value: LocalizedOptionValue>: View
{
    var name: LocalizedStringKey
    var options: [Value]
    var attributes: [FeatureAttribute]
    
    @Binding
    var selectedValue: Value

    public var body: some View {
        Picker(selection: $selectedValue, label: proLabel) {
            ForEach(options, id: \.self) { value in
                value.localizedDescription
            }
        }
        .pickerStyle(.menu)
        .displayInline()
    }
    
    var proLabel: some View {
        let pro = self.attributes.contains(where: {$0 == .pro})
        let beta = self.attributes.contains(where: {$0 == .beta})
        
        return Text(name).addProLabel(pro).addBetaLabel(beta)
    }
}
