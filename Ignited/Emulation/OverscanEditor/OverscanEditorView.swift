//
//  OverscanEditorView.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 1/13/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import UIKit

class OverscanEditorView: UIView
{
    @IBOutlet var applyButton: UIButton!
    @IBOutlet var resetButton: UIButton!
    @IBOutlet var doneButton: UIButton!
    
    @IBOutlet var topInsetIncreaseButton: UIButton!
    @IBOutlet var topInsetDecreaseButton: UIButton!
    @IBOutlet var topInsetLabel: UILabel!
    
    @IBOutlet var bottomInsetIncreaseButton: UIButton!
    @IBOutlet var bottomInsetDecreaseButton: UIButton!
    @IBOutlet var bottomInsetLabel: UILabel!
    
    @IBOutlet var leftInsetIncreaseButton: UIButton!
    @IBOutlet var leftInsetDecreaseButton: UIButton!
    @IBOutlet var leftInsetLabel: UILabel!
    
    @IBOutlet var rightInsetIncreaseButton: UIButton!
    @IBOutlet var rightInsetDecreaseButton: UIButton!
    @IBOutlet var rightInsetLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.topInsetIncreaseButton.setTitle("", for: .normal)
        self.topInsetDecreaseButton.setTitle("", for: .normal)
        self.bottomInsetIncreaseButton.setTitle("", for: .normal)
        self.bottomInsetDecreaseButton.setTitle("", for: .normal)
        self.leftInsetIncreaseButton.setTitle("", for: .normal)
        self.leftInsetDecreaseButton.setTitle("", for: .normal)
        self.rightInsetIncreaseButton.setTitle("", for: .normal)
        self.rightInsetDecreaseButton.setTitle("", for: .normal)
    }
}
