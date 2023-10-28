//
//  DSFeatures.swift
//  Delta
//
//  Created by Chris Rittenhouse on 6/30/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import Features

extension Settings
{
    struct DSFeatures: FeatureContainer
    {
        static let shared = DSFeatures()

        @Feature(name: "DS AirPlay", options: DSAirPlayOptions())
        var dsAirPlay
        
        @Feature(name: "DSi Support")
        var dsiSupport

        private init()
        {
            self.prepareFeatures()
        }
    }
}
