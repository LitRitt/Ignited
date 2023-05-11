//
//  GameCollectionViewController.swift
//  Delta
//
//  Created by Riley Testut on 8/12/16.
//  Copyright © 2016 Riley Testut. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation

import DeltaCore
import MelonDSDeltaCore
import Features

import Roxas
import Harmony

import SDWebImage

extension GameCollectionViewController
{
    private enum LaunchError: Error
    {
        case alreadyRunning
        case downloadingGameSave
        case biosNotFound
    }
}

class GameCollectionViewController: UICollectionViewController
{
    var gameCollection: GameCollection? {
        didSet {
            self.title = self.gameCollection?.shortName
            self.updateDataSource()
        }
    }
    
    var theme: Theme = .opaque {
        didSet {
            // self.collectionView?.reloadData()
            
            // Calling reloadData sometimes will not update the cells correctly if an insertion/deletion animation is in progress
            // As a workaround, we manually iterate over and configure each cell ourselves
            for cell in self.collectionView?.visibleCells ?? []
            {
                if let indexPath = self.collectionView?.indexPath(for: cell)
                {
                    self.configure(cell as! GridCollectionViewGameCell, for: indexPath)
                }
            }
        }
    }
    
    var minimumSpacing: CGFloat {
        get {
            let layout = self.collectionViewLayout as! GridCollectionViewLayout
            
            var minimumSpacing: CGFloat
            switch UserInterfaceFeatures.shared.artwork.size
            {
            case .small:
                minimumSpacing = 12
            case .medium:
                minimumSpacing = 16
            case .large:
                minimumSpacing = 20
            }
            
            if self.traitCollection.horizontalSizeClass == .regular
            {
                minimumSpacing *= 1.5
            }
            
            return minimumSpacing
        }
    }
    
    var itemWidth: CGFloat {
        get {
            let layout = self.collectionViewLayout as! GridCollectionViewLayout
            
            var itemsPerRow: CGFloat
            switch UserInterfaceFeatures.shared.artwork.size
            {
            case .small:
                itemsPerRow = 4.0
            case .medium:
                itemsPerRow = 3.0
            case .large:
                itemsPerRow = 2.0
            }
            
            if self.traitCollection.horizontalSizeClass == .regular
            {
                itemsPerRow = floor(itemsPerRow * 1.5)
            }
            
            let deviceWidth = UIScreen.main.fixedCoordinateSpace.bounds.width
            let itemWidth = floor((deviceWidth - (layout.minimumInteritemSpacing * (itemsPerRow + 1))) / itemsPerRow)
            
            return itemWidth
        }
    }
    
    internal let dataSource: RSTFetchedResultsCollectionViewPrefetchingDataSource<Game, UIImage>
    
    weak var activeEmulatorCore: EmulatorCore?
    
    private var activeSaveState: SaveStateProtocol?
    
    private let prototypeCell = GridCollectionViewGameCell()
    
    private var _performingPreviewTransition = false
    private weak var _previewTransitionViewController: PreviewGameViewController?
    private weak var _previewTransitionDestinationViewController: UIViewController?
    
    private weak var _popoverSourceView: UIView?
    
    private var _renameAction: UIAlertAction?
    private var _changingArtworkGame: Game?
    private var _importingSaveFileGame: Game?
    private var _exportedSaveFileURL: URL?
    
    required init?(coder aDecoder: NSCoder)
    {
        self.dataSource = RSTFetchedResultsCollectionViewPrefetchingDataSource<Game, UIImage>(fetchedResultsController: NSFetchedResultsController())

        super.init(coder: aDecoder)
        
        self.prepareDataSource()
    }
}

//MARK: - UIViewController -
/// UIViewController
extension GameCollectionViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.collectionView?.dataSource = self.dataSource
        self.collectionView?.prefetchDataSource = self.dataSource
        self.collectionView?.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameCollectionViewController.settingsDidChange(_:)), name: .settingsDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GameCollectionViewController.resumeCurrentGame), name: .resumePlaying, object: nil)
        
        self.update()
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        if _performingPreviewTransition
        {
            _performingPreviewTransition = false
            
            // Unlike our custom transitions, 3D Touch transition doesn't manually call appearance methods for us
            // To compensate, we call them ourselves
            _previewTransitionDestinationViewController?.beginAppearanceTransition(true, animated: true)
            
            self.transitionCoordinator?.animate(alongsideTransition: nil, completion: { (context) in
                self._previewTransitionDestinationViewController?.endAppearanceTransition()
                self._previewTransitionDestinationViewController = nil
            })
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?)
    {
        super.traitCollectionDidChange(previousTraitCollection)
        
        self.update()
    }
}

//MARK: - Segues -
/// Segues
extension GameCollectionViewController
{
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        guard let identifier = segue.identifier else { return }
        
