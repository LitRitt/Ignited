//
//  GamesViewController.swift
//  Ignited
//
//  Created by Riley Testut on 10/12/15.
//  Copyright © 2015 Riley Testut. All rights reserved.
//

import UIKit
import CoreData
import MobileCoreServices

import DeltaCore
import Features

import Roxas
import Harmony

class GamesViewController: UIViewController
{
    var theme: Theme = .opaque {
        didSet {
            self.updateTheme()
        }
    }
    
    weak var activeEmulatorCore: EmulatorCore? {
        didSet
        {
            let game = oldValue?.game as? Game
            NotificationCenter.default.removeObserver(self, name: .NSManagedObjectContextObjectsDidChange, object: game?.managedObjectContext)
            
            if let game = self.activeEmulatorCore?.game as? Game
            {
                NotificationCenter.default.addObserver(self, selector: #selector(GamesViewController.managedObjectContextDidChange(with:)), name: .NSManagedObjectContextObjectsDidChange, object: game.managedObjectContext)
            }
        }
    }
    
    private var pageViewController: UIPageViewController!
    private var placeholderView: RSTPlaceholderView!
    private var pageControl: UIPageControl!
    
    private let fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>
    
    private var searchController: RSTSearchController?
    private lazy var importController: ImportController = self.makeImportController()
    
    private var syncingToastView: RSTToastView? {
        didSet {
            if self.syncingToastView == nil
            {
                self.syncingProgressObservation = nil
            }
        }
    }
    private var syncingProgressObservation: NSKeyValueObservation?
    private var forceNextSyncingToast: Bool = false
    
    private var skipPreparingPopoverMenu: Bool = false
    private var noGamesImported: Bool = true
    
    @IBOutlet private var optionsButton: UIBarButtonItem!
    @IBOutlet private var playButton: UIBarButtonItem!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("initWithNibName: not implemented")
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        let fetchRequest = GameCollection.rst_fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(GameCollection.index), ascending: true)]
                
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DatabaseManager.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        super.init(coder: aDecoder)
        
        self.fetchedResultsController.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(GamesViewController.syncingDidStart(_:)), name: SyncCoordinator.didStartSyncingNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GamesViewController.syncingDidFinish(_:)), name: SyncCoordinator.didFinishSyncingNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GamesViewController.settingsDidChange(_:)), name: Settings.didChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GamesViewController.emulationDidQuit(_:)), name: EmulatorCore.emulationDidQuitNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GamesViewController.graphicsRenderingAPIDidChange(_:)), name: .graphicsRenderingAPIDidChange, object: nil)
    }
}

//MARK: - UIViewController -
/// UIViewController
extension GamesViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.placeholderView = RSTPlaceholderView(frame: self.view.bounds)
        self.placeholderView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.placeholderView.textLabel.text = NSLocalizedString("No Games", comment: "")
        self.placeholderView.detailTextLabel.text = NSLocalizedString("You can import games by pressing the + button in the top right.", comment: "")
        self.view.insertSubview(self.placeholderView, at: 0)
        
        self.pageControl = UIPageControl()
        
        if let navigationController = self.navigationController
        { 
            let navigationBarAppearance = navigationController.navigationBar.standardAppearance.copy()
            navigationBarAppearance.backgroundEffect = UIBlurEffect(style: .systemThinMaterial)
            navigationController.navigationBar.standardAppearance = navigationBarAppearance
            navigationController.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        }
        
        self.importController.presentingViewController = self
        
        self.updateTheme()
        self.updateOptionsMenu()
        self.updatePlayMenu()
        
        self.prepareSearchController()
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        if self.fetchedResultsController.performFetchIfNeeded()
        {
            self.updateSections(animated: false)
        }
        
        self.preparePopoverMenuController()
        
        DispatchQueue.global().async {
            self.activeEmulatorCore?.stop()
        }
        
        if Settings.gameplayFeatures.autoSync.isEnabled
        {
            self.sync()
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - Segues -
/// Segues
extension GamesViewController
{
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        guard let identifier = segue.identifier else { return }
        
        switch identifier
        {
        case "embedPageViewController":
            self.pageViewController = segue.destination as? UIPageViewController
            self.pageViewController.dataSource = self
            self.pageViewController.delegate = self
            self.pageViewController.view.isHidden = true
        
        case "showSettings":
            let destinationViewController = segue.destination
            destinationViewController.presentationController?.delegate = self
            
        default: break
        }
    }
    
    @IBAction private func unwindFromSettingsViewController(_ segue: UIStoryboardSegue)
    {
        self.unwindFromSettings()
        
        if Settings.gameplayFeatures.autoSync.isEnabled
        {
            self.sync()
        }
    }
}

