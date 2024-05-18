//
//  ControllerSkinsViewController.swift
//  Ignited
//
//  Created by Riley Testut on 10/19/16.
//  Copyright © 2016 Riley Testut. All rights reserved.
//

import UIKit

import DeltaCore

import Roxas

protocol ControllerSkinsViewControllerDelegate: AnyObject
{
    func controllerSkinsViewController(_ controllerSkinsViewController: ControllerSkinsViewController, didChooseControllerSkin controllerSkin: ControllerSkin)
    func controllerSkinsViewControllerDidResetControllerSkin(_ controllerSkinsViewController: ControllerSkinsViewController)
}

class ControllerSkinsViewController: UITableViewController
{
    weak var delegate: ControllerSkinsViewControllerDelegate?
    
    var system: System? {
        didSet {
            self.updateDataSource()
        }
    }
    
    var traits: DeltaCore.ControllerSkin.Traits! {
        didSet {
            self.updateDataSource()
        }
    }
    
    var isResetButtonVisible: Bool = true
    
    private let dataSource: RSTFetchedResultsTableViewPrefetchingDataSource<ControllerSkin, UIImage>
    
    @IBOutlet private var importControllerSkinButton: UIBarButtonItem!
    
    required init?(coder aDecoder: NSCoder)
    {
        self.dataSource = RSTFetchedResultsTableViewPrefetchingDataSource<ControllerSkin, UIImage>(fetchedResultsController: NSFetchedResultsController())
        
        super.init(coder: aDecoder)
        
        self.prepareDataSource()
    }
}

