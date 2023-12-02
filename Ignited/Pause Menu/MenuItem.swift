//
//  MenuItem.swift
//  Ignited
//
//  Created by Riley Testut on 1/30/16.
//  Copyright © 2016 Riley Testut. All rights reserved.
//

import UIKit

// Must be class for use with Objective-C generics :(
class MenuItem: NSObject
{
    var text: String
    var image: UIImage?
    var action: ((MenuItem) -> Void)
    var holdAction: ((MenuItem) -> Void)?
    
    @objc dynamic var isSelected = false
    
    init(text: String, image: UIImage?, action: @escaping ((MenuItem) -> Void), holdAction: ((MenuItem) -> Void)? = nil)
    {
        self.image = image
        self.text = text
        self.action = action
        self.holdAction = holdAction
    }
}

extension MenuItem
{
    override func isEqual(_ object: Any?) -> Bool
    {
        guard let item = object as? MenuItem else { return false }
        return item.image == self.image && item.text == self.text
    }
}
