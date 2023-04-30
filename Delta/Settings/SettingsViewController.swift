//
//  SettingsViewController.swift
//  Delta
//
//  Created by Riley Testut on 9/4/15.
//  Copyright © 2015 Riley Testut. All rights reserved.
//

import UIKit
import SafariServices

import DeltaCore

import Roxas

private extension SettingsViewController
{
    enum Section: Int
    {
        case patreon
        case syncing
        case features
        case theme
        case gameAudio
        case autoLoad
        case rewind
        case hapticTouch
        case fastForward
        case screenshots
        case skinOptions
        case controllerSkins
        case controllers
        case skinDownloads
        case resourceLinks
        case cores
        case advanced
        case credits
        case updates
    }
    
    enum Segue: String
    {
        case controllers = "controllersSegue"
        case controllerSkins = "controllerSkinsSegue"
        case dsSettings = "dsSettingsSegue"
    }
    
    enum FeaturesRow: Int, CaseIterable
    {
        case userInterface
        case touchFeedback
    }
    
    enum SkinDownloadsRow: Int, CaseIterable
    {
        case litDesign
        case skinGenerator
        case deltaSkins
        case skins4Delta
    }

    enum SyncingRow: Int, CaseIterable
    {
        case service
        case status
    }
    
    enum CreditsRow: Int, CaseIterable
    {
        case developer
        case contributors
        case softwareLicenses
    }
    
    enum RewindRow: Int, CaseIterable
    {
        case enabled
        case interval
    }
    
    enum FastForwardRow: Int, CaseIterable
    {
        case unsafeSpeeds
        case speed
        case prompt
    }
    
    enum SkinOptionsRow: Int, CaseIterable
    {
        case opacity
        case alwaysShow
    }
    
    enum GameAudioRow: Int, CaseIterable
    {
        case respectSilent
        case playOverMedia
        case volume
    }
    
    enum GameArtworkRow: Int, CaseIterable
    {
        case roundedCorners
        case shadows
    }
    
    enum ResourceLinksRow: Int, CaseIterable
    {
        case romPatcher
        case saveConverter
    }
    
    enum AdvancedRow: Int, CaseIterable
    {
        case altSkin
        case debug
        case resetBuildCounter
        case clearAutoStates
    }
    
    enum PatreonRow: Int, CaseIterable
    {
        case patreonLink
        case patrons
    }
    
    enum ScreenshotsRow: Int, CaseIterable
    {
        case files
        case photos
        case scale
    }
}

class SettingsViewController: UITableViewController
{
    @IBOutlet private var themeColorLabel: UILabel!
    
    @IBOutlet private var controllerOpacityLabel: UILabel!
    @IBOutlet private var controllerOpacitySlider: UISlider!
    @IBOutlet private var controllerSkinAlwaysShowSwitch: UISwitch!
    @IBOutlet private var altRepresentationsSwitch: UISwitch!
    @IBOutlet private var debugModeSwitch: UISwitch!
    
    @IBOutlet private var autoLoadSaveSwitch: UISwitch!
    
    @IBOutlet private var respectSilentModeSwitch: UISwitch!
    @IBOutlet private var playOverOtherMediaSwitch: UISwitch!
    @IBOutlet private var gameVolumeLabel: UILabel!
    @IBOutlet private var gameVolumeSlider: UISlider!
    
    @IBOutlet private var previewsEnabledSwitch: UISwitch!
    
    @IBOutlet private var versionLabel: UILabel!
    
    @IBOutlet private var syncingServiceLabel: UILabel!
    
    @IBOutlet private var rewindEnabledSwitch: UISwitch!
    @IBOutlet private var rewindIntervalSlider: UISlider!
    @IBOutlet private var rewindIntervalLabel: UILabel!
    
    @IBOutlet private var promptSpeedSwitch: UISwitch!
    @IBOutlet private var fastForwardSpeedLabel: UILabel!
    @IBOutlet private var unsafeFastForwardSpeedsSwitch: UISwitch!
    
    @IBOutlet private var screenshotSaveToFilesSwitch: UISwitch!
    @IBOutlet private var screenshotSaveToPhotosSwitch: UISwitch!
    @IBOutlet private var screenshotImageScaleLabel: UILabel!
    
    private var selectionFeedbackGenerator: UISelectionFeedbackGenerator?
    
    private var previousSelectedRowIndexPath: IndexPath?
    
