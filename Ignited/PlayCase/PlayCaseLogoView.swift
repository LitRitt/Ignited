//
//  PlayCaseLogoView.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 9/14/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import SwiftUI

struct PlayCaseLogoView: View {
    var body: some View {
        HStack {
            Image("PlayCaseLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
            Spacer()
            GifImageView("playcase")
                .frame(width: 70, height: 100, alignment: .center)
        }
        .frame(height: 100)
        .padding()
    }
}
