//
//  Patron.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 7/18/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import Foundation

extension PatreonAPI
{
    struct PatronResponse: Decodable
    {
        struct Attributes: Decodable
        {
            var full_name: String
            var patron_status: String?
        }
        
        struct Relationships: Decodable
        {
            struct Tiers: Decodable
            {
                struct TierID: Decodable
                {
                    var id: String
                    var type: String
                }
                
                var data: [TierID]
            }
            
            var currently_entitled_tiers: Tiers
        }
        
        var id: String
        var attributes: Attributes
        
        var relationships: Relationships?
    }
}

extension Patron
{
    enum Status: String, Decodable
    {
        case active = "active_patron"
        case declined = "declined_patron"
        case former = "former_patron"
        case unknown = "unknown"
    }
}

class Patron: Identifiable
{
    var name: String
    var identifier: String
    
    var id: String {
        return self.identifier
    }
    
    var status: Status
    
    var benefits: Set<Benefit> = []
    
    init(response: PatreonAPI.PatronResponse)
    {
        self.name = response.attributes.full_name
        self.identifier = response.id
        
        if let status = response.attributes.patron_status
        {
            self.status = Status(rawValue: status) ?? .unknown
        }
        else
        {
            self.status = .unknown
        }
    }
}