        switch identifier
        {
        case "saveStates":
            let game = sender as! Game
            
            let saveStatesViewController = (segue.destination as! UINavigationController).topViewController as! SaveStatesViewController
            saveStatesViewController.delegate = self
            saveStatesViewController.game = game
            saveStatesViewController.mode = .loading
            saveStatesViewController.theme = self.theme
            
        case "preferredControllerSkins":
            let game = sender as! Game
            
            let preferredControllerSkinsViewController = (segue.destination as! UINavigationController).topViewController as! PreferredControllerSkinsViewController
            preferredControllerSkinsViewController.game = game

        case "unwindFromGames":
            let destinationViewController = segue.destination as! GameViewController
            let cell = sender as! UICollectionViewCell
            
            let indexPath = self.collectionView!.indexPath(for: cell)!
            let game = self.dataSource.item(at: indexPath)
            
            destinationViewController.game = game
            
            if let emulatorBridge = destinationViewController.emulatorCore?.deltaCore.emulatorBridge as? MelonDSEmulatorBridge
            {
                //TODO: Update this to work with multiple processes by retrieving emulatorBridge directly from emulatorCore.
                
                if game.identifier == Game.melonDSDSiBIOSIdentifier
                {
                    emulatorBridge.systemType = .dsi
                }
                else
                {
                    emulatorBridge.systemType = .ds
                }
                
                emulatorBridge.isJITEnabled = ProcessInfo.processInfo.isJITAvailable
            }
            
            if let saveState = self.activeSaveState
            {
                // Must be synchronous or else there will be a flash of black
                destinationViewController.emulatorCore?.start()
                destinationViewController.emulatorCore?.pause()
                
                do
                {
                    // don't load save states on DSi home screen
                    if game.identifier != Game.melonDSDSiBIOSIdentifier
                    {
                        try destinationViewController.emulatorCore?.load(saveState)
                    }
                }
                catch EmulatorCore.SaveStateError.doesNotExist
                {
                    print("Save State does not exist.")
                }
                catch
                {
                    print(error)
                }
                
                destinationViewController.emulatorCore?.resume()
            }
            
            self.activeSaveState = nil
            
            if _performingPreviewTransition
            {
                _previewTransitionDestinationViewController = destinationViewController
            }
            
        case "resumeCurrentGame":
            let destinationViewController = segue.destination as! GameViewController
            let game = sender as! Game
            
            destinationViewController.game = game
            
            if let emulatorBridge = destinationViewController.emulatorCore?.deltaCore.emulatorBridge as? MelonDSEmulatorBridge
            {
                //TODO: Update this to work with multiple processes by retrieving emulatorBridge directly from emulatorCore.
                
                if game.identifier == Game.melonDSDSiBIOSIdentifier
                {
                    emulatorBridge.systemType = .dsi
                }
                else
                {
                    emulatorBridge.systemType = .ds
                }
                
                emulatorBridge.isJITEnabled = ProcessInfo.processInfo.isJITAvailable
            }
            
            if let saveState = self.activeSaveState
            {
                // Must be synchronous or else there will be a flash of black
                destinationViewController.emulatorCore?.start()
                destinationViewController.emulatorCore?.pause()
                
                do
                {
                    // don't load save states on DSi home screen
                    if game.identifier != Game.melonDSDSiBIOSIdentifier
                    {
                        try destinationViewController.emulatorCore?.load(saveState)
                    }
                }
                catch EmulatorCore.SaveStateError.doesNotExist
                {
                    print("Save State does not exist.")
                }
                catch
                {
                    print(error)
                }
                
                destinationViewController.emulatorCore?.resume()
            }
            
            self.activeSaveState = nil
            
            if _performingPreviewTransition
            {
                _previewTransitionDestinationViewController = destinationViewController
            }
            
        default: break
        }
    }
    
    @IBAction private func unwindToGameCollectionViewController(_ segue: UIStoryboardSegue)
    {
    }
}

//MARK: - Private Methods -
private extension GameCollectionViewController
{
    func update()
    {
        let layout = self.collectionViewLayout as! GridCollectionViewLayout
        
        layout.minimumInteritemSpacing = self.minimumSpacing
        layout.itemWidth = self.itemWidth
        
        self.collectionView.reloadData()
    }
    
    //MARK: - Data Source
    func prepareDataSource()
    {
        self.dataSource.cellConfigurationHandler = { [weak self] (cell, item, indexPath) in
            self?.configure(cell as! GridCollectionViewGameCell, for: indexPath)
        }
        
        self.dataSource.prefetchHandler = { (game, indexPath, completionHandler) in
            guard let artworkURL = game.artworkURL else { return nil }
            
            let imageOperation = LoadImageURLOperation(url: artworkURL)
            imageOperation.resultHandler = { (image, error) in
                completionHandler(image, error)
            }
            
            return imageOperation
        }
        
        self.dataSource.prefetchCompletionHandler = { (cell, image, indexPath, error) in
            guard let image = image else { return }
            
            let cell = cell as! GridCollectionViewGameCell
            cell.imageView.image = image
            
            self.updateImage(cell: cell, image: image)
            
            let game = self.dataSource.item(at: indexPath)
            if let artworkURL = game.artworkURL,
               artworkURL.pathExtension.lowercased() == "gif"
            {
                guard let gifData = try? Data(contentsOf: artworkURL),
                      let source =  CGImageSourceCreateWithData(gifData as CFData, nil) else { return }
                
                var images = [UIImage]()
                let imageCount = CGImageSourceGetCount(source)
                for i in 0 ..< imageCount
                {
                    if let image = CGImageSourceCreateImageAtIndex(source, i, nil)
                    {
                        if i == 0
                        {
                            let pauseFrames = UserInterfaceFeatures.shared.artwork.isEnabled ? UserInterfaceFeatures.shared.artwork.animationPause : 20
                            for j in 0 ..< Int(floor(pauseFrames)) // replicate first image to create a delay between animations
                            {
                                images.append(UIImage(cgImage: image))
                            }
                        }
                        else
                        {
                            images.append(UIImage(cgImage: image))
                        }
                    }
                }
                
                let animationSpeed = UserInterfaceFeatures.shared.artwork.isEnabled ? UserInterfaceFeatures.shared.artwork.animationSpeed : 1.0
                
                cell.imageView.animationImages = images
                cell.imageView.animationDuration = Double(images.count) * 0.05 / animationSpeed
                cell.imageView.startAnimating()
            }
        }
    }
    
    func updateDataSource()
    {
        let fetchRequest: NSFetchRequest<Game> = Game.fetchRequest()
        
        if let gameCollection = self.gameCollection
        {
            fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(Game.gameCollection), gameCollection)
        }
        var sortDescriptors = [NSSortDescriptor(keyPath: \Game.isFavorite, ascending: false)]
        if UserInterfaceFeatures.shared.artwork.isEnabled && !UserInterfaceFeatures.shared.artwork.favoriteSort
        {
            sortDescriptors = []
        }
        
        switch UserInterfaceFeatures.shared.artwork.sortOrder
        {
        case .alphabeticalAZ:
            sortDescriptors.append(NSSortDescriptor(keyPath: \Game.name, ascending: true))
        case .alphabeticalZA:
            sortDescriptors.append(NSSortDescriptor(keyPath: \Game.name, ascending: false))
        case .mostRecent:
            sortDescriptors.append(NSSortDescriptor(keyPath: \Game.playedDate, ascending: false))
        case .leastRecent:
            sortDescriptors.append(NSSortDescriptor(keyPath: \Game.playedDate, ascending: true))
        }
        
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.returnsObjectsAsFaults = false
        
