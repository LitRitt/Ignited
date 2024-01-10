//
//  ToastView.swift
//  AltStore
//
//  Created by Riley Testut on 7/19/19.
//  Copyright © 2019 Riley Testut. All rights reserved.
//

import UIKit

import Roxas

class ToastView: RSTToastView
{
    override init(text: String, detailText detailedText: String?)
    {
        super.init(text: text, detailText: detailedText)
        
        self.textLabel.textAlignment = .center
        
        self.layoutMargins = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        self.layer.cornerRadius = 16
    }
}

extension ToastView
{
    static func show(_ text: String, in view: UIView? = nil, detailText: String? = nil, onEdge presentationEdge: RSTViewEdge = .top, duration: Double = 2.0)
    {
        let toast = ToastView(text: text, detailText: detailText)
        toast.presentationEdge = presentationEdge
        
        if let view = view
        {
            toast.show(in: view, duration: duration)
        }
        else
        {
            guard let topViewController = UIApplication.shared.topViewController() else { return }
            
            toast.show(in: topViewController.view, duration: duration)
        }
    }
}
