//
//  View+ProLabel.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 1/6/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import SwiftUI

public extension View
{
    @ViewBuilder
    func addProLabel(_ isPro: Bool = true) -> some View
    {
        if isPro
        {
            if #available(iOS 16, *)
            {
                HStack {
                    self
                    ZStack {
                        Color.accentColor
                            .frame(width: 30, height: 20, alignment: .center)
                            .clipShape(.capsule)
                        Text("PRO")
                            .font(.system(size: 15, weight: .bold, design: .default))
                            .fontWidth(.compressed)
                    }
                }
            }
            else
            {
                HStack {
                    self
                    ZStack {
                        Color.accentColor
                            .frame(width: 40, height: 20, alignment: .center)
                            .clipShape(.capsule)
                        Text("PRO")
                            .font(.system(size: 15, weight: .bold, design: .default))
                    }
                }
            }
        }
        else
        {
            self
        }
    }
}
