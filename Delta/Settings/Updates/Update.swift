//
//  Update.swift
//  Delta
//
//  Created by Chris Rittenhouse on 3/3/23.
//  Copyright © 2023 Riley Testut. All rights reserved.
//

import Foundation

struct Update: Identifiable, Decodable
{
    var version: String
    
    var id: String {
        // Use names as identifiers for now.
        return self.version
    }
    
    var url: URL? {
        guard let link = self.link, let url = URL(string: link) else { return nil }
        return url
    }
    private var link: String?

    var changes: [Change]
}

struct Change: Identifiable, Decodable
{
    var description: String
    
    var type: String
    
    var id: String {
        // Use names as identifiers for now.
        return self.description
    }
    
    var url: URL? {
        guard let link = self.link, let url = URL(string: link) else { return nil }
        return url
    }
    private var link: String?
}
