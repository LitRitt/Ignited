//
//  GameScreenshot.swift
//  Delta
//
//  Created by Chris Rittenhouse on 4/24/23.
//  Copyright © 2023 Riley Testut. All rights reserved.
//

import SwiftUI

import Features

enum ScreenshotSize: Double, CaseIterable, CustomStringConvertible
{
    case x5 = 5
    case x4 = 4
    case x3 = 3
    case x2 = 2
    
    var description: String {
        if #available(iOS 15, *)
        {
            let formattedText = self.rawValue.formatted(.number.decimalSeparator(strategy: .automatic))
            return "\(formattedText)x Size"
        }
        else
        {
            return "\(self.rawValue)x Size"
        }
    }
}

extension ScreenshotSize: LocalizedOptionValue
{
    var localizedDescription: Text {
        Text(self.description)
    }
    
    static var localizedNilDescription: Text {
        Text("Original Size")
    }
}

struct GameScreenshotOptions
{
    @Option(name: "Image Size", description: "Choose the size of screenshots. This only increases the export size, it does not increase the quality.", values: ScreenshotSize.allCases)
    var size: ScreenshotSize?
    
    @Option(name: "Save to Files", description: "Save the screenshot to the app's directory in Files.")
    var saveToFiles: Bool = true
    
    @Option(name: "Save to Photos", description: "Save the screenshot to the Photo Library.")
    var saveToPhotos: Bool = false
    
    @Option(name: "Countdown", description: "After initiating a screenshot, play a 3 second countdown before capturing the screenshot.")
    var playCountdown: Bool = false
    
    @Option(name: "Restore Defaults",
            description: "Reset all options to their default values.",
            detailView: { _ in
        Button("Restore Defaults") {
            PowerUserOptions.resetFeature(.gameScreenshot)
        }
        .font(.system(size: 17, weight: .bold, design: .default))
        .foregroundColor(.red)
        .displayInline()
    })
    var resetGameScreenshots: Bool = false
}
