//
//  UILabel+UnplayedIcon.swift
//  Delta
//
//  Created by Chris Rittenhouse on 11/18/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import UIKit

extension UILabel
{
    func addDot(_ color: UIColor)
    {
        // Create icon renderer
        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 30, height: 30), format: format)
        
        // Create Attachment with dot icon
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = renderer.image { (context) in
            let ctx = context.cgContext
            
            ctx.saveGState()
            
            ctx.setFillColor(color.adjustBrightness(-0.4).cgColor)
            ctx.setShadow(offset: .zero, blur: 5, color: color.adjustBrightness(-0.5).cgColor)
            ctx.fillEllipse(in: CGRect(x: 5, y: 5, width: 20, height: 20))
            
            ctx.restoreGState()
            
            ctx.setFillColor(color.adjustBrightness(0.15).cgColor)
            ctx.fillEllipse(in: CGRect(x: 7, y: 7, width: 16, height: 16))
        }
        
        // Set bound to reposition
        // Constants are magic
        imageAttachment.bounds = CGRect(x: 0, y: -1 * (font.pointSize * 0.035), width: font.pointSize * 0.8, height: font.pointSize * 0.8)
        
        // Create string with attachment
        let attachmentString = NSAttributedString(attachment: imageAttachment)
        let finalString = NSMutableAttributedString(string: "")
        finalString.append(attachmentString)
        let textAfterIcon = NSAttributedString(string: " " + (text ?? ""))
        finalString.append(textAfterIcon)
        
        // Set attributed text to attachment string
        textAlignment = .center
        attributedText = finalString
    }
}