// MARK: - UI -
/// UI
private extension GamesViewController
{
    func prepareSearchController()
    {
        let searchResultsController = self.storyboard?.instantiateViewController(withIdentifier: "gameCollectionViewController") as! GameCollectionViewController
        searchResultsController.gameCollection = nil
        searchResultsController.theme = self.theme
        searchResultsController.activeEmulatorCore = self.activeEmulatorCore
        
        let placeholderView = RSTPlaceholderView()
        placeholderView.textLabel.text = NSLocalizedString("No Games Found", comment: "")
        placeholderView.detailTextLabel.text = NSLocalizedString("Please make sure the name is correct, or try searching for another game.", comment: "")
        
        switch self.theme
        {
        case .opaque: searchResultsController.dataSource.placeholderView = placeholderView
        case .translucent:
            let vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: UIBlurEffect(style: .systemUltraThinMaterial)))
            vibrancyView.contentView.addSubview(placeholderView, pinningEdgesWith: .zero)
            searchResultsController.dataSource.placeholderView = vibrancyView
        }
        
        self.searchController = RSTSearchController(searchResultsController: searchResultsController)
        self.searchController?.searchableKeyPaths = [#keyPath(Game.name)]
        self.searchController?.searchHandler = { [weak self, weak searchResultsController] (searchValue, _) in
            guard let self = self else { return nil }
            
            if self.searchController?.searchBar.text?.isEmpty == false
            {
                self.pageViewController.view.isHidden = true
            }
            else
            {
                self.pageViewController.view.isHidden = false
            }
            
            searchResultsController?.dataSource.predicate = searchValue.predicate
            return nil
        }
        self.searchController?.searchBar.barStyle = .default
        
        self.navigationItem.searchController = self.searchController
        self.navigationItem.hidesSearchBarWhenScrolling = true
        self.definesPresentationContext = true
        
        if #available(iOS 16, *) { self.navigationItem.preferredSearchBarPlacement = .stacked }
    }
    
    func updateTheme()
    {
        switch self.theme
        {
        case .opaque: self.view.backgroundColor = .secondarySystemBackground
        case .translucent: self.view.backgroundColor = nil
        }
                
        if let viewControllers = self.pageViewController.viewControllers as? [GameCollectionViewController]
        {
            for collectionViewController in viewControllers
            {
                collectionViewController.theme = self.theme
            }
        }
    }
    
    func unwindFromSettings()
    {
        NotificationCenter.default.post(name: .unwindFromSettings, object: nil, userInfo: [:])
        
        self.updateOptionsMenu()
        self.updatePlayMenu()
    }
}

// MARK: - Helper Methods -
private extension GamesViewController
{
    func viewControllerForIndex(_ index: Int) -> GameCollectionViewController?
    {
        guard let pages = self.fetchedResultsController.sections?.first?.numberOfObjects, pages > 0 else { return nil }
        
        // Return nil if only one section, and not asking for the 0th view controller
        guard !(pages == 1 && index != 0) else { return nil }
        
        var safeIndex = index % pages
        if safeIndex < 0
        {
            safeIndex = pages + safeIndex
        }
        
        let indexPath = IndexPath(row: safeIndex, section: 0)
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "gameCollectionViewController") as! GameCollectionViewController
        viewController.gameCollection = self.fetchedResultsController.object(at: indexPath) as? GameCollection
        viewController.theme = self.theme
        viewController.activeEmulatorCore = self.activeEmulatorCore
        
        return viewController
    }
    
    func updateSections(animated: Bool, resetPages: Bool = false)
    {
        let sections = self.fetchedResultsController.sections?.first?.numberOfObjects ?? 0
        self.pageControl.numberOfPages = sections
        
        var resetPageViewController = resetPages
        
        if let viewController = self.pageViewController.viewControllers?.first as? GameCollectionViewController, let gameCollection = viewController.gameCollection
        {
            if let index = self.fetchedResultsController.fetchedObjects?.firstIndex(where: { $0 as! GameCollection == gameCollection })
            {
                self.pageControl.currentPage = index
            }
            else
            {
                resetPageViewController = true
                
                self.pageControl.currentPage = 0
            }
            
        }
        
        if self.pageViewController.viewControllers?.count == 0
        {
            resetPageViewController = true
        }
        
        if sections > 0
        {
            self.noGamesImported = false
            
            // Reset page view controller if currently hidden or current child should view controller no longer exists
            if self.pageViewController.view.isHidden || resetPageViewController
            {
                var index = 0
                
                if let gameCollection = Settings.previousGameCollection
                {
                    if let gameCollectionIndex = self.fetchedResultsController.fetchedObjects?.firstIndex(where: { $0 as! GameCollection == gameCollection })
                    {
                        index = gameCollectionIndex
                    }
                }
                
                if let viewController = self.viewControllerForIndex(index)
                {
                    self.pageViewController.view.setHidden(false, animated: animated)
                    self.placeholderView.setHidden(true, animated: animated)
                    
                    self.pageViewController.setViewControllers([viewController], direction: .forward, animated: false, completion: nil)
                    
                    if let popoverMenuButton = self.navigationItem.popoverMenuController?.popoverMenuButton
                    {
                        popoverMenuButton.title = viewController.title ?? NSLocalizedString("Games", comment: "")
                        popoverMenuButton.bounds.size = popoverMenuButton.intrinsicContentSize
                        
                        self.navigationController?.navigationBar.layoutIfNeeded()
                    }
                    else
                    {
                        self.title = viewController.title ?? NSLocalizedString("Games", comment: "")
                    }
                    self.pageControl.currentPage = index
                }
            }
            else
            {
                self.pageViewController.setViewControllers(self.pageViewController.viewControllers, direction: .forward, animated: false, completion: nil)
            }
        }
        else
        {
            self.title = nil
            self.navigationItem.popoverMenuController = nil
            
            self.navigationController?.navigationBar.layoutIfNeeded()
            
            self.skipPreparingPopoverMenu = true
            self.noGamesImported = true
            
            self.pageViewController.view.setHidden(true, animated: animated)
            self.placeholderView.setHidden(false, animated: animated)
        }
    }
}

