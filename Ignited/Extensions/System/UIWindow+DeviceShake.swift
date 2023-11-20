//
//  UIWindow+DeviceShake.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 10/31/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import UIKit

extension UIWindow
{
     open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?)
    {
        switch motion
        {
        case .motionShake: NotificationCenter.default.post(name: UIDevice.deviceDidShakeNotification, object: nil)
        default: break
        }
    }
}
