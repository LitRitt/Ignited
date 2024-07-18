//
//  Campaign.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 7/18/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import Foundation

extension PatreonAPI
{
    struct CampaignResponse: Decodable
    {
        var id: String
    }
}

struct Campaign
{
    var identifier: String
        
    init(response: PatreonAPI.CampaignResponse)
    {
        self.identifier = response.id
    }
}