//MARK: - Popover Menu -
/// Popover Menu
private extension GamesViewController
{
    func preparePopoverMenuController()
    {
        guard !self.skipPreparingPopoverMenu else {
            self.skipPreparingPopoverMenu = false
            return
        }
        
        let listMenuViewController = ListMenuViewController()
        listMenuViewController.title = NSLocalizedString("Collections", comment: "")
        
        let navigationController = UINavigationController(rootViewController: listMenuViewController)
        navigationController.navigationBar.scrollEdgeAppearance = navigationController.navigationBar.standardAppearance
        
        let popoverMenuController = PopoverMenuController(popoverViewController: navigationController)
        self.navigationItem.popoverMenuController = popoverMenuController
        if let gameCollections = self.fetchedResultsController.fetchedObjects as? [GameCollection],
           let viewController = self.pageViewController.viewControllers?.first as? GameCollectionViewController
        {
            let items = gameCollections.map { [unowned self, weak popoverMenuController, weak listMenuViewController] gameCollection -> MenuItem in
                let item = MenuItem(text: gameCollection.system?.localizedName ?? NSLocalizedString("Collection", comment: ""),
                                    image: UIImage.symbolWithTemplate(name: "key.fill"))
                { [weak popoverMenuController, weak listMenuViewController] item in
                    listMenuViewController?.items.forEach { $0.isSelected = ($0 == item) }
                    popoverMenuController?.isActive = false
                    
                    viewController.gameCollection = gameCollection
                    Settings.previousGameCollection = gameCollection
                    
                    self.updateSections(animated: true, resetPages: true)
                }
                item.isSelected = (gameCollection == viewController.gameCollection)
                
                return item
            }
            listMenuViewController.items = items
        }
        
        let title = traitCollection.userInterfaceIdiom == .pad ? Settings.previousGameCollection?.system?.localizedName : Settings.previousGameCollection?.system?.localizedShortName
        popoverMenuController.popoverMenuButton.title = title ?? (self.title ?? NSLocalizedString("Games", comment: ""))
    }
}

//MARK: - Importing -
/// Importing
extension GamesViewController: ImportControllerDelegate
{
    private func makeImportController() -> ImportController
    {
        var documentTypes = Set(System.registeredSystems.map { $0.gameType.rawValue })
        documentTypes.insert(kUTTypeZipArchive as String)
        documentTypes.insert("com.rileytestut.delta.skin")
        
        // .bin files (Genesis ROMs)
        documentTypes.insert("com.apple.macbinary-archive")
        
        // Add GBA4iOS's exported UTIs in case user has GBA4iOS installed (which may override Delta's UTI declarations)
        documentTypes.insert("com.rileytestut.gba")
        documentTypes.insert("com.rileytestut.gbc")
        documentTypes.insert("com.rileytestut.gb")
        
        let itunesImportOption = iTunesImportOption(presentingViewController: self)
        
        let importController = ImportController(documentTypes: documentTypes)
        importController.delegate = self
        importController.importOptions = [itunesImportOption]
        
        return importController
    }
    
    @IBAction private func importFiles()
    {
        self.present(self.importController, animated: true, completion: nil)
    }
    