extension ControllerSkinsViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.tableView.dataSource = self.dataSource
        self.tableView.prefetchDataSource = self.dataSource
        
        self.importControllerSkinButton.accessibilityLabel = NSLocalizedString("Import Controller Skin", comment: "")
        
        if !self.isResetButtonVisible
        {
            self.navigationItem.rightBarButtonItems = [self.importControllerSkinButton]
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

private extension ControllerSkinsViewController
{
    //MARK: - Update
    func prepareDataSource()
    {
        self.dataSource.proxy = self
        self.dataSource.cellConfigurationHandler = { (cell, item, indexPath) in
            let cell = cell as! ControllerSkinTableViewCell
            
            cell.controllerSkinImageView.image = nil
            cell.activityIndicatorView.startAnimating()
        }
        
        self.dataSource.prefetchHandler = { [unowned self] (controllerSkin, indexPath, completionHandler) in
            let imageOperation = LoadControllerSkinImageOperation(controllerSkin: controllerSkin, traits: self.traits, size: UIScreen.main.previewSkinSize)
            imageOperation.resultHandler = { (image, error) in
                completionHandler(image, error)
            }
            
            return imageOperation
        }
        
        self.dataSource.prefetchCompletionHandler = { (cell, image, indexPath, error) in
            guard let image = image, let cell = cell as? ControllerSkinTableViewCell else { return }
            
            cell.controllerSkinImageView.image = image
            cell.activityIndicatorView.stopAnimating()
        }
    }
    
    func updateDataSource()
    {
        guard let traits = self.traits else { return }
        
        guard let configuration = ControllerSkinConfigurations(traits: traits) else { return }
        
        let fetchRequest: NSFetchRequest<ControllerSkin> = ControllerSkin.fetchRequest()
        
        if Settings.advancedFeatures.skinDebug.unsupportedSkins
        {
            let iphoneStandardConfiguration: ControllerSkinConfigurations = (traits.orientation == .landscape) ? .iphoneStandardLandscape : .iphoneStandardPortrait
            let iphoneEdgeToEdgeConfiguration: ControllerSkinConfigurations = (traits.orientation == .landscape) ? .iphoneEdgeToEdgeLandscape : .iphoneEdgeToEdgePortrait
            let ipadStandardConfiguration: ControllerSkinConfigurations = (traits.orientation == .landscape) ? .ipadStandardLandscape : .ipadStandardLandscape
            let ipadSplitViewConfiguration: ControllerSkinConfigurations = (traits.orientation == .landscape) ? .ipadSplitViewLandscape : .ipadSplitViewPortrait
            let tvStandardConfiguration: ControllerSkinConfigurations = (traits.orientation == .landscape) ? .tvStandardLandscape : .tvStandardPortrait
            
            if let system = self.system
            {
                fetchRequest.predicate = NSPredicate(format: "%K == %@ AND ((%K & %d) != 0 OR (%K & %d) != 0 OR (%K & %d) != 0 OR (%K & %d) != 0 OR (%K & %d) != 0)",
                                                     #keyPath(ControllerSkin.gameType), system.gameType.rawValue,
                                                     #keyPath(ControllerSkin.supportedConfigurations), iphoneStandardConfiguration.rawValue,
                                                     #keyPath(ControllerSkin.supportedConfigurations), iphoneEdgeToEdgeConfiguration.rawValue,
                                                     #keyPath(ControllerSkin.supportedConfigurations), ipadStandardConfiguration.rawValue,
                                                     #keyPath(ControllerSkin.supportedConfigurations), ipadSplitViewConfiguration.rawValue,
                                                     #keyPath(ControllerSkin.supportedConfigurations), tvStandardConfiguration.rawValue)
            }
            else
            {
                fetchRequest.predicate = NSPredicate(format: "(%K & %d) != 0 OR (%K & %d) != 0 OR (%K & %d) != 0 OR (%K & %d) != 0 OR (%K & %d) != 0",
                                                     #keyPath(ControllerSkin.supportedConfigurations), iphoneStandardConfiguration.rawValue,
                                                     #keyPath(ControllerSkin.supportedConfigurations), iphoneEdgeToEdgeConfiguration.rawValue,
                                                     #keyPath(ControllerSkin.supportedConfigurations), ipadStandardConfiguration.rawValue,
                                                     #keyPath(ControllerSkin.supportedConfigurations), ipadSplitViewConfiguration.rawValue,
                                                     #keyPath(ControllerSkin.supportedConfigurations), tvStandardConfiguration.rawValue)
            }
        }
        else
        {
            if let system = self.system
            {
                if traits.device == .iphone && traits.displayType == .edgeToEdge
                {
                    let fallbackConfiguration: ControllerSkinConfigurations = (traits.orientation == .landscape) ? .iphoneStandardLandscape : .iphoneStandardPortrait
                    
                    // Allow selecting skins that only support standard display types as well.
                    fetchRequest.predicate = NSPredicate(format: "%K == %@ AND ((%K & %d) != 0 OR (%K & %d) != 0)",
                                                         #keyPath(ControllerSkin.gameType), system.gameType.rawValue,
                                                         #keyPath(ControllerSkin.supportedConfigurations), configuration.rawValue,
                                                         #keyPath(ControllerSkin.supportedConfigurations), fallbackConfiguration.rawValue)
                }
                else
                {
                    fetchRequest.predicate = NSPredicate(format: "%K == %@ AND (%K & %d) != 0",
                                                         #keyPath(ControllerSkin.gameType), system.gameType.rawValue,
                                                         #keyPath(ControllerSkin.supportedConfigurations), configuration.rawValue)
                }
            }
            else
            {
                if traits.device == .iphone && traits.displayType == .edgeToEdge
                {
                    let fallbackConfiguration: ControllerSkinConfigurations = (traits.orientation == .landscape) ? .iphoneStandardLandscape : .iphoneStandardPortrait
                    
                    // Allow selecting skins that only support standard display types as well.
                    fetchRequest.predicate = NSPredicate(format: "(%K & %d) != 0 OR (%K & %d) != 0",
                                                         #keyPath(ControllerSkin.supportedConfigurations), configuration.rawValue,
                                                         #keyPath(ControllerSkin.supportedConfigurations), fallbackConfiguration.rawValue)
                }
                else
                {
                    fetchRequest.predicate = NSPredicate(format: "(%K & %d) != 0",
                                                         #keyPath(ControllerSkin.supportedConfigurations), configuration.rawValue)
                }
            }
        }
        
        if let _ = self.system
        {
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ControllerSkin.isStandard), ascending: false), NSSortDescriptor(key: #keyPath(ControllerSkin.name), ascending: true)]
        }
        else
        {
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ControllerSkin.isStandard), ascending: true), NSSortDescriptor(key: #keyPath(ControllerSkin.gameType), ascending: true), NSSortDescriptor(key: #keyPath(ControllerSkin.name), ascending: true)]
        }
        
        self.dataSource.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DatabaseManager.shared.viewContext, sectionNameKeyPath: #keyPath(ControllerSkin.name), cacheName: nil)
    }
    
    @IBAction func resetControllerSkin(_ sender: UIBarButtonItem)
    {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.popoverPresentationController?.barButtonItem = sender
        alertController.addAction(.cancel)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Reset Controller Skin to Default", comment: ""), style: .destructive, handler: { (action) in
            self.delegate?.controllerSkinsViewControllerDidResetControllerSkin(self)
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction private func importControllerSkin()
    {
        let importController = ImportController(documentTypes: ["com.litritt.ignited.skin"])
        importController.delegate = self
        self.present(importController, animated: true, completion: nil)
    }
}

extension ControllerSkinsViewController
{
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        let controllerSkin = self.dataSource.item(at: IndexPath(row: 0, section: section))
        return controllerSkin.name
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        let controllerSkin = self.dataSource.item(at: indexPath)
        return !controllerSkin.isStandard
    }
        
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        let controllerSkin = self.dataSource.item(at: indexPath)
        
        DatabaseManager.shared.performBackgroundTask { (context) in
            let controllerSkin = context.object(with: controllerSkin.objectID) as! ControllerSkin
            context.delete(controllerSkin)
            
            do
            {
                try context.save()
            }
            catch
            {
                print("Error deleting controller skin:", error)
            }
        }
    }
}

extension ControllerSkinsViewController
{
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        guard let window = self.view.window else { return }
        
        let controllerSkin = self.dataSource.item(at: indexPath)
        
        var deviceSupported = false
        var traits = DeltaCore.ControllerSkin.Traits.defaults(for: window)
        
        for displayType in DeltaCore.ControllerSkin.DisplayType.allCases
        {
            for orientation in DeltaCore.ControllerSkin.Orientation.allCases
            {
                traits.displayType = displayType
                traits.orientation = orientation
                
                if controllerSkin.supports(traits, alt: false)
                {
                    deviceSupported = true
                }
            }
        }
        
        if deviceSupported
        {
            self.delegate?.controllerSkinsViewController(self, didChooseControllerSkin: controllerSkin)
        }
        else
        {
            let alertController = UIAlertController(title: NSLocalizedString("Cannot Select Skin", comment: ""), message: NSLocalizedString("This skin does not support this device.", comment: ""), preferredStyle: .alert)
            alertController.addAction(.ok)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        let controllerSkin = self.dataSource.item(at: indexPath)
        
        let alt = Settings.advancedFeatures.skinDebug.useAlt
        guard let traits = controllerSkin.supportedTraits(for: self.traits, alt: alt) else
        {
            guard Settings.advancedFeatures.skinDebug.unsupportedSkins else { return 150 }
            
            var height = 200.0
            let safeHeight = (self.view.bounds.height - self.view.safeAreaInsets.top - self.view.safeAreaInsets.bottom - 30)
            if let size = controllerSkin.anyPreviewSize(for: self.traits, alt: alt)
            {
                let scale = (self.view.bounds.width / size.width)
                height = size.height * scale
            }
            return min(height, safeHeight)
        }
        
        var height = 200.0
        let safeHeight = (self.view.bounds.height - self.view.safeAreaInsets.top - self.view.safeAreaInsets.bottom - 30)
        if let size = controllerSkin.previewSize(for: traits, alt: alt)
        {
            let scale = (self.view.bounds.width / size.width)
            height = size.height * scale
        }
        return min(height, safeHeight)
    }
}

extension ControllerSkinsViewController: ImportControllerDelegate
{
    func importController(_ importController: ImportController, didImportItemsAt urls: Set<URL>, errors: [Error])
    {
        for error in errors
        {
            print(error)
        }
        
        if let error = errors.first
        {
            DispatchQueue.main.async {
                self.transitionCoordinator?.animate(alongsideTransition: nil) { _ in
                    // Wait until ImportController is dismissed before presenting alert.
                    let alertController = UIAlertController(title: NSLocalizedString("Failed to Import Controller Skin", comment: ""), error: error)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
            
            return
        }        
        
        let controllerSkinURLs = urls.filter { $0.pathExtension.lowercased() == "ignitedskin" || $0.pathExtension.lowercased() == "deltaskin" }
        DatabaseManager.shared.importControllerSkins(at: Set(controllerSkinURLs)) { (controllerSkins, errors) in
            if errors.count > 0
            {
                let alertController = UIAlertController.alertController(for: .controllerSkins, with: errors)
                self.present(alertController, animated: true, completion: nil)
            }
            
            if controllerSkins.count > 0,
               let window = self.view.window,
               Settings.libraryFeatures.importing.popup
            {
                let traits = DeltaCore.ControllerSkin.Traits.defaults(for: window)
                
                let alertController = UIAlertController.alertController(games: nil, controllerSkins: controllerSkins, traits: traits)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
}
