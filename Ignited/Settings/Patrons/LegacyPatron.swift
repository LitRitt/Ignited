//
//  Patron.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 5/20/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import Foundation

struct LegacyPatron: Identifiable, Decodable
{
    var name: String
    
    var id: String {
        // Use names as identifiers for now.
        return self.name
    }
    
    var url: URL? {
        guard let link = self.link, let url = URL(string: link) else { return nil }
        return url
    }
    private var link: String?
    
    var linkName: String?
}

