//
//  GBCoreFeatures.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 3/21/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import SwiftUI

import GBCDeltaCore
import mGBADeltaCore

import Features

struct GBCoreOptions
{
    @Option(name: "Core Info",
            description: "Information about the current core",
            detailView: { _ in
        ForEach(Settings.preferredCore(for: .gbc)?.metadata?.sortedKeys ?? []) { key in
            if let item = Settings.preferredCore(for: .gbc)?.metadata?[key]
            {
                VStack {
                    if let url = item.url
                    {
                        Link(destination: url) {
                            HStack {
                                Text(key.rawValue)
                                    .foregroundColor(.primary)
                                Spacer()
                                Text(item.value)
                                    .foregroundColor(.gray)
                                Image(systemName: "chevron.forward")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                    else
                    {
                        HStack {
                            Text(key.rawValue)
                            Spacer()
                            Text(item.value)
                        }
                    }
                    
                    if let lastKey = Settings.preferredCore(for: .gbc)?.metadata?.sortedKeys?.last,
                       key != lastKey
                    {
                        Divider()
                    }
                }
            }
        }
        .displayInline()
    })
    var coreInfo: String = ""
    
    @Option(name: "Change Core",
            description: "Choose the core to use for GBC games.",
            detailView: { value in
        HStack {
            Spacer()
            Button("Choose Core") {
                GBCoreOptions.changeCore()
            }
            .foregroundColor(.red)
            Spacer()
        }
        .displayInline()
    })
    var coreName: String = Settings.preferredCore(for: .gbc)?.metadata?.name.value ?? mGBC.core.name
}

extension GBCoreOptions
{
    static func changeCore()
    {
        guard let topViewController = UIApplication.shared.topViewController() else { return }
        
        let alertController = UIAlertController(title: NSLocalizedString("Change Emulator Core", comment: ""), message: NSLocalizedString("Save states are not compatible between different emulator cores. Make sure to use in-game saves in order to keep using your save data.\n\nYour existing save states will not be deleted and will be available whenever you switch cores again.", comment: ""), preferredStyle: .actionSheet)
        alertController.preparePopoverPresentationController(topViewController.view)
        
        var gambatteActionTitle = GBC.core.metadata?.name.value ?? GBC.core.name
        var mgbcActionTitle = mGBC.core.metadata?.name.value ?? mGBC.core.name
        
        if Settings.preferredCore(for: .gbc) == GBC.core
        {
            gambatteActionTitle += " ✓"
        }
        else
        {
            mgbcActionTitle += " ✓"
        }
        
        alertController.addAction(UIAlertAction(title: gambatteActionTitle, style: .default, handler: { (action) in
            Settings.setPreferredCore(GBC.core, for: .gbc)
            Settings.gbFeatures.core.coreName = GBC.core.metadata?.name.value ?? GBC.core.name
        }))
        
        alertController.addAction(UIAlertAction(title: mgbcActionTitle, style: .default, handler: { (action) in
            Settings.setPreferredCore(mGBC.core, for: .gbc)
            Settings.gbFeatures.core.coreName = mGBC.core.metadata?.name.value ?? mGBC.core.name
        }))
        alertController.addAction(.cancel)
        topViewController.present(alertController, animated: true, completion: nil)
    }
}