    private var syncingConflictsCount = 0
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsViewController.settingsDidChange(with:)), name: Settings.didChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsViewController.externalGameControllerDidConnect(_:)), name: .externalGameControllerDidConnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsViewController.externalGameControllerDidDisconnect(_:)), name: .externalGameControllerDidDisconnect, object: nil)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if let version = Bundle.main.versionNumber,
            let build = Bundle.main.buildNumber
        {
            self.versionLabel.text = NSLocalizedString(String(format: "Ignited v%@ build %d", version, build), comment: "Ignited Version")
        }
        else
        {
            self.versionLabel.text = NSLocalizedString("Ignited", comment: "")
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        if let indexPath = self.previousSelectedRowIndexPath
        {
            if indexPath.section == Section.controllers.rawValue
            {
                // Update and temporarily re-select selected row.
                self.tableView.reloadSections(IndexSet(integer: Section.controllers.rawValue), with: .none)
                self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableView.ScrollPosition.none)
            }
            
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
        
        self.update()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        guard
            let identifier = segue.identifier,
            let segueType = Segue(rawValue: identifier),
            let cell = sender as? UITableViewCell,
            let indexPath = self.tableView.indexPath(for: cell)
        else { return }
        
        self.previousSelectedRowIndexPath = indexPath
        
        switch segueType
        {
        case Segue.controllers:
            let controllersSettingsViewController = segue.destination as! ControllersSettingsViewController
            controllersSettingsViewController.playerIndex = indexPath.row
            
        case Segue.controllerSkins:
            let preferredControllerSkinsViewController = segue.destination as! PreferredControllerSkinsViewController
            
            let system = System.registeredSystems[indexPath.row]
            preferredControllerSkinsViewController.system = system
            
        case Segue.dsSettings: break
        }
    }
}

private extension SettingsViewController
{
    func update()
    {
        self.updateThemeColorLabel()
        self.controllerOpacitySlider.value = Float(Settings.translucentControllerSkinOpacity)
        self.updateControllerOpacityLabel()
        self.controllerSkinAlwaysShowSwitch.isOn = Settings.isAlwaysShowControllerSkinEnabled
        self.altRepresentationsSwitch.isOn = Settings.isAltRepresentationsEnabled
        self.debugModeSwitch.isOn = Settings.isDebugModeEnabled
        
        self.autoLoadSaveSwitch.isOn = Settings.autoLoadSave
        
        self.respectSilentModeSwitch.isOn = Settings.respectSilentMode
        self.playOverOtherMediaSwitch.isOn = Settings.playOverOtherMedia
        self.gameVolumeSlider.value = Float(Settings.gameVolume)
        self.updateGameVolumeSlider()
        
        self.syncingServiceLabel.text = Settings.syncingService?.localizedName
        
        do
        {
            let records = try SyncManager.shared.recordController?.fetchConflictedRecords() ?? []
            self.syncingConflictsCount = records.count
        }
        catch
        {
            print(error)
        }
        
        self.previewsEnabledSwitch.isOn = Settings.isPreviewsEnabled
        
        self.rewindEnabledSwitch.isOn = Settings.isRewindEnabled
        self.rewindIntervalSlider.value = Float(Settings.rewindTimerInterval)
        self.updateRewindIntervalLabel()
        
        self.unsafeFastForwardSpeedsSwitch.isOn = Settings.isUnsafeFastForwardSpeedsEnabled
        self.promptSpeedSwitch.isOn = Settings.isPromptSpeedEnabled
        self.updateFastForwardSpeedLabel()
        
        self.screenshotSaveToFilesSwitch.isOn = Settings.screenshotSaveToFiles
        self.screenshotSaveToPhotosSwitch.isOn = Settings.screenshotSaveToPhotos
        self.updateScreenshotImageScaleLabel()
        
        self.view.tintColor = .themeColor
        
        self.tableView.reloadData()
    }
    
    func updateThemeColorLabel()
    {
        self.themeColorLabel.layer.cornerRadius = 5
        self.themeColorLabel.layer.borderWidth = 1
        self.themeColorLabel.layer.borderColor = UIColor.gray.cgColor
        self.themeColorLabel.textColor = UIColor.themeColor
        self.themeColorLabel.backgroundColor = UIColor.themeColor
    }
    
    func updateControllerOpacityLabel()
    {
        let percentage = "Opacity: " + String(format: "%.f", Settings.translucentControllerSkinOpacity * 100) + "%"
        self.controllerOpacityLabel.text = percentage
    }
    
