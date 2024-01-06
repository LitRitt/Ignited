//
//  Benefit.swift
//  AltStore
//
//  Created by Riley Testut on 8/21/19.
//  Copyright © 2019 Riley Testut. All rights reserved.
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
    case credit = "14405923"
    case pro = "14401724"
    case premium = "12920203"
    case testFlight = "14405936"
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