    func importController(_ importController: ImportController, didImportItemsAt urls: Set<URL>, errors: [Error])
    {
        for error in errors
        {
            print(error)
        }
        
        var importedGames: Set<Game>? = nil
        var importedControllerSkins: Set<ControllerSkin>? = nil
        
        let gameURLs = urls.filter { $0.pathExtension.lowercased() != "ignitedskin" && $0.pathExtension.lowercased() != "deltaskin" }
        DatabaseManager.shared.importGames(at: Set(gameURLs)) { (games, errors) in
            if errors.count > 0
            {
                let alertController = UIAlertController.alertController(for: .games, with: errors)
                self.present(alertController, animated: true, completion: nil)
            }
            
            if games.count > 0
            {
                importedGames = games
                
                self.updatePlayMenu()
                self.preparePopoverMenuController()
                
                if self.noGamesImported { self.updateSections(animated: true, resetPages: true) }
            }
        }
        
        let controllerSkinURLs = urls.filter { $0.pathExtension.lowercased() == "ignitedskin" || $0.pathExtension.lowercased() == "deltaskin" }
        DatabaseManager.shared.importControllerSkins(at: Set(controllerSkinURLs)) { (controllerSkins, errors) in
            if errors.count > 0
            {
                let alertController = UIAlertController.alertController(for: .controllerSkins, with: errors)
                self.present(alertController, animated: true, completion: nil)
            }
            
            if controllerSkins.count > 0
            {
                importedControllerSkins = controllerSkins
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + max(0.1 + (Double(urls.count) * 0.02), 2)) {
            if let window = self.view.window
            {
                let traits = DeltaCore.ControllerSkin.Traits.defaults(for: window)
                
                let alertController = UIAlertController.alertController(games: importedGames, controllerSkins: importedControllerSkins, traits: traits)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
}
//MARK: - Options Menu -
/// Options Menu
private extension GamesViewController
{
    func updateOptionsMenu()
    {
        self.optionsButton.menu = self.makeOptionsMenu()
        self.optionsButton.action = nil
        self.optionsButton.target = nil
    }
    
    func makeOptionsMenu() -> UIMenu
    {
        var options: [UIMenuElement] = [self.makeSaveStateMenu(), self.makePreviewMenu(), self.makeCustomizationMenu(), self.makeOtherMenu()]
        
        if let _ = SyncManager.shared.service
        {
            options.insert(self.makeSyncMenu(), at: 0)
        }
        
        return UIMenu(title: NSLocalizedString("Options", comment: ""), children: options)
    }
    
    func makePreviewMenu() -> UIMenu
    {
        let previewOptions: [UIAction] = [
            UIAction(title: NSLocalizedString("Context Menu", comment: ""),
                     image: UIImage(systemName: "text.below.photo"),
                     state: Settings.userInterfaceFeatures.previews.isEnabled ? .on : .off,
                     handler: { action in
                         Settings.userInterfaceFeatures.previews.isEnabled = !Settings.userInterfaceFeatures.previews.isEnabled
                         self.updateOptionsMenu()
            }),
            UIAction(title: NSLocalizedString("Live Artwork", comment: ""),
                     image: UIImage(systemName: "photo"),
                     state: Settings.libraryFeatures.artwork.useScreenshots ? .on : .off,
                     handler: { action in
                         Settings.libraryFeatures.artwork.useScreenshots = !Settings.libraryFeatures.artwork.useScreenshots
                         self.updateOptionsMenu()
                         self.updateSections(animated: true, resetPages: true)
            })
        ]
        
        return UIMenu(title: NSLocalizedString("Previews", comment: ""),
                      image: UIImage(systemName: "photo.on.rectangle"),
                      children: previewOptions)
    }
    
    func makeSaveStateMenu() -> UIMenu
    {
        let saveStateOptions: [UIAction] = [
            UIAction(title: NSLocalizedString("Auto Save", comment: ""),
                     image: UIImage(systemName: "tray.and.arrow.down"),
                     state: Settings.gameplayFeatures.saveStates.autoSave ? .on : .off,
                     handler: { action in
                         if Settings.gameplayFeatures.saveStates.autoSave
                         {
                             Settings.gameplayFeatures.saveStates.autoSave = false
                             Settings.gameplayFeatures.saveStates.autoLoad = false
                         }
                         else
                         {
                             Settings.gameplayFeatures.saveStates.autoSave = true
                         }
                         self.updateOptionsMenu()
                     }),
            UIAction(title: NSLocalizedString("Auto Load", comment: ""),
                     image: UIImage(systemName: "tray.and.arrow.up"),
                     state: Settings.gameplayFeatures.saveStates.autoLoad ? .on : .off,
                     handler: { action in
                         if Settings.gameplayFeatures.saveStates.autoLoad
                         {
                             Settings.gameplayFeatures.saveStates.autoLoad = false
                         }
                         else
                         {
                             Settings.gameplayFeatures.saveStates.autoLoad = true
                             Settings.gameplayFeatures.saveStates.autoSave = true
                             
                         }
                         self.updateOptionsMenu()
                     })
        ]
        
        return UIMenu(title: NSLocalizedString("Save States", comment: ""),
                      image: UIImage(systemName: "memorychip"),
                      children: saveStateOptions)
    }
    
    func makeSyncMenu() -> UIMenu
    {
        let syncOptions: [UIAction] = [
            UIAction(title: NSLocalizedString("Auto Sync", comment: ""),
                     image: UIImage(systemName: "arrow.triangle.2.circlepath.icloud"),
                     state: Settings.gameplayFeatures.autoSync.isEnabled ? .on : .off,
                     handler: { action in
                         Settings.gameplayFeatures.autoSync.isEnabled = !Settings.gameplayFeatures.autoSync.isEnabled
                         self.updateOptionsMenu()
                     }),
            UIAction(title: NSLocalizedString("Sync Now", comment: ""),
                     image: UIImage(systemName: "checkmark.icloud"),
                     handler: { action in
                         self.forceNextSyncingToast = true
                         self.sync()
                     })
        ]
        
        return UIMenu(title: NSLocalizedString("Sync", comment: ""),
                      image: UIImage(systemName: "icloud.and.arrow.up"),
                      children: syncOptions)
    }
    
    func makeCustomizationMenu() -> UIMenu
    {
        return UIMenu(title: NSLocalizedString("Customization", comment: ""),
                      options: [.displayInline],
                      children: [self.makeThemeMenu(), self.makeArtworkMenu(), self.makeSortingMenu()])
    }
    
    func makeThemeMenu() -> UIMenu
    {
        return UIMenu(title: NSLocalizedString("Theme", comment: ""),
                      image: UIImage(systemName: "paintbrush"),
                      children: [self.makeThemeStyleMenu(), self.makeThemeColorMenu()])
    }
    
    func makeThemeStyleMenu() -> UIMenu
    {
        var themeStyleOptions: [UIAction] = []
        
        for themeStyle in ThemeStyle.allCases
        {
            themeStyleOptions.append(
                UIAction(title: themeStyle.description,
                         image: UIImage(systemName: themeStyle.symbolName),
                         state: Settings.userInterfaceFeatures.theme.style == themeStyle ? .on : .off,
                         handler: { action in
                             Settings.userInterfaceFeatures.theme.style = themeStyle
                             self.updateOptionsMenu()
                })
            )
        }
        
        return UIMenu(title: NSLocalizedString("Style", comment: ""),
                      image: UIImage(systemName: "circle.lefthalf.filled"),
                      children: themeStyleOptions)
    }
    
    func makeThemeColorMenu() -> UIMenu
    {
        var themeColorOptions: [UIAction] = []
        
        for themeColor in ThemeColor.allCases.filter { Settings.proFeaturesEnabled || $0 != .custom }
        {
            themeColorOptions.append(
                UIAction(title: themeColor.description,
                         state: Settings.userInterfaceFeatures.theme.color == themeColor ? .on : .off,
                         handler: { action in
                             Settings.userInterfaceFeatures.theme.color = themeColor
                             AppIconOptions.updateAppIcon()
                             self.updateOptionsMenu()
                })
            )
        }
        
        return UIMenu(title: NSLocalizedString("Color", comment: ""),
                      image: UIImage(systemName: "paintpalette"),
                      children: themeColorOptions)
    }
    
    func makeSortingMenu() -> UIMenu
    {
        let favoritesAction = Settings.libraryFeatures.favorites.sortFirst
        ?
        UIAction(title: NSLocalizedString("Favorites First", comment: ""),
                 image: UIImage(systemName: "star"),
                 state: .on,
                 handler: { action in
            Settings.libraryFeatures.favorites.sortFirst = false
            self.updateOptionsMenu()
        })
        :
        UIAction(title: NSLocalizedString("Favorites First", comment: ""),
                 image: UIImage(systemName: "star.slash"),
                 state: .off,
                 handler: { action in
            Settings.libraryFeatures.favorites.sortFirst = true
            self.updateOptionsMenu()
        })
        
        var sortOptions: [UIAction] = []
        
        for sortOrder in SortOrder.allCases {
            sortOptions.append(
                UIAction(title: sortOrder.description,
                         image: UIImage(systemName: sortOrder.symbolName),
                         state: Settings.libraryFeatures.artwork.sortOrder == sortOrder ? .on : .off,
                         handler: { action in
                             Settings.libraryFeatures.artwork.sortOrder = sortOrder
                             self.updateOptionsMenu()
                })
            )
        }
        
        let sortMenu = UIMenu(title: "",
                              options: [.displayInline],
                              children: sortOptions)
        
        return UIMenu(title: NSLocalizedString("Sorting", comment: ""),
                              image: UIImage(systemName: "arrow.up.and.down.text.horizontal"),
                              children: [favoritesAction, sortMenu])
    }
    
    func makeArtworkMenu() -> UIMenu
    {
        return UIMenu(title: NSLocalizedString("Artwork", comment: ""),
                      image: UIImage(systemName: "person.crop.artframe"),
                      children: [self.makeArtworkStyleMenu(), self.makeArtworkSizeMenu(), self.makeArtworkOptionsMenu()])
    }
    
    func makeArtworkOptionsMenu() -> UIMenu
    {
        let forceAspectOption = UIAction(title: NSLocalizedString("Force Aspect Ratio", comment: ""),
                                         image: UIImage(systemName: "aspectratio"),
                                         state: Settings.libraryFeatures.artwork.forceAspect ? .on : .off,
                                         handler: { action in
            Settings.libraryFeatures.artwork.forceAspect = !Settings.libraryFeatures.artwork.forceAspect
            self.updateOptionsMenu()
        })
        
        let newGameIconOption = UIAction(title: NSLocalizedString("New Game Icon", comment: ""),
                                         image: UIImage(systemName: "circle.fill"),
                                         state: Settings.libraryFeatures.artwork.showNewGames ? .on : .off,
                                         handler: { action in
            Settings.libraryFeatures.artwork.showNewGames = !Settings.libraryFeatures.artwork.showNewGames
            self.updateOptionsMenu()
        })
        
        let pauseIconOption = UIAction(title: NSLocalizedString("Pause Icon", comment: ""),
                                         image: UIImage(systemName: "pause.fill"),
                                         state: Settings.libraryFeatures.artwork.showPauseIcon ? .on : .off,
                                         handler: { action in
            Settings.libraryFeatures.artwork.showPauseIcon = !Settings.libraryFeatures.artwork.showPauseIcon
            self.updateOptionsMenu()
        })
        
        let favoritesIconOption = UIAction(title: NSLocalizedString("Favorites Icon", comment: ""),
                                         image: UIImage(systemName: "star.circle.fill"),
                                           state: Settings.libraryFeatures.favorites.showStarIcon ? .on : .off,
                                         handler: { action in
            Settings.libraryFeatures.favorites.showStarIcon = !Settings.libraryFeatures.favorites.showStarIcon
            self.updateOptionsMenu()
        })
        
        return UIMenu(title: NSLocalizedString("Options", comment: ""),
                      image: UIImage(systemName: "gearshape"),
                      children: [forceAspectOption, newGameIconOption, pauseIconOption, favoritesIconOption])
    }
    
    func makeArtworkStyleMenu() -> UIMenu
    {
        var artworkStyleOptions: [UIAction] = []
        
        for artworkStyle in ArtworkStyle.allCases.filter { Settings.proFeaturesEnabled || $0 != .custom }
        {
            artworkStyleOptions.append(
                UIAction(title: artworkStyle.description,
                         image: UIImage(systemName: artworkStyle.symbolName),
                         state: Settings.libraryFeatures.artwork.style == artworkStyle ? .on : .off,
                         handler: { action in
                             Settings.libraryFeatures.artwork.style = artworkStyle
                             self.updateOptionsMenu()
                })
            )
        }
        
        return UIMenu(title: NSLocalizedString("Style", comment: ""),
                      image: UIImage(systemName: "paintbrush.pointed"),
                      children: artworkStyleOptions)
    }
    
    func makeArtworkSizeMenu() -> UIMenu
    {
        var artworkSizeOptions: [UIAction] = []
        
        for artworkSize in ArtworkSize.allCases
        {
            artworkSizeOptions.append(
                UIAction(title: artworkSize.description,
                         image: UIImage(systemName: artworkSize.symbolName),
                         state: Settings.libraryFeatures.artwork.size == artworkSize ? .on : .off,
                         handler: { action in
                             Settings.libraryFeatures.artwork.size = artworkSize
                             self.updateOptionsMenu()
                })
            )
        }
        
        return UIMenu(title: NSLocalizedString("Size", comment: ""),
                      image: UIImage(systemName: "square.resize"),
                      children: artworkSizeOptions)
    }
    
    func makeOtherMenu() -> UIMenu
    {
        return UIMenu(title: NSLocalizedString("Other", comment: ""),
                      options: [.displayInline],
                      children: [self.makeHelpMenu()])
    }
    
    func makeHelpMenu() -> UIMenu
    {
        let helpOptions: [UIAction] = [
            UIAction(title: NSLocalizedString("Documentation", comment: ""),
                     image: UIImage(systemName: "doc.richtext"),
                     handler: { action in
                         UIApplication.shared.openWebpage(site: "https://docs.ignitedemulator.com")
            }),
            UIAction(title: NSLocalizedString("Release Notes", comment: ""),
                     image: UIImage(systemName: "doc.badge.clock"),
                     handler: { action in
                         UIApplication.shared.openWebpage(site: "https://docs.ignitedemulator.com/release-notes")
            })
        ]
        
        return UIMenu(title: NSLocalizedString("Help", comment: ""),
                      image: UIImage(systemName: "exclamationmark.questionmark"),
                      children: helpOptions)
    }
}

//MARK: - Play Menu -
/// Play Menu
extension GamesViewController
{
    func updatePlayMenu()
    {
        self.playButton.menu = self.makePlayMenu()
        self.playButton.action = nil
        self.playButton.target = nil
    }
    
    private func makePlayMenu() -> UIMenu
    {
        let importActions = self.importController.makeActions().menuActions
        let importMenu = UIMenu(title: NSLocalizedString("Import", comment: ""),
                                image: UIImage(systemName: "plus"),
                                children: importActions)
        
        let gamesFetchRequest: NSFetchRequest<Game> = Game.fetchRequest()
        gamesFetchRequest.returnsObjectsAsFaults = false
        gamesFetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Game.playedDate), ascending: false)]
        
        var recentGames: [Game] = []
        
        do {
            recentGames = try DatabaseManager.shared.viewContext.fetch(gamesFetchRequest)
        } catch {
            print(error)
        }
        
        if recentGames.count == 0
        {
            self.playButton.image = UIImage(systemName: "plus")
            
            return importMenu
        }
        else
        {
            if let core = self.activeEmulatorCore,
               let game = core.game as? Game
            {
                self.playButton.image = UIImage(systemName: "pause.fill")
                
                let playOptions: [UIMenuElement] = [
                    UIAction(title: NSLocalizedString("Resume", comment: ""),
                             image: UIImage(systemName: "play"),
                             handler: { action in
                                 NotificationCenter.default.post(name: .resumePlaying, object: nil, userInfo: [:])
                             }),
                    UIAction(title: NSLocalizedString("Quit", comment: ""),
                             image: UIImage(systemName: "power"),
                             handler: { action in
                                 self.quitEmulation()
                                 DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                     self.updatePlayMenu()
                                 }
                             }),
                    UIMenu(title: NSLocalizedString("Play Another Game", comment: ""),
                           options: .displayInline,
                           children: [importMenu, self.makeRecentGamesMenu(recentGames), self.makeRandomGameMenu()])
                ]
                
                return UIMenu(title: game.name,
                              children: playOptions)
            }
            else
            {
                self.playButton.image = UIImage(systemName: "play.fill")
                
                 return UIMenu(title: NSLocalizedString("No Game Playing", comment: ""),
                               children: [importMenu, self.makeRecentGamesMenu(recentGames), self.makeRandomGameMenu()])
            }
        }
    }
    