        self.dataSource.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DatabaseManager.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    //MARK: - Configure Cells
    func configure(_ cell: GridCollectionViewGameCell, for indexPath: IndexPath)
    {
        let game = self.dataSource.item(at: indexPath) as! Game
        
        cell.imageView.tintColor = UIColor.white
        cell.imageView.clipsToBounds = true
        cell.imageView.contentMode = .scaleToFill
        
        if UserInterfaceFeatures.shared.artwork.isEnabled
        {
            if UserInterfaceFeatures.shared.artwork.bgThemed
            {
                cell.imageView.backgroundColor = UIColor.themeColor.withAlphaComponent(UserInterfaceFeatures.shared.artwork.bgOpacity).darker(componentDelta: 0.1)
            }
            else
            {
                cell.imageView.backgroundColor = UIColor(cgColor: UserInterfaceFeatures.shared.artwork.bgColor.cgColor!).withAlphaComponent(UserInterfaceFeatures.shared.artwork.bgOpacity).darker(componentDelta: 0.1)
            }
            cell.imageView.layer.cornerRadius = UserInterfaceFeatures.shared.artwork.cornerRadius
            cell.imageView.layer.borderWidth = UserInterfaceFeatures.shared.artwork.borderWidth
            cell.layer.shadowOpacity = Float(UserInterfaceFeatures.shared.artwork.shadowOpacity)
        }
        else
        {
            cell.imageView.backgroundColor = UIColor.themeColor.darker(componentDelta: 0.1)
            cell.imageView.layer.cornerRadius = 15
            cell.imageView.layer.borderWidth = 1.2
            cell.layer.shadowOpacity = 0.5
        }
        
        cell.layer.shadowRadius = 3.0
        
        if let currentCore = self.activeEmulatorCore, game.fileURL == currentCore.game.fileURL
        {
            cell.layer.shadowColor = UIColor.themeColor.cgColor
            cell.layer.shadowOpacity = 1.0
            cell.layer.shadowRadius = 8.0
            cell.layer.shadowOffset = CGSize(width: 0, height: 0)
            cell.imageView.layer.borderColor = UIColor.themeColor.lighter(componentDelta: 0.1).cgColor
        }
        else
        {
            if UserInterfaceFeatures.shared.artwork.isEnabled,
               UserInterfaceFeatures.shared.artwork.favoriteHighlight,
               game.isFavorite
            {
                cell.layer.shadowColor = UserInterfaceFeatures.shared.artwork.favoriteColor.cgColor
                cell.layer.shadowOpacity = 1.0
                cell.layer.shadowRadius = 8.0
                cell.layer.shadowOffset = CGSize(width: 0, height: 0)
                cell.imageView.layer.borderColor = UIColor(cgColor: UserInterfaceFeatures.shared.artwork.favoriteColor.cgColor!).lighter(componentDelta: 0.1).cgColor
            }
            else
            {
                cell.layer.shadowColor = UIColor.black.cgColor
                cell.layer.shadowOffset = CGSize(width: 0, height: 3)
                cell.imageView.layer.borderColor = UIColor.ignitedLightGray.cgColor
            }
        }
        
        switch game.gameCollection?.system
        {
        case .nes: cell.imageView.image = #imageLiteral(resourceName: "NES")
        case .snes: cell.imageView.image = #imageLiteral(resourceName: "SNES")
        case .genesis: cell.imageView.image = #imageLiteral(resourceName: "GENESIS")
        case .n64: cell.imageView.image = #imageLiteral(resourceName: "N64")
        case .gbc: cell.imageView.image = #imageLiteral(resourceName: "GBC")
        case .gba: cell.imageView.image = #imageLiteral(resourceName: "GBA")
        case .ds: cell.imageView.image = #imageLiteral(resourceName: "DS")
        default: return
        }
        
        if self.traitCollection.horizontalSizeClass == .regular
        {
            let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .subheadline).withSymbolicTraits(.traitBold)!
            cell.textLabel.font = UIFont(descriptor: fontDescriptor, size: 0)
        }
        else
        {
            switch UserInterfaceFeatures.shared.artwork.size
            {
            case .small:
                cell.textLabel.font = UIFont.preferredFont(forTextStyle: .caption1).withSize(11)
            case .medium:
                cell.textLabel.font = UIFont.preferredFont(forTextStyle: .caption1).withSize(12)
            case .large:
                cell.textLabel.font = UIFont.preferredFont(forTextStyle: .caption1).withSize(13)
            }
        }
        
        let layout = self.collectionViewLayout as! GridCollectionViewLayout
        cell.imageSize = CGSize(width: layout.itemWidth, height: layout.itemWidth)
        
