//
//  PlayCaseView.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 9/14/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import UIKit
import SwiftUI
import Features

struct PlayCaseView: View {
    
    var body: some View {
        ZStack(alignment: .center) {
            Rectangle()
                .foregroundStyle(.clear)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            Image("PlayCaseLogo")
                .resizable()
                .blur(radius: 30)
                .opacity(0.2)
                .frame(maxWidth: 500)
            VStack(alignment: .center, spacing: 20) {
                HStack {
                    Image(systemName: "chevron.down")
                    Text("Swipe down to dismiss")
                    Image(systemName: "chevron.down")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.vertical, 12)
                
                PlayCaseLogoView()
                
                Text("Introducing PlayCase")
                    .font(.title)
                    .fontWeight(.semibold)
                Text("Precision and Protection")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text("""
The PlayCase combines durable phone protection with precise game controls. Just snap on a faceplate to transform your phone case into a retro controller. The number of supported devices and systems  is growing all the time, and customer support is top tier. Consider purchasing a PlayCase to support its creator and help the product develop and improve.

Ignited now works seamlessly with PlayCase, allowing you to access all settings and menus without removing the faceplate. This is done via the new PlayCase mode toggle available in Settings -> Controllers and Skins -> PlayCase Mode.
""")
                .font(.system(size: 15))
                
                HStack(spacing: 20) {
                    Button {
                        UIApplication.shared.openWebpage(site: PlayCaseOptions.affiliateURL)
                    } label: {
                        Label("Shop", image: "PlayCase")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundStyle(Color("PlayCasePink"))
                            .padding(10)
                    }.background(
                        Color(uiColor: .systemBackground).opacity(0.2)
                            .clipShape(RoundedRectangle(cornerRadius: 10)))
                    Button {
                        UIApplication.shared.openWebpage(site: PlayCaseOptions.videoURL)
                    } label: {
                        Label("Watch", systemImage: "play.circle.fill")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundStyle(Color("PlayCasePink"))
                            .padding(10)
                    }.background(
                        Color(uiColor: .systemBackground).opacity(0.2)
                            .clipShape(RoundedRectangle(cornerRadius: 10)))
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: 500)
        }
        .background(.ultraThinMaterial)
        .onDisappear {
            Settings.playCaseHasBeenSeen = true
        }
    }
}

extension PlayCaseView
{
    static func makeViewController() -> UIHostingController<some View>
    {
        let onboardingView = PlayCaseView()
        
        let hostingController = UIHostingController(rootView: onboardingView)
        hostingController.view.backgroundColor = .clear
        return hostingController
    }
}
