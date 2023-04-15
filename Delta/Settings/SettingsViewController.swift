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
        case theme
        case gameAudio
        case autoLoad
        case rewind
        case overlay
        case hapticFeedback
        case audioFeedback
        case hapticTouch
        case fastForward
        case toasts
        case skinOptions
        case controllerSkins
        case controllers
        case skinDownloads
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
    
    enum HapticsRow: Int, CaseIterable
    {
        case clicky
        case buttons
        case sticks
        case strength
    }
    
    enum AudioFeedbackRow: Int, CaseIterable
    {
        case buttons
        case sound
    }
    
    enum OverlayRow: Int, CaseIterable
    {
        case buttons
        case themed
        case opacity
        case size
    }
    
    enum AdvancedRow: Int, CaseIterable
    {
        case altSkin
        case debug
        case resetBuildCounter
        case clearAutoStates
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
    
    @IBOutlet private var showToastNotificationsSwitch: UISwitch!
    
    @IBOutlet private var respectSilentModeSwitch: UISwitch!
    @IBOutlet private var playOverOtherMediaSwitch: UISwitch!
    @IBOutlet private var gameVolumeLabel: UILabel!
    @IBOutlet private var gameVolumeSlider: UISlider!
    
    @IBOutlet private var buttonHapticFeedbackEnabledSwitch: UISwitch!
    @IBOutlet private var thumbstickHapticFeedbackEnabledSwitch: UISwitch!
    @IBOutlet private var clickyHapticSwitch: UISwitch!
    @IBOutlet private var hapticStrengthLabel: UILabel!
    @IBOutlet private var hapticStrengthSlider: UISlider!
    
    @IBOutlet private var buttonAudioFeedbackEnabledSwitch: UISwitch!
    @IBOutlet private var buttonAudioFeedbackSoundLabel: UILabel!
    
    @IBOutlet private var buttonTouchOverlayEnabledSwitch: UISwitch!
    @IBOutlet private var touchOverlayThemeEnabledSwitch: UISwitch!
    @IBOutlet private var touchOverlayOpacityLabel: UILabel!
    @IBOutlet private var touchOverlayOpacitySlider: UISlider!
    @IBOutlet private var touchOverlaySizeLabel: UILabel!
    @IBOutlet private var touchOverlaySizeSlider: UISlider!
    
    @IBOutlet private var previewsEnabledSwitch: UISwitch!
    
    @IBOutlet private var versionLabel: UILabel!
    
    @IBOutlet private var syncingServiceLabel: UILabel!
    
    @IBOutlet private var rewindEnabledSwitch: UISwitch!
    @IBOutlet private var rewindIntervalSlider: UISlider!
    @IBOutlet private var rewindIntervalLabel: UILabel!
    
    @IBOutlet private var promptSpeedSwitch: UISwitch!
    @IBOutlet private var fastForwardSpeedLabel: UILabel!
    @IBOutlet private var unsafeFastForwardSpeedsSwitch: UISwitch!
    
    private var selectionFeedbackGenerator: UISelectionFeedbackGenerator?
    
    private var previousSelectedRowIndexPath: IndexPath?
    
    private var syncingConflictsCount = 0
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsViewController.settingsDidChange(with:)), name: .settingsDidChange, object: nil)
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
        
        self.showToastNotificationsSwitch.isOn = Settings.showToastNotifications
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
        
        self.buttonHapticFeedbackEnabledSwitch.isOn = Settings.isButtonHapticFeedbackEnabled
        self.thumbstickHapticFeedbackEnabledSwitch.isOn = Settings.isThumbstickHapticFeedbackEnabled
        self.clickyHapticSwitch.isOn = Settings.isClickyHapticEnabled
        self.hapticStrengthSlider.value = Float(Settings.hapticFeedbackStrength)
        self.updateHapticStrengthLabel()
        
        self.buttonAudioFeedbackEnabledSwitch.isOn = Settings.isButtonAudioFeedbackEnabled
        self.updateButtonAudioFeedbackSoundLabel()
        
        self.buttonTouchOverlayEnabledSwitch.isOn = Settings.isButtonTouchOverlayEnabled
        self.touchOverlayThemeEnabledSwitch.isOn = Settings.isTouchOverlayThemeEnabled
        self.touchOverlayOpacitySlider.value = Float(Settings.touchOverlayOpacity)
        self.updateTouchOverlayOpacityLabel()
        self.touchOverlaySizeSlider.value = Float(Settings.touchOverlaySize)
        self.updateTouchOverlaySizeLabel()
        
        self.previewsEnabledSwitch.isOn = Settings.isPreviewsEnabled
        
        self.rewindEnabledSwitch.isOn = Settings.isRewindEnabled
        self.rewindIntervalSlider.value = Float(Settings.rewindTimerInterval)
        self.updateRewindIntervalLabel()
        
        self.unsafeFastForwardSpeedsSwitch.isOn = Settings.isUnsafeFastForwardSpeedsEnabled
        self.promptSpeedSwitch.isOn = Settings.isPromptSpeedEnabled
        self.updateFastForwardSpeedLabel()
        
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
    
    func updateHapticStrengthLabel()
    {
        let strength = "Strength: " + String(format: "%.f", Settings.hapticFeedbackStrength * 100) + "%"
        self.hapticStrengthLabel.text = strength
    }
    
    func updateButtonAudioFeedbackSoundLabel()
    {
        let sound: String
        switch Settings.buttonAudioFeedbackSound
        {
        case .system: sound = NSLocalizedString("System", comment: "")
        case .snappy: sound = NSLocalizedString("Snappy", comment: "")
        case .bit8: sound = NSLocalizedString("8-Bit", comment: "")
        }
        self.buttonAudioFeedbackSoundLabel.text = sound
    }
    
    func updateTouchOverlayOpacityLabel()
    {
        let opacity = "Opacity: " + String(format: "%.f", Settings.touchOverlayOpacity * 100) + "%"
        self.touchOverlayOpacityLabel.text = opacity
    }
    
    func updateTouchOverlaySizeLabel()
    {
        let size = "Size: " + String(format: "%.f", Settings.touchOverlaySize * 100) + "%"
        self.touchOverlaySizeLabel.text = size
    }
    
    func updateFastForwardSpeedLabel()
    {
        let speed = String(format: "%.f", Settings.fastForwardSpeed * 100) + "%"
        self.fastForwardSpeedLabel.text = speed
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
        case .hapticFeedback: return self.view.traitCollection.userInterfaceIdiom == .pad
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
    
    @IBAction func beginChangingHapticStrength(with sender: UISlider)
    {
        self.selectionFeedbackGenerator = UISelectionFeedbackGenerator()
        self.selectionFeedbackGenerator?.prepare()
    }
    
    @IBAction func changeHapticStrength(with sender: UISlider)
    {
        let roundedValue = CGFloat((sender.value / 0.05).rounded() * 0.05)
        
        if roundedValue != Settings.hapticFeedbackStrength
        {
            self.selectionFeedbackGenerator?.selectionChanged()
        }
        
        Settings.hapticFeedbackStrength = CGFloat(roundedValue)
        
        self.updateHapticStrengthLabel()
    }
    
    @IBAction func didFinishChangingHapticStrength(with sender: UISlider)
    {
        sender.value = Float(Settings.hapticFeedbackStrength)
        self.selectionFeedbackGenerator = nil
    }
    
    @IBAction func toggleClickyHaptic(_ sender: UISwitch)
    {
        Settings.isClickyHapticEnabled = sender.isOn
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
    
    @IBAction func toggleButtonHapticFeedbackEnabled(_ sender: UISwitch)
    {
        Settings.isButtonHapticFeedbackEnabled = sender.isOn
    }
    
    @IBAction func toggleThumbstickHapticFeedbackEnabled(_ sender: UISwitch)
    {
        Settings.isThumbstickHapticFeedbackEnabled = sender.isOn
    }
    
    @IBAction func toggleButtonAudioFeedbackEnabled(_ sender: UISwitch)
    {
        Settings.isButtonAudioFeedbackEnabled = sender.isOn
    }
    
    @IBAction func toggleButtonTouchOverlayEnabled(_ sender: UISwitch)
    {
        Settings.isButtonTouchOverlayEnabled = sender.isOn
    }
    
    @IBAction func toggleTouchOverlayThemeEnabled(_ sender: UISwitch)
    {
        Settings.isTouchOverlayThemeEnabled = sender.isOn
    }
    
    @IBAction func beginChangingTouchOverlayOpacity(with sender: UISlider)
    {
        self.selectionFeedbackGenerator = UISelectionFeedbackGenerator()
        self.selectionFeedbackGenerator?.prepare()
    }
    
    @IBAction func changeTouchOverlayOpacity(with sender: UISlider)
    {
        let roundedValue = CGFloat((sender.value / 0.05).rounded() * 0.05)
        
        if roundedValue != Settings.touchOverlayOpacity
        {
            self.selectionFeedbackGenerator?.selectionChanged()
        }
        
        Settings.touchOverlayOpacity = CGFloat(roundedValue)
        
        self.updateTouchOverlayOpacityLabel()
    }
    
    @IBAction func didFinishChangingTouchOverlayOpacity(with sender: UISlider)
    {
        sender.value = Float(Settings.touchOverlayOpacity)
        self.selectionFeedbackGenerator = nil
    }
    
    @IBAction func beginChangingTouchOverlaySize(with sender: UISlider)
    {
        self.selectionFeedbackGenerator = UISelectionFeedbackGenerator()
        self.selectionFeedbackGenerator?.prepare()
    }
    
    @IBAction func changeTouchOverlaySize(with sender: UISlider)
    {
        let roundedValue = CGFloat((sender.value / 0.05).rounded() * 0.05)
        
        if roundedValue != Settings.touchOverlaySize
        {
            self.selectionFeedbackGenerator?.selectionChanged()
        }
        
        Settings.touchOverlaySize = CGFloat(roundedValue)
        
        self.updateTouchOverlaySizeLabel()
    }
    
    @IBAction func didFinishChangingTouchOverlaySize(with sender: UISlider)
    {
        sender.value = Float(Settings.touchOverlaySize)
        self.selectionFeedbackGenerator = nil
    }
    
    @IBAction func togglePreviewsEnabled(_ sender: UISwitch)
    {
        Settings.isPreviewsEnabled = sender.isOn
    }
    
    @IBAction func toggleShowToastNotifications(_ sender: UISwitch)
    {
        Settings.showToastNotifications = sender.isOn
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
    
    func openSkinWebsite(site: String)
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
    
    func changeButtonAudioFeedbackSound()
    {
        let alertController = UIAlertController(title: NSLocalizedString("Change Button Audio Sound", comment: ""), message: NSLocalizedString("The chosen sound will be played when you press a button.", comment: ""), preferredStyle: .actionSheet)
        alertController.popoverPresentationController?.sourceView = self.view
        alertController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        alertController.popoverPresentationController?.permittedArrowDirections = []
        
        var systemTitle = "System Keyboard"
        var snappyTitle = "Snappy Button"
        var bit8Title = "8-Bit Button"
        
        switch Settings.buttonAudioFeedbackSound
        {
        case .system: systemTitle += " ✓"
        case .snappy: snappyTitle += " ✓"
        case .bit8: bit8Title += " ✓"
        }
        
        alertController.addAction(UIAlertAction(title: systemTitle, style: .default, handler: { (action) in
            Settings.buttonAudioFeedbackSound = .system
        }))
        alertController.addAction(UIAlertAction(title: snappyTitle, style: .default, handler: { (action) in
            Settings.buttonAudioFeedbackSound = .snappy
        }))
        alertController.addAction(UIAlertAction(title: bit8Title, style: .default, handler: { (action) in
            Settings.buttonAudioFeedbackSound = .bit8
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
        case .themeColor, .fastForwardSpeed, .buttonAudioFeedbackSound:
            self.update()
            
        case .localControllerPlayerIndex, .preferredControllerSkin, .translucentControllerSkinOpacity, .respectSilentMode, .isButtonHapticFeedbackEnabled, .isThumbstickHapticFeedbackEnabled, .isUnsafeFastForwardSpeedsEnabled, .isPromptSpeedEnabled, .isAltJITEnabled, .isRewindEnabled, .rewindTimerInterval, .isAltRepresentationsEnabled, .isAltRepresentationsAvailable, .isAlwaysShowControllerSkinEnabled, .isDebugModeEnabled, .isSkinDebugModeEnabled, .gameArtworkSize, .autoLoadSave, .isClickyHapticEnabled, .hapticFeedbackStrength, .isButtonTouchOverlayEnabled, .touchOverlayOpacity, .touchOverlaySize, .isTouchOverlayThemeEnabled, .isButtonAudioFeedbackEnabled, .playOverOtherMedia, .gameVolume: break
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
            
        case .theme, .skinDownloads, .skinOptions, .gameAudio, .rewind, .hapticFeedback, .hapticTouch, .patreon, .credits, .updates, .autoLoad, .toasts, .fastForward, .advanced, .overlay, .audioFeedback: break
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
            case .litDesign: self.openSkinWebsite(site: "https://design.litritt.com")
            case .skinGenerator: self.openSkinWebsite(site: "https://generator.skins4delta.com")
            case .deltaSkins: self.openSkinWebsite(site: "https://delta-skins.github.io")
            case .skins4Delta: self.openSkinWebsite(site: "https://skins4delta.com")
            }
            
        case .cores: self.performSegue(withIdentifier: Segue.dsSettings.rawValue, sender: cell)
        case .toasts, .autoLoad, .skinOptions, .gameAudio, .rewind, .hapticFeedback, .hapticTouch, .syncing, .overlay: break
        case .fastForward:
            switch FastForwardRow.allCases[indexPath.row]
            {
            case .speed:
                self.changeCustomFastForwardSpeed()
            case .unsafeSpeeds, .prompt: break
            }
            
        case .audioFeedback:
            switch AudioFeedbackRow.allCases[indexPath.row]
            {
            case .sound:
                self.changeButtonAudioFeedbackSound()
            case .buttons: break
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
            let patreonURL = URL(string: "https://www.patreon.com/litritt")!
            
            UIApplication.shared.open(patreonURL, options: [:]) { (success) in
                guard !success else { return }
                
                let patreonURL = URL(string: "https://www.patreon.com/litritt")!
                
                let safariViewController = SFSafariViewController(url: patreonURL)
                safariViewController.preferredControlTintColor = UIColor.themeColor
                self.present(safariViewController, animated: true, completion: nil)
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
