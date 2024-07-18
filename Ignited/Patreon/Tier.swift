//
//  Tier.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 7/18/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import Foundation

extension PatreonAPI
{
    struct TierResponse: Decodable
    {
        struct Attributes: Decodable
        {
            var title: String
        }
        
        struct Relationships: Decodable
        {
            struct Benefits: Decodable
            {
                var data: [BenefitResponse]
            }
            
            var benefits: Benefits
        }
        
        var id: String
        var attributes: Attributes
        
        var relationships: Relationships
    }
}

struct Tier
{
    var name: String
    var identifier: String
    
    var benefits: [Benefit] = []
    
    init(response: PatreonAPI.TierResponse)
    {
        self.name = response.attributes.title
        self.identifier = response.id
        self.benefits = response.relationships.benefits.data.map(Benefit.init(response:))
    }
}
