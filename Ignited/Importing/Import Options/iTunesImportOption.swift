//
//  iTunesImportOption.swift
//  Ignited
//
//  Created by Riley Testut on 5/1/17.
//  Copyright © 2017 Riley Testut. All rights reserved.
//

import UIKit

import DeltaCore

struct iTunesImportOption: ImportOption
{
    let title = NSLocalizedString("From Folder", comment: "")
    let image: UIImage? = UIImage(systemName: "folder")
    
    private let presentingViewController: UIViewController
    
    init(presentingViewController: UIViewController)
    {
        self.presentingViewController = presentingViewController
    }
    
    func `import`(withCompletionHandler completionHandler: @escaping (Set<URL>?) -> Void)
    {
        DatabaseManager.shared.importFromFolder(completionHandler: completionHandler)
    }
}