    private func makeRecentGamesMenu(_ recentGames: [Game]) -> UIMenu
    {
        var recentGamesOptions: [UIMenuElement] = []
        
        for game in recentGames {
            guard game.playedDate != nil else { continue }
            
            recentGamesOptions.append(
                UIAction(title: game.name,
                         handler: { action in
                             NotificationCenter.default.post(name: .startRecentlyPlayedGame, object: game, userInfo: [:])
                         })
            )
        }
        
        return UIMenu(title: NSLocalizedString("Recent", comment: ""),
                       image: UIImage(systemName: "clock.arrow.circlepath"),
                       children: recentGamesOptions)
    }
    
    private func makeRandomGameMenu() -> UIMenu
    {
        let randomGameOptions: [UIAction] = [
            UIAction(title: NSLocalizedString("Library", comment: ""),
                     image: UIImage(systemName: "building.columns"),
                     handler: { action in
                         Settings.userInterfaceFeatures.randomGame.useCollection = false
                         NotificationCenter.default.post(name: .startRandomGame, object: nil, userInfo: [:])
            }),
            UIAction(title: NSLocalizedString("Collection", comment: ""),
                     image: UIImage(systemName: "books.vertical"),
                     handler: { action in
                         Settings.userInterfaceFeatures.randomGame.useCollection = true
                         NotificationCenter.default.post(name: .startRandomGame, object: nil, userInfo: [:])
            })
        ]
        
        return UIMenu(title: NSLocalizedString("Random", comment: ""),
                      image: UIImage(systemName: "dice"),
                      children: randomGameOptions)
    }
}