        cell.textLabel.text = game.isFavorite ? "☆ " + game.name : game.name
        cell.textLabel.textColor = UIColor.ignitedLightGray
    }
    
    func updateImage(cell: GridCollectionViewGameCell, image: UIImage)
    {
        let bounds = CGRect(x: 0, y: 0, width: self.itemWidth, height: self.itemWidth)
        let aspectRatio = image.size.width / image.size.height
        let maxOffset = self.itemWidth * 0.25
        
        var offset: CGFloat
        let adjustedBounds: CGRect
        
        if aspectRatio < 1 // Vertical
        {
            offset = (bounds.width - (bounds.height * aspectRatio)) / 2
            if offset > maxOffset { offset = maxOffset }
            adjustedBounds = CGRect(x: bounds.minX + offset, y: bounds.minY, width: bounds.width - (offset * 2), height: bounds.height)
            cell.verticalOffset = 0
        }
        else // Horizontal
        {
            offset = (bounds.height - (bounds.width / aspectRatio)) / 2
            if offset > maxOffset { offset = maxOffset }
            adjustedBounds = CGRect(x: bounds.minX, y: bounds.minY + offset, width: bounds.width, height: bounds.height - (offset * 2))
            cell.verticalOffset = offset
        }
        
        cell.aspectRatio = aspectRatio
        cell.imageSize = CGSize(width: adjustedBounds.width, height: adjustedBounds.height)
    }
    
    //MARK: - Emulation
    func launchGame(at indexPath: IndexPath, clearScreen: Bool, ignoreAlreadyRunningError: Bool = false)
    {
        func launchGame(ignoringErrors ignoredErrors: [Error])
        {
            let game = self.dataSource.item(at: indexPath)
            
            do
            {
                try self.validateLaunchingGame(game, ignoringErrors: ignoredErrors)
                
                if clearScreen
                {
                    self.activeEmulatorCore?.gameViews.forEach { $0.inputImage = nil }
                }
                
                let cell = self.collectionView.cellForItem(at: indexPath)
                
                if GameplayFeatures.shared.autoLoad.isEnabled
                {
                    let fetchRequest = SaveState.rst_fetchRequest() as! NSFetchRequest<SaveState>
                    fetchRequest.predicate = NSPredicate(format: "%K == %@ AND %K == %d", #keyPath(SaveState.game), game, #keyPath(SaveState.type), SaveStateType.auto.rawValue)
                    fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(SaveState.creationDate), ascending: true)]
                    
                    do
                    {
                        let saveStates = try game.managedObjectContext?.fetch(fetchRequest)
                        self.activeSaveState = saveStates?.last
                    }
                    catch
                    {
                        print(error)
                    }
                }
                
                self.performSegue(withIdentifier: "unwindFromGames", sender: cell)
            }
            catch LaunchError.alreadyRunning
            {
                let fetchRequest = SaveState.rst_fetchRequest() as! NSFetchRequest<SaveState>
                fetchRequest.predicate = NSPredicate(format: "%K == %@ AND %K == %d", #keyPath(SaveState.game), game, #keyPath(SaveState.type), SaveStateType.auto.rawValue)
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(SaveState.creationDate), ascending: true)]
                
                do
                {
                    let saveStates = try game.managedObjectContext?.fetch(fetchRequest)
                    self.activeSaveState = saveStates?.last
                }
                catch
                {
                    print(error)
                }
                
                // Disable videoManager to prevent flash of black
                self.activeEmulatorCore?.videoManager.isEnabled = false
                
                launchGame(ignoringErrors: [LaunchError.alreadyRunning])
                
                // The game hasn't changed, so the activeEmulatorCore is the same as before, so we need to enable videoManager it again
                self.activeEmulatorCore?.videoManager.isEnabled = true
            }
            catch LaunchError.downloadingGameSave
            {
                let alertController = UIAlertController(title: NSLocalizedString("Downloading Save File", comment: ""), message: NSLocalizedString("Please wait until after this game's save file has been downloaded before playing to prevent losing save data.", comment: ""), preferredStyle: .alert)
                alertController.addAction(.ok)
                self.present(alertController, animated: true, completion: nil)
            }
            catch LaunchError.biosNotFound
            {
                let alertController = UIAlertController(title: NSLocalizedString("Missing Required DS Files", comment: ""), message: NSLocalizedString("Ignited requires certain files to play Nintendo DS games. Please import them to launch this game.", comment: ""), preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: NSLocalizedString("Import Files", comment: ""), style: .default) { _ in
                    self.performSegue(withIdentifier: "showDSSettings", sender: nil)
                })
                alertController.addAction(.cancel)
                
                self.present(alertController, animated: true, completion: nil)
            }
            catch
            {
                let alertController = UIAlertController(title: NSLocalizedString("Unable to Launch Game", comment: ""), error: error)
                self.present(alertController, animated: true, completion: nil)
            }
        }
        
        if ignoreAlreadyRunningError
        {
            launchGame(ignoringErrors: [LaunchError.alreadyRunning])
        }
        else
        {
            launchGame(ignoringErrors: [])
        }
    }
    
    func validateLaunchingGame(_ game: Game, ignoringErrors ignoredErrors: [Error]) throws
    {
        let ignoredErrors = ignoredErrors.map { $0 as NSError }
        
        if !ignoredErrors.contains(where: { $0.domain == (LaunchError.alreadyRunning as NSError).domain && $0.code == (LaunchError.alreadyRunning as NSError).code })
        {
            guard game.fileURL != self.activeEmulatorCore?.game.fileURL else { throw LaunchError.alreadyRunning }
        }
        
        if let coordinator = SyncManager.shared.coordinator, coordinator.isSyncing
        {
            if let gameSave = game.gameSave
            {
                do
                {
                    if let record = try coordinator.recordController.fetchRecords(for: [gameSave]).first
                    {
                        if record.isSyncingEnabled && !record.isConflicted && (record.localStatus == nil || record.remoteStatus == .updated)
                        {
                            throw LaunchError.downloadingGameSave
                        }
                    }
                }
                catch let error as LaunchError
                {
                    throw error
                }
                catch
                {
                    print("Error fetching record for game save.", error)
                }
            }
        }
        
        if game.type == .ds && Settings.preferredCore(for: .ds) == MelonDS.core
        {
            if game.identifier == Game.melonDSDSiBIOSIdentifier
            {
                guard
                    FileManager.default.fileExists(atPath: MelonDSEmulatorBridge.shared.dsiBIOS7URL.path) &&
                    FileManager.default.fileExists(atPath: MelonDSEmulatorBridge.shared.dsiBIOS9URL.path) &&
                    FileManager.default.fileExists(atPath: MelonDSEmulatorBridge.shared.dsiFirmwareURL.path) &&
                    FileManager.default.fileExists(atPath: MelonDSEmulatorBridge.shared.dsiNANDURL.path)
                else { throw LaunchError.biosNotFound }
            }
            else
            {
                guard
                    FileManager.default.fileExists(atPath: MelonDSEmulatorBridge.shared.bios7URL.path) &&
                    FileManager.default.fileExists(atPath: MelonDSEmulatorBridge.shared.bios9URL.path) &&
                    FileManager.default.fileExists(atPath: MelonDSEmulatorBridge.shared.firmwareURL.path)
                else { throw LaunchError.biosNotFound }
            }
        }
    }
    
    @objc func resumeCurrentGame()
    {
        guard let emulatorCore = self.activeEmulatorCore else { return }
        guard let game = emulatorCore.game as? Game else { return }
        
        let fetchRequest = SaveState.rst_fetchRequest() as! NSFetchRequest<SaveState>
        fetchRequest.predicate = NSPredicate(format: "%K == %@ AND %K == %d", #keyPath(SaveState.game), game, #keyPath(SaveState.type), SaveStateType.auto.rawValue)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(SaveState.creationDate), ascending: true)]
        
        do
        {
            let saveStates = try game.managedObjectContext?.fetch(fetchRequest)
            self.activeSaveState = saveStates?.last
        }
        catch
        {
            print(error)
        }
        
        self.performSegue(withIdentifier: "resumeCurrentGame", sender: game)
    }
}

