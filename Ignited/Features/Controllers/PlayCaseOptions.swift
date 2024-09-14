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
            detailView: { _ in PlayCaseLogoView().displayInline() })
    var logo: Bool = false
    
    @Option(name: "Visit PlayCase",
            description: "Consider buying a PlayCase to support its creator, who strives to continue improving the product and provides excellent customer support!.",
            detailView: { _ in
        Button("Visit PlayCase") {
            UIApplication.shared.openWebpage(site: PlayCaseOptions.affiliateURL)
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
            UIApplication.shared.openWebpage(site: PlayCaseOptions.affiliateSkinsURL)
        }
        .font(.system(size: 17, weight: .bold, design: .default))
        .foregroundColor(.accentColor)
        .displayInline()
    })
    var downloadSkins: Bool = false
}

extension PlayCaseOptions {
    static var safeAreaBottomInset: Double {
        return Settings.controllerFeatures.playCase.isEnabled ? (UIScreen.main.bounds.height * 0.4) : 0
    }
    
    static var safeAreaEdgeInsets: EdgeInsets {
        return EdgeInsets(top: 0, leading: 0, bottom: safeAreaBottomInset, trailing: 0)
    }
}

extension PlayCaseOptions {
    static let affiliateURL: String = "https://playcase.gg/ref/LitRitt/"
    static let affiliateSkinsURL: String = "https://playcase.gg/skins/ref/LitRitt/"
    static let videoURL: String = "https://www.youtube.com/watch?v=2dDebK5G9FY&ab_channel=Buppin"
}
