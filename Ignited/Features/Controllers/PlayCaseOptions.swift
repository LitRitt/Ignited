//
//  PlayCaseOptions.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 9/9/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import SwiftUI

import Features

struct PlayCaseOptions
{
    @Option(name: "Logo",
            description: "PlayCase is a phone case designed to enhance your mobile emulation experience by giving you physical buttons on top of your screen.",
            detailView: { _ in
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
        .displayInline()
    })
    var logo: Bool = false
    
    @Option(name: "Visit PlayCase",
            description: "Consider buying a PlayCase to support its creator, who strives to continue improving the product and provides excellent customer support!.",
            detailView: { _ in
        Button("Visit PlayCase") {
            UIApplication.shared.openWebpage(site: "https://playcase.gg")
        }
        .font(.system(size: 17, weight: .bold, design: .default))
        .foregroundColor(.accentColor)
        .displayInline()
    })
    var visitButton: Bool = false
    
    @Option(name: "Download Skins",
            description: "Tap here to download compatible skins from the PlayCase website.",
            detailView: { _ in
        Button("Download Skins") {
            UIApplication.shared.openWebpage(site: "https://playcase.gg/skins/")
        }
        .font(.system(size: 17, weight: .bold, design: .default))
        .foregroundColor(.accentColor)
        .displayInline()
    })
    var downloadSkins: Bool = false
}