//MARK: - Game Actions -
private extension GameCollectionViewController
{
    func actions(for game: Game) -> [Action]
    {
        let cancelAction = Action(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, action: nil)
        
        let renameAction = Action(title: NSLocalizedString("Rename", comment: ""), style: .default, image: UIImage(symbolNameIfAvailable: "pencil.and.ellipsis.rectangle"), action: { [unowned self] action in
            self.rename(game)
        })
        
        let changeArtworkAction = Action(title: NSLocalizedString("Change Artwork", comment: ""), style: .default, image: UIImage(symbolNameIfAvailable: "photo")) { [unowned self] action in
            self.changeArtwork(for: game)
        }
        
        let changeControllerSkinAction = Action(title: NSLocalizedString("Change Controller Skin", comment: ""), style: .default, image: UIImage(symbolNameIfAvailable: "gamecontroller")) { [unowned self] _ in
            self.changePreferredControllerSkin(for: game)
        }
        
        let shareAction = Action(title: NSLocalizedString("Share", comment: ""), style: .default, image: UIImage(symbolNameIfAvailable: "square.and.arrow.up"), action: { [unowned self] action in
            self.share(game)
        })
        
        let saveStatesAction = Action(title: NSLocalizedString("Save States", comment: ""), style: .default, image: UIImage(symbolNameIfAvailable: "doc.on.doc"), action: { [unowned self] action in
            self.viewSaveStates(for: game)
        })
        
        let importSaveFile = Action(title: NSLocalizedString("Import Save File", comment: ""), style: .default, image: UIImage(symbolNameIfAvailable: "tray.and.arrow.down")) { [unowned self] _ in
            self.importSaveFile(for: game)
        }
        
        let exportSaveFile = Action(title: NSLocalizedString("Export Save File", comment: ""), style: .default, image: UIImage(symbolNameIfAvailable: "tray.and.arrow.up")) { [unowned self] _ in
            self.exportSaveFile(for: game)
        }
        
        let deleteAction = Action(title: NSLocalizedString("Delete", comment: ""), style: .destructive, image: UIImage(symbolNameIfAvailable: "trash"), action: { [unowned self] action in
            self.delete(game)
        })
        
        let favoriteAction: Action
        if UserInterfaceFeatures.shared.artwork.favoriteGames[game.type.rawValue]!.contains(game.identifier)
        {
            favoriteAction = Action(title: NSLocalizedString("Remove Favorite", comment: ""), style: .default, image: UIImage(symbolNameIfAvailable: "star.slash"), action: { [unowned self] action in
                self.removeFavoriteGame(for: game)
            })
        }
        else
        {
            favoriteAction = Action(title: NSLocalizedString("Add Favorite", comment: ""), style: .default, image: UIImage(symbolNameIfAvailable: "star"), action: { [unowned self] action in
                self.addFavoriteGame(for: game)
            })
        }
        
        switch game.type
        {
        case GameType.unknown:
            return [cancelAction, favoriteAction, renameAction, changeArtworkAction, shareAction, deleteAction]
        case .ds where game.identifier == Game.melonDSBIOSIdentifier || game.identifier == Game.melonDSDSiBIOSIdentifier:
            return [cancelAction, favoriteAction, renameAction, changeArtworkAction, changeControllerSkinAction, saveStatesAction]
        default:
            return [cancelAction, favoriteAction, renameAction, changeArtworkAction, changeControllerSkinAction, shareAction, saveStatesAction, importSaveFile, exportSaveFile, deleteAction]
        }
    }
    
    func delete(_ game: Game)
    {
        let confirmationAlertController = UIAlertController(title: NSLocalizedString("Are you sure you want to delete this game?", comment: ""),
                                                            message: NSLocalizedString("All associated data, such as saves, save states, and cheat codes, will also be deleted.", comment: ""),
                                                            preferredStyle: .alert)
        confirmationAlertController.addAction(UIAlertAction(title: NSLocalizedString("Delete Game", comment: ""), style: .destructive, handler: { action in
            
            DatabaseManager.shared.performBackgroundTask { (context) in
                let temporaryGame = context.object(with: game.objectID) as! Game
                context.delete(temporaryGame)
                
                context.saveWithErrorLogging()
            }
            
        }))
        confirmationAlertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        
        self.present(confirmationAlertController, animated: true, completion: nil)
    }
    
    func viewSaveStates(for game: Game)
    {
        self.performSegue(withIdentifier: "saveStates", sender: game)
    }
    
