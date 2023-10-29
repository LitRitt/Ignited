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
    
    class func alertController(controllerSkins: Set<ControllerSkin>, traits: DeltaCore.ControllerSkin.Traits) -> UIAlertController
    {
        let title = NSLocalizedString("Import Successful", comment: "")
        
        var message = NSLocalizedString("The following controller skins were imported:", comment: "") + "\n"
        
        var traits = traits
        
        var traitsPortrait = traits
        traitsPortrait.orientation = .portrait
        
        var traitsLandscape = traits
        traitsLandscape.orientation = .landscape
        
        for controllerSkin in controllerSkins
        {
            message += "\n" + controllerSkin.name
            
            if controllerSkin.supports(traitsPortrait, alt: false)
            {
                message += "\n" + "* Your device is supported *"
            }
            else if controllerSkin.supports(traitsLandscape, alt: false)
            {
                message += "\n" + "* Your device is supported *"
            }
            else
            {
                message += "\n" + "* Your device is NOT supported *"
            }
            
            message += "\n" + "Supported traits:"
            
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
                            message += "\n" + traits.description
                        }
                    }
                }
            }
            
            message += "\n"
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: RSTSystemLocalizedString("OK"), style: .cancel, handler: nil))
        return alertController
    }
}