//MARK: - Syncing -
/// Syncing
private extension GamesViewController
{
    @IBAction func sync()
    {
        // Show toast view in case sync started before this view controller existed.
        self.showSyncingToastViewIfNeeded()
        
        SyncManager.shared.sync()
    }
    
    func showSyncingToastViewIfNeeded()
    {
        guard let coordinator = SyncManager.shared.coordinator, let syncProgress = SyncManager.shared.syncProgress, coordinator.isSyncing && self.syncingToastView == nil else { return }

        let toastView = RSTToastView(text: NSLocalizedString("Syncing...", comment: ""), detailText: syncProgress.localizedAdditionalDescription)
        toastView.activityIndicatorView.startAnimating()
        toastView.addTarget(self, action: #selector(GamesViewController.hideSyncingToastView), for: .touchUpInside)
        toastView.show(in: self.view)
        
        self.syncingProgressObservation = syncProgress.observe(\.localizedAdditionalDescription) { [weak toastView, weak self] (progress, change) in
            DispatchQueue.main.async {
                // Prevent us from updating text right as we're dismissing the toast view.
                guard self?.syncingToastView != nil else { return }
                toastView?.detailTextLabel.text = progress.localizedAdditionalDescription
            }
        }
        
        self.syncingToastView = toastView
    }
    
    func showSyncFinishedToastView(result: SyncResult)
    {
        let toastView: RSTToastView
        
        switch result
        {
        case .success: toastView = RSTToastView(text: NSLocalizedString("Sync Complete", comment: ""), detailText: nil)
        case .failure(let error): toastView = RSTToastView(text: NSLocalizedString("Sync Failed", comment: ""), detailText: error.failureReason)
        }
        
        toastView.textLabel.textAlignment = .center
        toastView.addTarget(self, action: #selector(GamesViewController.presentSyncResultsViewController), for: .touchUpInside)
        
        toastView.show(in: self.view, duration: 2.0)
        
        self.syncingToastView = nil
        self.forceNextSyncingToast = false
    }
    
    @objc func hideSyncingToastView()
    {
        self.syncingToastView = nil
        self.forceNextSyncingToast = false
    }
    
    @objc func presentSyncResultsViewController()
    {
        guard let result = SyncManager.shared.previousSyncResult else { return }
        
        let navigationController = SyncResultViewController.make(result: result)
        self.present(navigationController, animated: true, completion: nil)
    }
    
    func quitEmulation()
    {
        DispatchQueue.main.async {
            self.activeEmulatorCore = nil
            
            if let viewControllers = self.pageViewController.viewControllers as? [GameCollectionViewController]
            {
                for collectionViewController in viewControllers
                {
                    collectionViewController.activeEmulatorCore = nil
                }
            }
            
            self.theme = .opaque
        }
    }
}

//MARK: - Notifications -
/// Notifications
private extension GamesViewController
{
    @objc func managedObjectContextDidChange(with notification: Notification)
    {
        guard let deletedObjects = notification.userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject> else { return }
        
        if let game = self.activeEmulatorCore?.game as? Game
        {
            if deletedObjects.contains(game)
            {                
                self.quitEmulation()
            }
        }
        else
        {
            self.quitEmulation()
        }
    }
    
    @objc func syncingDidStart(_ notification: Notification)
    {
        guard Settings.gameplayFeatures.autoSync.isEnabled || self.forceNextSyncingToast else { return }
        
        DispatchQueue.main.async {
            self.showSyncingToastViewIfNeeded()
        }
    }
    
    @objc func syncingDidFinish(_ notification: Notification)
    {
        guard Settings.gameplayFeatures.autoSync.isEnabled || self.forceNextSyncingToast else { return }
        
        DispatchQueue.main.async {
            guard let result = notification.userInfo?[SyncCoordinator.syncResultKey] as? SyncResult else { return }
            self.showSyncFinishedToastView(result: result)
            
            self.updatePlayMenu()
            self.preparePopoverMenuController()
            
            DatabaseManager.shared.repairGameCollections()
            
            if self.noGamesImported { self.updateSections(animated: true, resetPages: true) }
        }
    }
    
    @objc func graphicsRenderingAPIDidChange(_ notification: Notification)
    {
        if let emulatorCore = self.activeEmulatorCore
        {
            emulatorCore.stop()
        }
        self.quitEmulation()
    }
    
    @objc func emulationDidQuit(_ notification: Notification)
    {
        self.quitEmulation()
    }
    
    @objc func settingsDidChange(_ notification: Notification)
    {
        guard let emulatorCore = self.activeEmulatorCore else { return }
        guard let game = emulatorCore.game as? Game else { return }
        
        game.managedObjectContext?.performAndWait {
            guard
                let name = notification.userInfo?[Settings.NotificationUserInfoKey.name] as? String, name == Settings.preferredCoreSettingsKey(for: emulatorCore.game.type),
                let core = notification.userInfo?[Settings.NotificationUserInfoKey.core] as? DeltaCoreProtocol, core != emulatorCore.deltaCore
            else { return }
            
            emulatorCore.stop()
            self.quitEmulation()
        }
    }
}

//MARK: - UIPageViewController -
/// UIPageViewController
extension GamesViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate
{
    //MARK: - UIPageViewControllerDataSource
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?
    {
        let viewController = self.viewControllerForIndex(self.pageControl.currentPage - 1)
        return viewController
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        let viewController = self.viewControllerForIndex(self.pageControl.currentPage + 1)
        return viewController
    }
    
    //MARK: - UIPageViewControllerDelegate
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool)
    {
        if let viewController = pageViewController.viewControllers?.first as? GameCollectionViewController, let gameCollection = viewController.gameCollection
        {
            let index = self.fetchedResultsController.fetchedObjects?.firstIndex(where: { $0 as! GameCollection == gameCollection }) ?? 0
            self.pageControl.currentPage = index
            
            Settings.previousGameCollection = gameCollection
        }
        else
        {
            Settings.previousGameCollection = nil
        }
        
        self.preparePopoverMenuController()
    }
}

extension GamesViewController: UISearchResultsUpdating
{
    func updateSearchResults(for searchController: UISearchController)
    {
        if searchController.searchBar.text?.isEmpty == false
        {            
            self.pageViewController.view.isHidden = true
        }
        else
        {
            self.pageViewController.view.isHidden = false
        }
    }
}

//MARK: - NSFetchedResultsControllerDelegate -
/// NSFetchedResultsControllerDelegate
extension GamesViewController: NSFetchedResultsControllerDelegate
{
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    {
        self.updateSections(animated: true)
    }
}

extension GamesViewController: UIAdaptivePresentationControllerDelegate
{
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController)
    {
        if Settings.gameplayFeatures.autoSync.isEnabled
        {
            self.sync()
        }
    }
    
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController)
    {
        self.unwindFromSettings()
    }
}

//MARK: - Notification.Name
/// Notification.Name
public extension Notification.Name
{
    static let resumePlaying = Notification.Name("resumeCurrentGameNotification")
    static let startRecentlyPlayedGame = Notification.Name("startRecentlyPlayedGameNotification")
    static let startRandomGame = Notification.Name("startRandomGameNotification")
    static let unwindFromSettings = Notification.Name("unwindFromSettingsNotification")
    static let dismissSettings = Notification.Name("dismissSettingsNotification")
    static let graphicsRenderingAPIDidChange = Notification.Name("graphicsRenderingAPIDidChangeNotification")
}