    func rename(_ game: Game)
    {
        let alertController = UIAlertController(title: NSLocalizedString("Rename Game", comment: ""), message: nil, preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.text = game.name
            textField.placeholder = NSLocalizedString("Name", comment: "")
            textField.autocapitalizationType = .words
            textField.returnKeyType = .done
            textField.enablesReturnKeyAutomatically = true
            textField.addTarget(self, action: #selector(GameCollectionViewController.textFieldTextDidChange(_:)), for: .editingChanged)
        }
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
            self._renameAction = nil
        }))
        
        let renameAction = UIAlertAction(title: NSLocalizedString("Rename", comment: ""), style: .default, handler: { [unowned alertController] (action) in
            self.rename(game, with: alertController.textFields?.first?.text ?? "")
        })
        alertController.addAction(renameAction)
        self._renameAction = renameAction
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func rename(_ game: Game, with name: String)
    {
        guard name.count > 0 else { return }

        DatabaseManager.shared.performBackgroundTask { (context) in
            let game = context.object(with: game.objectID) as! Game
            game.name = name
            
            context.saveWithErrorLogging()
        }
        
        self._renameAction = nil
    }
    
    func changeArtwork(for game: Game)
    {
        self._changingArtworkGame = game
        
        let clipboardImportOption = ClipboardImportOption()
        let photoLibraryImportOption = PhotoLibraryImportOption(presentingViewController: self)
        let gamesDatabaseImportOption = GamesDatabaseImportOption(presentingViewController: self)
        
        let importController = ImportController(documentTypes: [kUTTypeImage as String])
        importController.delegate = self
        importController.importOptions = [clipboardImportOption, photoLibraryImportOption, gamesDatabaseImportOption]
        importController.sourceView = self._popoverSourceView
        self.present(importController, animated: true, completion: nil)
    }
    
    func changeArtwork(for game: Game, toImageAt url: URL?, errors: [Error])
    {
        defer {
            if let temporaryImageURL = url
            {
                try? FileManager.default.removeItem(at: temporaryImageURL)
            }
        }
        
        var errors = errors
        
        var imageURL: URL?
        
        if let url = url
        {
            if url.isFileURL
            {
                do
                {
                    let imageData = try Data(contentsOf: url)
                    
                    if url.pathExtension.lowercased() == "gif" || ImageFormat.get(from: imageData) == .gif
                    {
                        let destinationURL = DatabaseManager.artworkGifURL(for: game)
                        try imageData.write(to: destinationURL, options: .atomic)
                        
                        imageURL = destinationURL
                    }
                    else if let image = UIImage(data: imageData),
                            let resizedImage = image.resizing(toFit: CGSize(width: 300, height: 300)),
                            let rotatedImage = resizedImage.rotatedToIntrinsicOrientation(), // in case image was imported directly from Files
                            let resizedData = rotatedImage.pngData()
                    {
                        let destinationURL = DatabaseManager.artworkURL(for: game)
                        try resizedData.write(to: destinationURL, options: .atomic)
                        
                        imageURL = destinationURL
                    }
                }
                catch
                {
                    errors.append(error)
                }
            }
            else
            {
                imageURL = url
            }
        }
        
        for error in errors
        {
            print(error)
        }
        
        if let imageURL = imageURL
        {
            self.dataSource.prefetchItemCache.removeObject(forKey: game)
            
            if let cacheManager = SDWebImageManager.shared()
            {
                let cacheKey = cacheManager.cacheKey(for: imageURL)
                cacheManager.imageCache.removeImage(forKey: cacheKey)
            }
            
            DatabaseManager.shared.performBackgroundTask { (context) in
                let temporaryGame = context.object(with: game.objectID) as! Game
                temporaryGame.artworkURL = imageURL
                context.saveWithErrorLogging()
                
                // Local image URLs may not change despite being a different image, so manually mark record as updated.
                SyncManager.shared.recordController?.updateRecord(for: temporaryGame)
                
                DispatchQueue.main.async {
                    if let indexPath = self.dataSource.fetchedResultsController.indexPath(forObject: game)
                    {
                        // Manually reload item because collection view may not be in window hierarchy,
                        // which means it won't automatically update when we save the context.
                        self.collectionView.reloadItems(at: [indexPath])
                    }
                    
                    self.presentedViewController?.dismiss(animated: true, completion: nil)
                }
            }
        }
        else
        {
            DispatchQueue.main.async {
                func presentAlertController()
                {
                    
                    let alertController = UIAlertController(title: NSLocalizedString("Unable to Change Artwork", comment: ""), message: NSLocalizedString("The image might be corrupted or in an unsupported format.", comment: ""), preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: RSTSystemLocalizedString("OK"), style: .cancel, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
                
                if let presentedViewController = self.presentedViewController
                {
                    presentedViewController.dismiss(animated: true) {
                        presentAlertController()
                    }
                }
                else
                {
                    presentAlertController()
                }
            }
        }
    }
    
    func share(_ game: Game)
    {
        let temporaryDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        
        let sanitizedName = game.name.components(separatedBy: .urlFilenameAllowed.inverted).joined()
        let temporaryURL = temporaryDirectory.appendingPathComponent(sanitizedName + "." + game.fileURL.pathExtension, isDirectory: false)
        
        do
        {
            try FileManager.default.createDirectory(at: temporaryDirectory, withIntermediateDirectories: true, attributes: nil)
                                    
            // Make a temporary copy so we can control the filename used when sharing.
            // Otherwise, if we just passed in game.fileURL to UIActivityViewController, the file name would be the game's SHA1 hash.
            try FileManager.default.copyItem(at: game.fileURL, to: temporaryURL, shouldReplace: true)
        }
        catch
        {
            let alertController = UIAlertController(title: NSLocalizedString("Could Not Share Game", comment: ""), error: error)
            self.present(alertController, animated: true, completion: nil)
            
            return
        }
        
        let copyDeepLinkActivity = CopyDeepLinkActivity()
        
        let activityViewController = UIActivityViewController(activityItems: [temporaryURL, game], applicationActivities: [copyDeepLinkActivity])
        activityViewController.popoverPresentationController?.sourceView = self._popoverSourceView?.superview
        activityViewController.popoverPresentationController?.sourceRect = self._popoverSourceView?.frame ?? .zero
        activityViewController.completionWithItemsHandler = { (activityType, finished, returnedItems, error) in
            // Make sure the user either shared the game or cancelled before deleting temporaryDirectory.
            guard finished || activityType == nil else { return }
            
            do
            {
                try FileManager.default.removeItem(at: temporaryDirectory)
            }
            catch
            {
                print(error)
            }
        }
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func importSaveFile(for game: Game)
    {
        self._importingSaveFileGame = game
        
        let importController = ImportController(documentTypes: [kUTTypeItem as String])
        importController.delegate = self
        self.present(importController, animated: true, completion: nil)
    }
    
    func importSaveFile(for game: Game, from fileURL: URL?, error: Error?)
    {
        var importSuccess = false
        
        // Dispatch to main queue so we can access game.gameSaveURL on its context's thread (main thread).
        DispatchQueue.main.async {
            do
            {
                if let error = error
                {
                    throw error
                }
                
                if let fileURL = fileURL
                {
                    try FileManager.default.copyItem(at: fileURL, to: game.gameSaveURL, shouldReplace: true)
                    
                    if let gameSave = game.gameSave
                    {
                        SyncManager.shared.recordController?.updateRecord(for: gameSave)
                    }
                    
                    importSuccess = true
                }
            }
            catch
            {
                let alertController = UIAlertController(title: NSLocalizedString("Failed to Import Save File", comment: ""), error: error)
                
                if let presentedViewController = self.presentedViewController
                {
                    presentedViewController.dismiss(animated: true) {
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
                else
                {
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    
        // delay by 0.5 seconds to not interfere with game save overwrite above
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            // delete auto save states so game starts fresh after import
            if importSuccess
            {
                let fetchRequest = SaveState.fetchRequest(for: game, type: .auto)
                
                DatabaseManager.shared.performBackgroundTask { (context) in
                    do
                    {
                        let saveStates = try fetchRequest.execute()
                        
                        for autoSaveState in saveStates
                        {
                            let saveState = context.object(with: autoSaveState.objectID)
                            context.delete(saveState)
                        }
                        context.saveWithErrorLogging()
                    }
                    catch
                    {
                        print("Failed to delete auto save states after game save import.")
                    }
                }
            }
        }
    }
    
    func exportSaveFile(for game: Game)
    {
        do
        {
            let sanitizedFilename = game.name.components(separatedBy: .urlFilenameAllowed.inverted).joined()
            
            let temporaryURL = FileManager.default.temporaryDirectory.appendingPathComponent(sanitizedFilename)
            try FileManager.default.copyItem(at: game.gameSaveURL, to: temporaryURL, shouldReplace: true)
            
            self._exportedSaveFileURL = temporaryURL
            
            let documentPicker = UIDocumentPickerViewController(urls: [temporaryURL], in: .exportToService)
            documentPicker.delegate = self
            self.present(documentPicker, animated: true, completion: nil)
        }
        catch
        {
            let alertController = UIAlertController(title: NSLocalizedString("Failed to Export Save File", comment: ""), error: error)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func changePreferredControllerSkin(for game: Game)
    {
        self.performSegue(withIdentifier: "preferredControllerSkins", sender: game)
    }
    
    func addFavoriteGame(for game: Game)
    {
        guard var favorites = UserInterfaceFeatures.shared.artwork.favoriteGames[game.type.rawValue] else { return }
        
        favorites.append(game.identifier)
        self.removeShadowForGame(for: game)
        
        DatabaseManager.shared.performBackgroundTask { (context) in
            let game = context.object(with: game.objectID) as! Game
            game.isFavorite = true
            
            context.saveWithErrorLogging()
            
            UserInterfaceFeatures.shared.artwork.favoriteGames.updateValue(favorites, forKey: game.type.rawValue)
        }
    }
    
    func removeFavoriteGame(for game: Game)
    {
        guard var favorites = UserInterfaceFeatures.shared.artwork.favoriteGames[game.type.rawValue],
              let index = favorites.firstIndex(of: game.identifier) else { return }
        
        favorites.remove(at: index)
        self.removeShadowForGame(for: game)
        
        DatabaseManager.shared.performBackgroundTask { (context) in
            let game = context.object(with: game.objectID) as! Game
            game.isFavorite = false
            
            context.saveWithErrorLogging()
            
            UserInterfaceFeatures.shared.artwork.favoriteGames.updateValue(favorites, forKey: game.type.rawValue)
        }
    }
    
    func removeShadowForGame(for game: Game)
    {
        for cell in self.collectionView?.visibleCells ?? []
        {
            if let indexPath = self.collectionView?.indexPath(for: cell)
            {
                let gameCell = self.dataSource.item(at: indexPath)
                
                if gameCell.identifier == game.identifier
                {
                    cell.layer.shadowOpacity = 0
                }
            }
        }
    }
    
    @objc func textFieldTextDidChange(_ textField: UITextField)
    {
        let text = textField.text ?? ""
        self._renameAction?.isEnabled = text.count > 0
    }
    
    @objc func handleLongPressGesture(_ gestureRecognizer: UILongPressGestureRecognizer)
    {
        guard gestureRecognizer.state == .began else { return }
        
        guard let indexPath = self.collectionView?.indexPathForItem(at: gestureRecognizer.location(in: self.collectionView)) else { return }
        
        let game = self.dataSource.item(at: indexPath)
        let actions = self.actions(for: game)
        
        let alertController = UIAlertController(actions: actions)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func settingsDidChange(_ notification: Notification)
    {
        guard let settingsName = notification.userInfo?[Settings.NotificationUserInfoKey.name] as? Settings.Name else { return }
        
        switch settingsName
        {
        case UserInterfaceFeatures.shared.theme.$useCustom.settingsKey, UserInterfaceFeatures.shared.theme.$customColor.settingsKey, UserInterfaceFeatures.shared.theme.$accentColor.settingsKey, UserInterfaceFeatures.shared.theme.settingsKey, UserInterfaceFeatures.shared.artwork.$size.settingsKey, UserInterfaceFeatures.shared.artwork.settingsKey, UserInterfaceFeatures.shared.artwork.$cornerRadius.settingsKey, UserInterfaceFeatures.shared.artwork.$borderWidth.settingsKey, UserInterfaceFeatures.shared.artwork.$shadowOpacity.settingsKey, UserInterfaceFeatures.shared.artwork.$favoriteGames.settingsKey, UserInterfaceFeatures.shared.artwork.$favoriteColor.settingsKey, UserInterfaceFeatures.shared.artwork.$bgColor.settingsKey, UserInterfaceFeatures.shared.artwork.$bgThemed.settingsKey, UserInterfaceFeatures.shared.artwork.$bgOpacity.settingsKey, UserInterfaceFeatures.shared.artwork.$animationPause.settingsKey, UserInterfaceFeatures.shared.artwork.$animationSpeed.settingsKey:
            self.update()
            
        case UserInterfaceFeatures.shared.artwork.$sortOrder.settingsKey, UserInterfaceFeatures.shared.artwork.$favoriteSort.settingsKey:
            self.updateDataSource()
            self.update()
            
        default: break
        }
    }
}

//MARK: - UIViewControllerPreviewingDelegate -
/// UIViewControllerPreviewingDelegate
extension GameCollectionViewController: UIViewControllerPreviewingDelegate
{
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController?
    {
        guard self.gameCollection?.identifier != GameType.unknown.rawValue else { return nil }
        
        guard
            let collectionView = self.collectionView,
            let indexPath = collectionView.indexPathForItem(at: location),
            let layoutAttributes = collectionView.layoutAttributesForItem(at: indexPath)
        else { return nil }
        
        previewingContext.sourceRect = layoutAttributes.frame
        
        let cell = collectionView.cellForItem(at: indexPath)
        self._popoverSourceView = cell
        
        let game = self.dataSource.item(at: indexPath)
        
        let gameViewController = self.makePreviewGameViewController(for: game)
        _previewTransitionViewController = gameViewController
        return gameViewController
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController)
    {
        self.commitPreviewTransition()
    }
    
    func makePreviewGameViewController(for game: Game) -> PreviewGameViewController
    {
        let gameViewController = PreviewGameViewController()
        gameViewController.game = game
        
        if let previewSaveState = game.previewSaveState
        {
            gameViewController.previewSaveState = previewSaveState
            gameViewController.previewImage = UIImage(contentsOfFile: previewSaveState.imageFileURL.path)
        }
        
        if let emulatorBridge = gameViewController.emulatorCore?.deltaCore.emulatorBridge as? MelonDSEmulatorBridge
        {
            //TODO: Update this to work with multiple processes by retrieving emulatorBridge directly from emulatorCore.

            if game.identifier == Game.melonDSDSiBIOSIdentifier
            {
                emulatorBridge.systemType = .dsi
            }
            else
            {
                emulatorBridge.systemType = .ds
            }

            emulatorBridge.isJITEnabled = ProcessInfo.processInfo.isJITAvailable
        }
        
        let actions = self.actions(for: game).previewActions
        gameViewController.overridePreviewActionItems = actions
        
        return gameViewController
    }
    
    func commitPreviewTransition()
    {
        guard let gameViewController = _previewTransitionViewController else { return }
        
        let game = gameViewController.game as! Game
        gameViewController.pauseEmulation()
        
        let indexPath = self.dataSource.fetchedResultsController.indexPath(forObject: game)!
        let fileURL = FileManager.default.uniqueTemporaryURL()
        
        if gameViewController.isLivePreview
        {
            self.activeSaveState = gameViewController.emulatorCore?.saveSaveState(to: fileURL)
        }
        else
        {
            self.activeSaveState = gameViewController.previewSaveState
        }
        
        gameViewController.emulatorCore?.stop()
        
        _performingPreviewTransition = true
        
        self.launchGame(at: indexPath, clearScreen: true, ignoreAlreadyRunningError: true)
        
        if gameViewController.isLivePreview
        {
            do
            {
                try FileManager.default.removeItem(at: fileURL)
            }
            catch
            {
                print(error)
            }
        }
    }
}

//MARK: - SaveStatesViewControllerDelegate -
/// SaveStatesViewControllerDelegate
extension GameCollectionViewController: SaveStatesViewControllerDelegate
{
    func saveStatesViewController(_ saveStatesViewController: SaveStatesViewController, updateSaveState saveState: SaveState)
    {
    }
    
    func saveStatesViewController(_ saveStatesViewController: SaveStatesViewController, loadSaveState saveState: SaveStateProtocol)
    {
        self.activeSaveState = saveState
        
        self.dismiss(animated: true) {
            let indexPath = self.dataSource.fetchedResultsController.indexPath(forObject: saveStatesViewController.game)!
            self.launchGame(at: indexPath, clearScreen: false, ignoreAlreadyRunningError: true)
        }
    }
}

//MARK: - ImportControllerDelegate -
/// ImportControllerDelegate
extension GameCollectionViewController: ImportControllerDelegate
{
    func importController(_ importController: ImportController, didImportItemsAt urls: Set<URL>, errors: [Error])
    {
        if let game = self._changingArtworkGame
        {
            self.changeArtwork(for: game, toImageAt: urls.first, errors: errors)
        }
        else if let game = self._importingSaveFileGame
        {
            self.importSaveFile(for: game, from: urls.first, error: errors.first)
        }
        
        self._changingArtworkGame = nil
        self._importingSaveFileGame = nil
    }
    
    func importControllerDidCancel(_ importController: ImportController)
    {
        self.presentedViewController?.dismiss(animated: true, completion: nil)
    }
}

//MARK: - UICollectionViewDelegate -
/// UICollectionViewDelegate
extension GameCollectionViewController
{
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        guard self.gameCollection?.identifier != GameType.unknown.rawValue else { return }
        
        self.launchGame(at: indexPath, clearScreen: true)
    }
}

//MARK: - UICollectionViewDelegateFlowLayout -
/// UICollectionViewDelegateFlowLayout
extension GameCollectionViewController: UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let collectionViewLayout = collectionView.collectionViewLayout as! GridCollectionViewLayout
        
        let widthConstraint = self.prototypeCell.contentView.widthAnchor.constraint(equalToConstant: collectionViewLayout.itemWidth)
        widthConstraint.isActive = true
        defer { widthConstraint.isActive = false }
        
        self.configure(self.prototypeCell, for: indexPath)
        
        let size = self.prototypeCell.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        return size
    }
}

extension GameCollectionViewController
{
    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration?
    {
        let game = self.dataSource.item(at: indexPath)
        let actions = self.actions(for: game)
        
        let cell = self.collectionView.cellForItem(at: indexPath)
        self._popoverSourceView = cell
                
        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: { [weak self] in
            guard let self = self else { return nil }
            
            do
            {
                try self.validateLaunchingGame(game, ignoringErrors: [LaunchError.alreadyRunning])
            }
            catch
            {
                print("Error trying to preview game:", error)
                return nil
            }
                        
            let previewViewController = self.makePreviewGameViewController(for: game)
            previewViewController.isLivePreview = UserInterfaceFeatures.shared.previews.isEnabled
            
            guard previewViewController.isLivePreview || previewViewController.previewSaveState != nil else { return nil }
            self._previewTransitionViewController = previewViewController
            
            return previewViewController
        }) { suggestedActions in
            return UIMenu(title: game.name, children: actions.menuActions)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating)
    {
        self.commitPreviewTransition()
    }
    
    override func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview?
    {
        guard let indexPath = configuration.identifier as? NSIndexPath else { return nil }
        guard let cell = collectionView.cellForItem(at: indexPath as IndexPath) as? GridCollectionViewGameCell else { return nil }
        
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        
        let preview = UITargetedPreview(view: cell.imageView)
        return preview
    }
    
    override func collectionView(_ collectionView: UICollectionView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview?
    {
        _previewTransitionViewController = nil
        return self.collectionView(collectionView, previewForHighlightingContextMenuWithConfiguration: configuration)
    }
}

extension GameCollectionViewController: UIDocumentPickerDelegate
{
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL])
    {
        if let saveFileURL = self._exportedSaveFileURL
        {
            try? FileManager.default.removeItem(at: saveFileURL)
        }
        
        self._exportedSaveFileURL = nil
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController)
    {
        if let saveFileURL = self._exportedSaveFileURL
        {
            try? FileManager.default.removeItem(at: saveFileURL)
        }
        
        self._exportedSaveFileURL = nil
    }
}
