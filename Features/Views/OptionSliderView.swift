//
//  OptionSliderView.swift
//  Features
//
//  Created by Chris Rittenhouse on 1/29/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import SwiftUI

// Type must be public, but not its properties.
public struct OptionSliderView<Value: LocalizedOptionValue>: View
{
    var name: LocalizedStringKey
    var range: ClosedRange<Double>
    var step: Double
    var unit: LocalizedStringKey
    var decimals: Int?
    var isPercentage: Bool
    var attributes: [FeatureAttribute]
    
    @Binding
    var selectedValue: Double

    public var body: some View {
        VStack {
            HStack {
                proLabel
                Spacer()
            }
            HStack {
                formattedLowerBound
                Slider(value: $selectedValue, in: range, step: step)
                formattedUpperBound
            }
        }
        .displayInline()
    }
    
    var specifier: String {
        if let decimals = decimals
        {
            return "%.\(decimals)f"
        }
        else
        {
            return "%.f"
        }
    }
    
    var formattedLowerBound: some View {
        let formattedBound = isPercentage ? Text("\(range.lowerBound * 100, specifier: "\(specifier)")") : Text("\(range.lowerBound, specifier: "\(specifier)")")
        
        return formattedBound + Text(unit)
    }
    
    var formattedUpperBound: some View {
        let formattedBound = isPercentage ? Text("\(range.upperBound * 100, specifier: "\(specifier)")") : Text("\(range.upperBound, specifier: "\(specifier)")")
        
        return formattedBound + Text(unit)
    }
    
    var proLabel: some View {
        let pro = self.attributes.contains(where: {$0 == .pro})
        let beta = self.attributes.contains(where: {$0 == .beta})
        
        let formattedValue = isPercentage ? Text(": \(selectedValue * 100, specifier: "\(specifier)")") : Text(": \(selectedValue, specifier: "\(specifier)")")
        let formattedLabel = Text(name) + formattedValue + Text(unit)
        
        return formattedLabel.addProLabel(pro).addBetaLabel(beta)
    }
}
