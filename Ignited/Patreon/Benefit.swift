//
//  Benefit.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 7/18/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import Foundation

extension PatreonAPI
{
    struct BenefitResponse: Decodable
    {
        var id: String
    }
}

enum BenefitType: String
{
    case credit = "14405936"
    case pro = "14401724"
    case premium = "12920203"
    case ota = "14390870"
}

struct Benefit: Hashable
{
    var type: BenefitType
    
    init(response: PatreonAPI.BenefitResponse)
    {
        self.type = BenefitType(rawValue: response.id) ?? .pro
    }
}