    func updateGameVolumeSlider()
    {
        let percentage = "Volume: " + String(format: "%.f", Settings.gameVolume * 100) + "%"
        self.gameVolumeLabel.text = percentage
    }
    
    func updateFastForwardSpeedLabel()
    {
        let speed = String(format: "%.f", Settings.fastForwardSpeed * 100) + "%"
        self.fastForwardSpeedLabel.text = speed
    }
    
    func updateScreenshotImageScaleLabel()
    {
        let scale = "\(Settings.screenshotImageScale.rawValue)x"
        self.screenshotImageScaleLabel.text = scale
    }
    
    func updateRewindIntervalLabel()
    {
        let interval = "Interval: " + String(Settings.rewindTimerInterval) + "s"
        self.rewindIntervalLabel.text = interval
    }
    
    func isSectionHidden(_ section: Section) -> Bool
    {
        switch section
        {
        default: return false
        }
    }
}

private extension SettingsViewController
{
    @IBAction func beginChangingControllerOpacity(with sender: UISlider)
    {
        self.selectionFeedbackGenerator = UISelectionFeedbackGenerator()
        self.selectionFeedbackGenerator?.prepare()
    }
    
    @IBAction func changeControllerOpacity(with sender: UISlider)
    {
        let roundedValue = CGFloat((sender.value / 0.05).rounded() * 0.05)
        
        if roundedValue != Settings.translucentControllerSkinOpacity
        {
            self.selectionFeedbackGenerator?.selectionChanged()
        }
        
        Settings.translucentControllerSkinOpacity = CGFloat(roundedValue)
        
        self.updateControllerOpacityLabel()
    }
    
    @IBAction func didFinishChangingControllerOpacity(with sender: UISlider)
    {
        sender.value = Float(Settings.translucentControllerSkinOpacity)
        self.selectionFeedbackGenerator = nil
    }
    
    @IBAction func beginChangingGameVolume(with sender: UISlider)
    {
        self.selectionFeedbackGenerator = UISelectionFeedbackGenerator()
        self.selectionFeedbackGenerator?.prepare()
    }
    
    @IBAction func changeGameVolume(with sender: UISlider)
    {
        let roundedValue = CGFloat((sender.value / 0.05).rounded() * 0.05)
        
        if roundedValue != Settings.gameVolume
        {
            self.selectionFeedbackGenerator?.selectionChanged()
        }
        
        Settings.gameVolume = CGFloat(roundedValue)
        
        self.updateGameVolumeSlider()
    }
    
    @IBAction func didFinishChangingGameVolume(with sender: UISlider)
    {
        sender.value = Float(Settings.gameVolume)
        self.selectionFeedbackGenerator = nil
    }
    
    @IBAction func toggleAlwaysShowControllerSkin(_ sender: UISwitch)
    {
        Settings.isAlwaysShowControllerSkinEnabled = sender.isOn
    }
    
    @IBAction func toggleAltRepresentationsEnabled(_ sender: UISwitch)
    {
        Settings.isAltRepresentationsEnabled = sender.isOn
    }
    
    @IBAction func toggleDebugModeEnabled(_ sender: UISwitch)
    {
        Settings.isDebugModeEnabled = sender.isOn
    }
    
    @IBAction func togglePreviewsEnabled(_ sender: UISwitch)
    {
        Settings.isPreviewsEnabled = sender.isOn
    }
    
    @IBAction func toggleAutoLoadSave(_ sender: UISwitch)
    {
        Settings.autoLoadSave = sender.isOn
    }
    
    @IBAction func toggleRespectSilentMode(_ sender: UISwitch)
    {
        Settings.respectSilentMode = sender.isOn
    }
    
    @IBAction func togglePlayOverOtherMedia(_ sender: UISwitch)
    {
        Settings.playOverOtherMedia = sender.isOn
    }
    
    @IBAction func togglePromptSpeed(_ sender: UISwitch)
    {
        Settings.isPromptSpeedEnabled = sender.isOn
    }
    
    @IBAction func toggleScreenshotSaveToFiles(_ sender: UISwitch)
    {
        Settings.screenshotSaveToFiles = sender.isOn
    }
    
    @IBAction func toggleScreenshotSaveToPhotos(_ sender: UISwitch)
    {
        Settings.screenshotSaveToPhotos = sender.isOn
    }
    
