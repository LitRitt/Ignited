//
//  TouchFeedbackOverlay.swift
//  Delta
//
//  Created by Chris Rittenhouse on 4/29/23.
//  Copyright © 2023 Lit Development. All rights reserved.
//

import SwiftUI

import Features

struct TouchFeedbackOverlayOptions
{
    @Option(name: "Theme Color",
            description: "Enabled: Theme colored overlays. Disabled: White overlays.")
    var themed: Bool = true
    
    @Option(name: "Opacity", description: "The opacity of the overlays.", detailView: { opacity in
        VStack {
            HStack {
                Text("Opacity: \(opacity.wrappedValue * 100, specifier: "%.f")%")
                Spacer()
            }
            HStack {
                Text("15%")
                Slider(value: opacity, in: 0.15...1.00, step: 0.05)
                Text("100%")
            }
        }.displayInline()
    })
    var opacity: Double = 0.70
    
    @Option(name: "Size", description: "The size of the overlays.", detailView: { size in
        VStack {
            HStack {
                Text("Size: \(size.wrappedValue * 100, specifier: "%.f")%")
                Spacer()
            }
            HStack {
                Text("50%")
                Slider(value: size, in: 0.50...2.00, step: 0.05)
                Text("200%")
            }
        }.displayInline()
    })
    var size: Double = 1.00
}
