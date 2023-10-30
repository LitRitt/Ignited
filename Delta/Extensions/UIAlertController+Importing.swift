//
//  UIAlertController+Importing.swift
//  Delta
//
//  Created by Riley Testut on 1/13/17.
//  Copyright © 2017 Riley Testut. All rights reserved.
//

import UIKit

import DeltaCore
import Roxas

extension UIAlertController
{
    enum ImportType
    {
        case games
        case controllerSkins
    }
    
    class func alertController(for importType: ImportType, with errors: Set<DatabaseManager.ImportError>) -> UIAlertController
    {
        var urls = Set<URL>()
        
        for error in errors
        {
            switch error
            {
            case .doesNotExist(let url): urls.insert(url)
            case .invalid(let url): urls.insert(url)
            case .unsupported(let url): urls.insert(url)
            case .unknown(let url, _): urls.insert(url)
            case .saveFailed(let errorURLs, _): urls.formUnion(errorURLs)
            }
        }
        
        let title: String
        let message: String
        
        if let fileURL = urls.first, let error = errors.first, errors.count == 1
        {
            title = String(format: NSLocalizedString("Could not import “%@”.", comment: ""), fileURL.lastPathComponent)
            message = error.localizedDescription
        }
        else
        {
            switch importType
            {
            case .games: title = NSLocalizedString("Error Importing Games", comment: "")
            case .controllerSkins: title = NSLocalizedString("Error Importing Controller Skins", comment: "")
            }
            
            if urls.count > 0
            {
                var tempMessage: String
                
                switch importType
                {
                case .games: tempMessage = NSLocalizedString("The following game files could not be imported:", comment: "") + "\n"
                case .controllerSkins: tempMessage = NSLocalizedString("The following controller skin files could not be imported:", comment: "") + "\n"
                }
                
                let filenames = urls.map { $0.lastPathComponent }.sorted()
                for filename in filenames
                {
                    tempMessage += "\n" + filename
                }
                
                message = tempMessage
            }
            else
            {
                // This branch can be executed when there are no input URLs when importing, but there is an error saving the database anyway.
                
                switch importType
                {
                case .games: message = NSLocalizedString("Ignited was unable to import games. Please try again later.", comment: "")
                case .controllerSkins: message = NSLocalizedString("Ignited was unable to import controller skins. Please try again later.", comment: "")
                }
            }
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: RSTSystemLocalizedString("OK"), style: .cancel, handler: nil))
        return alertController
    }
    
    class func alertController(games: Set<Game>?, controllerSkins: Set<ControllerSkin>?, traits: DeltaCore.ControllerSkin.Traits?) -> UIAlertController
    {
        let title = NSLocalizedString("Import Successful", comment: "")
        var message: String = ""
        
        if let games = games
        {
            message += "🕹️ " + NSLocalizedString("The following games were imported:", comment: "")
            
            for game in games
            {
                message += "\n\n"
                if let gameCollection = game.gameCollection
                {
                    message += "✓ [" + gameCollection.shortName + "] " + game.name
                }
                else
                {
                    message += "✓ " + game.name
                }
            }
            
            if let _ = controllerSkins { message += "\n\n" }
        }
        
        if let controllerSkins = controllerSkins,
           let traits = traits
        {
            var supportedSkins: Bool = false
            var supportedMessage = "🎨 " + NSLocalizedString("The following controller skins were imported:", comment: "")
            
            var unsupportedSkins: Bool = false
            var unsupportedMessage = "⚠️ " + NSLocalizedString("The following controller skins were imported, but do NOT support this device:", comment: "")
            
            let deviceTraits = traits
            var traits = traits
            
            for controllerSkin in controllerSkins
            {
                var tempMessage: String = ""
                var supportedTraits: Bool = false
                
                for device in DeltaCore.ControllerSkin.Device.allCases
                {
                    for displayType in DeltaCore.ControllerSkin.DisplayType.allCases
                    {
                        for orientation in DeltaCore.ControllerSkin.Orientation.allCases
                        {
                            traits.device = device
                            traits.displayType = displayType
                            traits.orientation = orientation
                            
                            if controllerSkin.supports(traits, alt: false)
                            {
                                if traits.device == .ipad
                                {
                                    if deviceTraits.device == .ipad
                                    {
                                        tempMessage += "\n" + "• "
                                        if traits.displayType == .splitView { tempMessage += "SplitView " }
                                        tempMessage += (traits.orientation == .portrait ? "Portrait" : "Landscape")
                                        
                                        supportedTraits = true
                                    }
                                }
                                else if traits.device == .iphone
                                {
                                    if deviceTraits.device == traits.device,
                                       deviceTraits.displayType == traits.displayType
                                    {
                                        tempMessage += "\n" + "• " + (traits.orientation == .portrait ? "Portrait" : "Landscape")
                                        
                                        supportedTraits = true
                                    }
                                }
                                else if traits.device == .tv
                                {
                                    tempMessage += "\n" + "• AirPlay TV"
                                    
                                    supportedTraits = true
                                }
                            }
                        }
                    }
                }
                
                if supportedTraits
                {
                    supportedMessage += "\n\n" + "✓ " + controllerSkin.name
                    supportedMessage += tempMessage
                    supportedSkins = true
                }
                else
                {
                    unsupportedMessage += "\n\n" + "✓ " + controllerSkin.name
                    unsupportedSkins = true
                }
            }
            
            if supportedSkins
            {
                message += supportedMessage
                
                if unsupportedSkins
                {
                    message += "\n\n"
                }
            }
            
            if unsupportedSkins
            {
                message += unsupportedMessage
            }
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: RSTSystemLocalizedString("OK"), style: .cancel, handler: nil))
        return alertController
    }
}