    @IBAction func toggleUnsafeFastForwardSpeeds(_ sender: UISwitch)
    {
        if sender.isOn
        {
            let alertController = UIAlertController(title: NSLocalizedString("⚠️ Unsafe Speeds ⚠️", comment: ""), message: NSLocalizedString("This setting enables 8x and 16x options. Using these speeds can cause instability and rarely crashes. Proceed with caution, use sparingly, and save often.", comment: ""), preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Enable", style: .destructive, handler: { (action) in
                Settings.isUnsafeFastForwardSpeedsEnabled = sender.isOn
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                self.unsafeFastForwardSpeedsSwitch.isOn = false
            }))
            self.present(alertController, animated: true, completion: nil)
        }
        else
        {
            Settings.isUnsafeFastForwardSpeedsEnabled = sender.isOn
            if Settings.fastForwardSpeed > 4.0
            {
                Settings.fastForwardSpeed = 4.0
            }
        }
    }
    
    @IBAction func toggleRewindEnabled(_ sender: UISwitch)
    {
        Settings.isRewindEnabled = sender.isOn
    }
    
    @IBAction func changeRewindInterval(_ sender: UISlider)
    {
        let roundedValue = Int((sender.value / 1).rounded() * 1)
        
        if roundedValue != Settings.rewindTimerInterval
        {
            self.selectionFeedbackGenerator?.selectionChanged()
        }
        
        Settings.rewindTimerInterval = Int(roundedValue)
        
        self.updateRewindIntervalLabel()
    }
    
    @IBAction func beginChangingRewindInterval(_ sender: UISlider)
    {
        self.selectionFeedbackGenerator = UISelectionFeedbackGenerator()
        self.selectionFeedbackGenerator?.prepare()
    }
    
    @IBAction func didFinishChangingRewindInterval(_ sender: UISlider)
    {
        sender.value = Float(Settings.rewindTimerInterval)
        self.selectionFeedbackGenerator = nil
    }
    
    func openWebsite(site: String)
    {
        let safariURL = URL(string: site)!
        let safariViewController = SFSafariViewController(url: safariURL)
        safariViewController.preferredControlTintColor = UIColor.themeColor
        self.present(safariViewController, animated: true, completion: nil)
    }
    
    func openHomePage()
    {
        let safariURL = URL(string: "https://litritt.com/")!
        let safariViewController = SFSafariViewController(url: safariURL)
        safariViewController.preferredControlTintColor = UIColor.themeColor
        self.present(safariViewController, animated: true, completion: nil)
    }
    
    func changeCustomFastForwardSpeed()
    {
        let alertController = UIAlertController(title: NSLocalizedString("Change Fast Forward Speed", comment: ""), message: NSLocalizedString("Speeds above 100% will speed up gameplay. Speeds below 100% will slow down gameplay.", comment: ""), preferredStyle: .actionSheet)
        alertController.popoverPresentationController?.sourceView = self.view
        alertController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        alertController.popoverPresentationController?.permittedArrowDirections = []
        
        var speedOneTitle = "25%"
        var speedTwoTitle = "50%"
        var speedThreeTitle = "150%"
        var speedFourTitle = "200%"
        var speedFiveTitle = "400%"
        var speedSixTitle = "800%"
        var speedSevenTitle = "1600%"
        
        switch Settings.fastForwardSpeed
        {
        case 0.25: speedOneTitle += " ✓"
        case 0.5: speedTwoTitle += " ✓"
        case 1.5: speedThreeTitle += " ✓"
        case 2.0: speedFourTitle += " ✓"
        case 4.0: speedFiveTitle += " ✓"
        case 8.0: speedSixTitle += " ✓"
        case 16.0: speedSevenTitle += " ✓"
        default: break
        }
        
        alertController.addAction(UIAlertAction(title: speedOneTitle, style: .default, handler: { (action) in
            Settings.fastForwardSpeed = 0.25
        }))
        alertController.addAction(UIAlertAction(title: speedTwoTitle, style: .default, handler: { (action) in
            Settings.fastForwardSpeed = 0.5
        }))
        alertController.addAction(UIAlertAction(title: speedThreeTitle, style: .default, handler: { (action) in
            Settings.fastForwardSpeed = 1.5
        }))
        alertController.addAction(UIAlertAction(title: speedFourTitle, style: .default, handler: { (action) in
            Settings.fastForwardSpeed = 2.0
        }))
        alertController.addAction(UIAlertAction(title: speedFiveTitle, style: .default, handler: { (action) in
            Settings.fastForwardSpeed = 4.0
        }))
        if Settings.isUnsafeFastForwardSpeedsEnabled {
            alertController.addAction(UIAlertAction(title: speedSixTitle, style: .default, handler: { (action) in
                Settings.fastForwardSpeed = 8.0
            }))
            alertController.addAction(UIAlertAction(title: speedSevenTitle, style: .default, handler: { (action) in
                Settings.fastForwardSpeed = 16.0
            }))
        }
        alertController.addAction(.cancel)
        self.present(alertController, animated: true, completion: nil)
        
        if let indexPath = self.tableView.indexPathForSelectedRow
        {
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func changeScreenshotImageScale()
    {
        let alertController = UIAlertController(title: NSLocalizedString("Change Screenshot Image Scale", comment: ""), message: NSLocalizedString("Game screenshots will be saved at this scale. 1x is the native resolution of the system.", comment: ""), preferredStyle: .actionSheet)
        alertController.popoverPresentationController?.sourceView = self.view
        alertController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        alertController.popoverPresentationController?.permittedArrowDirections = []
        
        var x1Title = "1x"
        var x2Title = "2x"
        var x3Title = "3x"
        var x4Title = "4x"
        var x5Title = "5x"
        
        switch Settings.screenshotImageScale
        {
        case .x1: x1Title += " ✓"
        case .x2: x2Title += " ✓"
        case .x3: x3Title += " ✓"
        case .x4: x4Title += " ✓"
        case .x5: x5Title += " ✓"
        }
        
        alertController.addAction(UIAlertAction(title: x1Title, style: .default, handler: { (action) in
            Settings.screenshotImageScale = .x1
        }))
        alertController.addAction(UIAlertAction(title: x2Title, style: .default, handler: { (action) in
            Settings.screenshotImageScale = .x2
        }))
        alertController.addAction(UIAlertAction(title: x3Title, style: .default, handler: { (action) in
            Settings.screenshotImageScale = .x3
        }))
        alertController.addAction(UIAlertAction(title: x4Title, style: .default, handler: { (action) in
            Settings.screenshotImageScale = .x4
        }))
        alertController.addAction(UIAlertAction(title: x5Title, style: .default, handler: { (action) in
            Settings.screenshotImageScale = .x5
        }))
        alertController.addAction(.cancel)
        self.present(alertController, animated: true, completion: nil)
        
        if let indexPath = self.tableView.indexPathForSelectedRow
        {
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func showUpdates()
    {
        let hostingController = UpdatesView.makeViewController()
        self.navigationController?.pushViewController(hostingController, animated: true)
    }
    
    func showContributors()
    {
        let hostingController = ContributorsView.makeViewController()
        self.navigationController?.pushViewController(hostingController, animated: true)
    }
    
    func showPatrons()
    {
        let hostingController = PatronsView.makeViewController()
        self.navigationController?.pushViewController(hostingController, animated: true)
    }
    
    func showUserInterfaceFeatures()
    {
        let hostingController = UserInterfaceFeaturesView.makeViewController()
        self.navigationController?.pushViewController(hostingController, animated: true)
    }
    
    func showTouchFeedbackFeatures()
    {
        let hostingController = TouchFeedbackFeaturesView.makeViewController()
        self.navigationController?.pushViewController(hostingController, animated: true)
    }
    
    func resetBuildCounter()
    {
        let alertController = UIAlertController(title: NSLocalizedString("Reset Build Counter?", comment: ""), message: NSLocalizedString("This will cause the updates screens to be shown on next launch.", comment: ""), preferredStyle: .alert)
        alertController.popoverPresentationController?.sourceView = self.view
        alertController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        alertController.popoverPresentationController?.permittedArrowDirections = []
        
        alertController.addAction(UIAlertAction(title: "Confirm", style: .destructive, handler: { (action) in
            Settings.lastUpdateShown = 1
        }))
        alertController.addAction(.cancel)
        
        self.present(alertController, animated: true, completion: nil)
        
        if let indexPath = self.tableView.indexPathForSelectedRow
        {
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func clearAutoSaveStates()
    {
        let alertController = UIAlertController(title: NSLocalizedString("⚠️ Clear States? ⚠️", comment: ""), message: NSLocalizedString("This will delete all auto save states from every game. The auto-load save states feature relies on these auto save states to resume your game where you left off. Deleting them can be useful to reduce the size of your Sync backup.", comment: ""), preferredStyle: .alert)
        alertController.popoverPresentationController?.sourceView = self.view
        alertController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        alertController.popoverPresentationController?.permittedArrowDirections = []
        
        alertController.addAction(UIAlertAction(title: "Confirm", style: .destructive, handler: { (action) in
            
            let gameFetchRequest: NSFetchRequest<Game> = Game.fetchRequest()
            gameFetchRequest.returnsObjectsAsFaults = false
            
            DatabaseManager.shared.performBackgroundTask { (context) in
                do
                {
                    let games = try gameFetchRequest.execute()
                    
                    for tempGame in games
                    {
                        let stateFetchRequest = SaveState.fetchRequest(for: tempGame, type: .auto)
                        
                        do
                        {
                            let saveStates = try stateFetchRequest.execute()
                            
                            for autoSaveState in saveStates
                            {
                                let saveState = context.object(with: autoSaveState.objectID)
                                context.delete(saveState)
                            }
                            context.saveWithErrorLogging()
                        }
                        catch
                        {
                            print("Failed to delete auto save states.")
                        }
                    }
                }
                catch
                {
                    print("Failed to fetch games.")
                }
            }
        }))
        
        alertController.addAction(.cancel)
        
        self.present(alertController, animated: true, completion: nil)
        
        if let indexPath = self.tableView.indexPathForSelectedRow
        {
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func changeThemeColor()
    {
        let alertController = UIAlertController(title: NSLocalizedString("Change Theme Color", comment: ""), message: NSLocalizedString("", comment: ""), preferredStyle: .actionSheet)
        alertController.popoverPresentationController?.sourceView = self.view
        alertController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        alertController.popoverPresentationController?.permittedArrowDirections = []
        
        var orangeTitle = "Orange"
        var purpleTitle = "Purple"
        var blueTitle = "Blue"
        var redTitle = "Red"
        var greenTitle = "Green"
        var tealTitle = "Teal"
        var pinkTitle = "Pink"
        var yellowTitle = "Yellow"
        var mintTitle = "Mint"

        switch Settings.themeColor
        {
        case .orange: orangeTitle += " ✓"
        case .purple: purpleTitle += " ✓"
        case .blue: blueTitle += " ✓"
        case .red: redTitle += " ✓"
        case .green: greenTitle += " ✓"
        case .teal: tealTitle += " ✓"
        case .pink: pinkTitle += " ✓"
        case .yellow: yellowTitle += " ✓"
        case .mint: mintTitle += " ✓"
        }
        
        let pinkAction = UIAlertAction(title: pinkTitle, style: .default, handler: { (action) in
            if Settings.themeColor != .pink {
                Settings.themeColor = .pink
                UIApplication.shared.setAlternateIconName("IconPink")
            }
        })
        pinkAction.setValue(UIColor.systemPink, forKey: "titleTextColor")
        alertController.addAction(pinkAction)
        
        let redAction = UIAlertAction(title: redTitle, style: .default, handler: { (action) in
            if Settings.themeColor != .red {
                Settings.themeColor = .red
                UIApplication.shared.setAlternateIconName("IconRed")
            }
        })
        redAction.setValue(UIColor.systemRed, forKey: "titleTextColor")
        alertController.addAction(redAction)
        
        let orangeAction = UIAlertAction(title: orangeTitle, style: .default, handler: { (action) in
            if Settings.themeColor != .orange {
                Settings.themeColor = .orange
                UIApplication.shared.setAlternateIconName(nil)
            }
        })
        orangeAction.setValue(UIColor.ignitedOrange, forKey: "titleTextColor")
        alertController.addAction(orangeAction)
        
        let yellowAction = UIAlertAction(title: yellowTitle, style: .default, handler: { (action) in
            if Settings.themeColor != .yellow {
                Settings.themeColor = .yellow
                UIApplication.shared.setAlternateIconName("IconYellow")
            }
        })
        yellowAction.setValue(UIColor.systemYellow, forKey: "titleTextColor")
        alertController.addAction(yellowAction)
        
        let greenAction = UIAlertAction(title: greenTitle, style: .default, handler: { (action) in
            if Settings.themeColor != .green {
                Settings.themeColor = .green
                UIApplication.shared.setAlternateIconName("IconGreen")
            }
        })
        greenAction.setValue(UIColor.systemGreen, forKey: "titleTextColor")
        alertController.addAction(greenAction)
        
        let mintAction = UIAlertAction(title: mintTitle, style: .default, handler: { (action) in
            if Settings.themeColor != .mint {
                Settings.themeColor = .mint
                UIApplication.shared.setAlternateIconName("IconMint")
            }
        })
        mintAction.setValue(UIColor.ignitedMint, forKey: "titleTextColor")
        alertController.addAction(mintAction)
        
        let tealAction = UIAlertAction(title: tealTitle, style: .default, handler: { (action) in
            if Settings.themeColor != .teal {
                Settings.themeColor = .teal
                UIApplication.shared.setAlternateIconName("IconTeal")
            }
        })
        tealAction.setValue(UIColor.systemTeal, forKey: "titleTextColor")
        alertController.addAction(tealAction)
        
        let blueAction = UIAlertAction(title: blueTitle, style: .default, handler: { (action) in
            if Settings.themeColor != .pink {
                Settings.themeColor = .blue
                UIApplication.shared.setAlternateIconName("IconBlue")
            }
        })
        blueAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
        alertController.addAction(blueAction)
        
        let purpleAction = UIAlertAction(title: purpleTitle, style: .default, handler: { (action) in
            if Settings.themeColor != .purple {
                Settings.themeColor = .purple
                UIApplication.shared.setAlternateIconName("IconPurple")
            }
        })
        purpleAction.setValue(UIColor.deltaPurple, forKey: "titleTextColor")
        alertController.addAction(purpleAction)
        
        alertController.addAction(.cancel)
        
        self.present(alertController, animated: true, completion: nil)
        
        if let indexPath = self.tableView.indexPathForSelectedRow
        {
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}

private extension SettingsViewController
{
    @objc func settingsDidChange(with notification: Notification)
    {
        guard let settingsName = notification.userInfo?[Settings.NotificationUserInfoKey.name] as? Settings.Name else { return }
        
        switch settingsName
        {
        case .syncingService:
            let selectedIndexPath = self.tableView.indexPathForSelectedRow
            
            self.tableView.reloadSections(IndexSet(integer: Section.syncing.rawValue), with: .none)
            
            let syncingServiceIndexPath = IndexPath(row: SyncingRow.service.rawValue, section: Section.syncing.rawValue)
            if selectedIndexPath == syncingServiceIndexPath
            {
                self.tableView.selectRow(at: selectedIndexPath, animated: true, scrollPosition: .none)
            }
        case .themeColor, .fastForwardSpeed, .screenshotImageScale:
            self.update()
            
        default: break
        }
    }

    @objc func externalGameControllerDidConnect(_ notification: Notification)
    {
        self.tableView.reloadSections(IndexSet(integer: Section.controllers.rawValue), with: .none)
    }
    
    @objc func externalGameControllerDidDisconnect(_ notification: Notification)
    {
        self.tableView.reloadSections(IndexSet(integer: Section.controllers.rawValue), with: .none)
    }
}

extension SettingsViewController
{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection sectionIndex: Int) -> Int
    {
        let section = Section(rawValue: sectionIndex)!
        switch section
        {
        case .controllers: return 4 // Temporarily hide other controller indexes until controller logic is finalized
        case .controllerSkins: return System.registeredSystems.count
        case .syncing: return SyncManager.shared.coordinator?.account == nil ? 1 : super.tableView(tableView, numberOfRowsInSection: sectionIndex)
        default:
            if isSectionHidden(section)
            {
                return 0
            }
            else
            {
                return super.tableView(tableView, numberOfRowsInSection: sectionIndex)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        let section = Section(rawValue: indexPath.section)!
        switch section
        {
        case .controllers:
            if indexPath.row == Settings.localControllerPlayerIndex
            {
                cell.detailTextLabel?.text = UIDevice.current.name
            }
            else if let index = ExternalGameControllerManager.shared.connectedControllers.firstIndex(where: { $0.playerIndex == indexPath.row })
            {
                let controller = ExternalGameControllerManager.shared.connectedControllers[index]
                cell.detailTextLabel?.text = controller.name
            }
            else
            {
                cell.detailTextLabel?.text = nil
            }
            
        case .controllerSkins:
            cell.textLabel?.text = System.registeredSystems[indexPath.row].localizedName
                        
        case .syncing:
            switch SyncingRow.allCases[indexPath.row]
            {
            case .status:
                let cell = cell as! BadgedTableViewCell
                cell.badgeLabel.text = self.syncingConflictsCount.description
                cell.badgeLabel.isHidden = (self.syncingConflictsCount == 0)
                
            case .service: break
            }
            
        case .cores:
            let preferredCore = Settings.preferredCore(for: .ds)
            cell.detailTextLabel?.text = preferredCore?.metadata?.name.value ?? preferredCore?.name ?? NSLocalizedString("Unknown", comment: "")
            
        default: break
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let cell = tableView.cellForRow(at: indexPath)
        let section = Section(rawValue: indexPath.section)!

        switch section
        {
        case .theme: self.changeThemeColor()
        case .controllers: self.performSegue(withIdentifier: Segue.controllers.rawValue, sender: cell)
        case .controllerSkins: self.performSegue(withIdentifier: Segue.controllerSkins.rawValue, sender: cell)
        case .skinDownloads:
            switch SkinDownloadsRow.allCases[indexPath.row]
            {
            case .litDesign: self.openWebsite(site: "https://design.litritt.com")
            case .skinGenerator: self.openWebsite(site: "https://generator.skins4delta.com")
            case .deltaSkins: self.openWebsite(site: "https://delta-skins.github.io")
            case .skins4Delta: self.openWebsite(site: "https://skins4delta.com")
            }
            
        case .features:
            switch FeaturesRow.allCases[indexPath.row]
            {
            case .userInterface: self.showUserInterfaceFeatures()
            case .touchFeedback: self.showTouchFeedbackFeatures()
            }
            
        case .resourceLinks:
            switch ResourceLinksRow.allCases[indexPath.row]
            {
            case .romPatcher: self.openWebsite(site: "https://www.marcrobledo.com/RomPatcher.js/")
            case .saveConverter: self.openWebsite(site: "https://www.save-editor.com/tools/wse_ds_save_converter.html")
            }
            
        case .cores: self.performSegue(withIdentifier: Segue.dsSettings.rawValue, sender: cell)
            
        case .fastForward:
            switch FastForwardRow.allCases[indexPath.row]
            {
            case .speed:
                self.changeCustomFastForwardSpeed()
            case .unsafeSpeeds, .prompt: break
            }
            
        case .screenshots:
            switch ScreenshotsRow.allCases[indexPath.row]
            {
            case .scale:
                self.changeScreenshotImageScale()
            case .files, .photos: break
            }
            
        case .advanced:
            switch AdvancedRow.allCases[indexPath.row]
            {
            case .resetBuildCounter:
                self.resetBuildCounter()
            case .clearAutoStates:
                self.clearAutoSaveStates()
            case .altSkin, .debug: break
            }
            
        case .patreon:
            switch PatreonRow.allCases[indexPath.row]
            {
            case .patreonLink:
                let patreonURL = URL(string: "https://www.patreon.com/litritt")!
                
                UIApplication.shared.open(patreonURL, options: [:]) { (success) in
                    guard !success else { return }
                    
                    let patreonURL = URL(string: "https://www.patreon.com/litritt")!
                    
                    let safariViewController = SFSafariViewController(url: patreonURL)
                    safariViewController.preferredControlTintColor = UIColor.themeColor
                    self.present(safariViewController, animated: true, completion: nil)
                }
                
            case .patrons: self.showPatrons()
            }
            
            tableView.deselectRow(at: indexPath, animated: true)
            
        case .credits:
            let row = CreditsRow(rawValue: indexPath.row)!
            switch row
            {
            case .developer: self.openHomePage()
            case .contributors: self.showContributors()
            case .softwareLicenses: break
            }
            
        case .updates: self.showUpdates()
            
        default: break
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        let section = Section(rawValue: section)!
        guard !isSectionHidden(section) else { return nil }
        
        switch section
        {
        case .hapticTouch where self.view.traitCollection.forceTouchCapability == .available: return NSLocalizedString("3D Touch", comment: "")
        default: return super.tableView(tableView, titleForHeaderInSection: section.rawValue)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String?
    {
        let section = Section(rawValue: section)!
        
        if isSectionHidden(section)
        {
            return nil
        }
        else
        {
            return super.tableView(tableView, titleForFooterInSection: section.rawValue)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        let section = Section(rawValue: section)!
        
        if isSectionHidden(section)
        {
            return 1
        }
        else
        {
            return super.tableView(tableView, heightForHeaderInSection: section.rawValue)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        let section = Section(rawValue: section)!
        
        if isSectionHidden(section)
        {
            return 1
        }
        else
        {
            return super.tableView(tableView, heightForFooterInSection: section.rawValue)
        }
    }
}
