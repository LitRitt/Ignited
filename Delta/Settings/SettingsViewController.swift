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
        case controllers
        case controllerSkins
        case skinDownloads
        case controllerOpacity
        case gameAudio
        case hapticFeedback
        case rewind
        case syncing
        case hapticTouch
        case fastForward
        case cores
        case patreon
        case credits
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
        case riley
        case shane
        case litRitt
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
        case enabled
        case speed
    }
}

class SettingsViewController: UITableViewController
{
    @IBOutlet private var controllerOpacityLabel: UILabel!
    @IBOutlet private var controllerOpacitySlider: UISlider!
    
    @IBOutlet private var respectSilentModeSwitch: UISwitch!
    @IBOutlet private var buttonHapticFeedbackEnabledSwitch: UISwitch!
    @IBOutlet private var thumbstickHapticFeedbackEnabledSwitch: UISwitch!
    @IBOutlet private var previewsEnabledSwitch: UISwitch!
    
    @IBOutlet private var versionLabel: UILabel!
    
    @IBOutlet private var syncingServiceLabel: UILabel!
    
    @IBOutlet private var rewindEnabledSwitch: UISwitch!
    @IBOutlet private var rewindIntervalSlider: UISlider!
    @IBOutlet private var rewindIntervalLabel: UILabel!
    
    @IBOutlet private var customFastForwardSwitch: UISwitch!
    @IBOutlet private var customFastForwardSpeedLabel: UILabel!
    
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
        
        if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        {
            #if LITE
            self.versionLabel.text = NSLocalizedString(String(format: "Delta Lite %@", version), comment: "Delta Version")
            #else
            self.versionLabel.text = NSLocalizedString(String(format: "Delta Ignited %@", version), comment: "Delta Version")
            #endif
        }
        else
        {
            #if LITE
            self.versionLabel.text = NSLocalizedString("Delta Lite", comment: "")
            #else
            self.versionLabel.text = NSLocalizedString("Delta Ignited", comment: "")
            #endif
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
        self.controllerOpacitySlider.value = Float(Settings.translucentControllerSkinOpacity)
        self.updateControllerOpacityLabel()
        
        self.respectSilentModeSwitch.isOn = Settings.respectSilentMode
        
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
        self.previewsEnabledSwitch.isOn = Settings.isPreviewsEnabled
        
        self.rewindEnabledSwitch.isOn = Settings.isRewindEnabled
        self.rewindIntervalSlider.value = Float(Settings.rewindTimerInterval)
        self.updateRewindIntervalLabel()
        
        self.customFastForwardSwitch.isOn = Settings.isCustomFastForwardEnabled
        self.updateCustomFastForwardSpeedLabel()
        
        self.tableView.reloadData()
    }
    
    func updateControllerOpacityLabel()
    {
        let percentage = String(format: "%.f", Settings.translucentControllerSkinOpacity * 100) + "%"
        self.controllerOpacityLabel.text = percentage
    }
    
    func updateCustomFastForwardSpeedLabel()
    {
        let speed = String(format: "%.f", Settings.customFastForwardSpeed * 100) + "%"
        self.customFastForwardSpeedLabel.text = speed
    }
    
    func updateRewindIntervalLabel()
    {
        let rewindTimerIntervalString = String(Settings.rewindTimerInterval)
        self.rewindIntervalLabel.text = rewindTimerIntervalString
    }
    
    func isSectionHidden(_ section: Section) -> Bool
    {
        switch section
        {
        case .hapticTouch:
            if #available(iOS 13, *)
            {
                // All devices on iOS 13 support either 3D touch or Haptic Touch.
                return false
            }
            else
            {
                return self.view.traitCollection.forceTouchCapability != .available
            }
            
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
    
    @IBAction func toggleButtonHapticFeedbackEnabled(_ sender: UISwitch)
    {
        Settings.isButtonHapticFeedbackEnabled = sender.isOn
    }
    
    @IBAction func toggleThumbstickHapticFeedbackEnabled(_ sender: UISwitch)
    {
        Settings.isThumbstickHapticFeedbackEnabled = sender.isOn
    }
    
    @IBAction func togglePreviewsEnabled(_ sender: UISwitch)
    {
        Settings.isPreviewsEnabled = sender.isOn
    }
    
    @IBAction func toggleRespectSilentMode(_ sender: UISwitch)
    {
        Settings.respectSilentMode = sender.isOn
    }
    
    @IBAction func toggleCustomFastForward(_ sender: UISwitch) {
        Settings.isCustomFastForwardEnabled = sender.isOn
    }
    
    @IBAction func toggleRewindEnabled(_ sender: UISwitch) {
        Settings.isRewindEnabled = sender.isOn
    }
    
    @IBAction func changeRewindInterval(_ sender: UISlider) {
        let roundedValue = Int((sender.value / 1).rounded() * 1)
        
        if roundedValue != Settings.rewindTimerInterval
        {
            self.selectionFeedbackGenerator?.selectionChanged()
        }
        
        Settings.rewindTimerInterval = Int(roundedValue)
        
        self.updateRewindIntervalLabel()
    }
    
    @IBAction func beginChangingRewindInterval(_ sender: UISlider) {
        self.selectionFeedbackGenerator = UISelectionFeedbackGenerator()
        self.selectionFeedbackGenerator?.prepare()
    }
    
    @IBAction func didFinishChangingRewindInterval(_ sender: UISlider) {
        sender.value = Float(Settings.rewindTimerInterval)
        self.selectionFeedbackGenerator = nil
    }
    
    func changeFastForwardSpeed()
    {
        Settings.customFastForwardSpeed = 8
    }
    
    func openSkinWebsite(site: String)
    {
        let safariURL = URL(string: site)!
        let safariViewController = SFSafariViewController(url: safariURL)
        safariViewController.preferredControlTintColor = .deltaPurple
        self.present(safariViewController, animated: true, completion: nil)
    }
    
    func openTwitter(username: String)
    {
        let twitterAppURL = URL(string: "twitter://user?screen_name=" + username)!
        UIApplication.shared.open(twitterAppURL, options: [:]) { (success) in
            if success
            {
                if let selectedIndexPath = self.tableView.indexPathForSelectedRow
                {
                    self.tableView.deselectRow(at: selectedIndexPath, animated: true)
                }
            }
            else
            {
                let safariURL = URL(string: "https://twitter.com/" + username)!
                
                let safariViewController = SFSafariViewController(url: safariURL)
                safariViewController.preferredControlTintColor = .deltaPurple
                self.present(safariViewController, animated: true, completion: nil)
            }
        }
    }
    
    func changeCustomFastForwardSpeed()
    {
        let alertController = UIAlertController(title: NSLocalizedString("Change Fast Forward Speed", comment: ""), message: NSLocalizedString("Speeds below 100% will slow down gameplay instead of speeding it up.", comment: ""), preferredStyle: .actionSheet)
        
        var speedOneTitle = "25%"
        var speedTwoTitle = "50%"
        var speedThreeTitle = "200%"
        var speedFourTitle = "400%"
        var speedFiveTitle = "800%"
        var speedSixTitle = "1600%"
        
        switch Settings.customFastForwardSpeed
        {
        case 0.25: speedOneTitle += " ✓"
        case 0.5: speedTwoTitle += " ✓"
        case 2.0: speedThreeTitle += " ✓"
        case 4.0: speedFourTitle += " ✓"
        case 8.0: speedFiveTitle += " ✓"
        case 16.0: speedSixTitle += " ✓"
        default: break
        }
        
        alertController.addAction(UIAlertAction(title: speedOneTitle, style: .default, handler: { (action) in
            Settings.customFastForwardSpeed = 0.25
            self.tableView.reloadData()
        }))
        alertController.addAction(UIAlertAction(title: speedTwoTitle, style: .default, handler: { (action) in
            Settings.customFastForwardSpeed = 0.5
            self.tableView.reloadData()
        }))
        alertController.addAction(UIAlertAction(title: speedThreeTitle, style: .default, handler: { (action) in
            Settings.customFastForwardSpeed = 2.0
            self.tableView.reloadData()
        }))
        alertController.addAction(UIAlertAction(title: speedFourTitle, style: .default, handler: { (action) in
            Settings.customFastForwardSpeed = 4.0
            self.tableView.reloadData()
        }))
        alertController.addAction(UIAlertAction(title: speedFiveTitle, style: .default, handler: { (action) in
            Settings.customFastForwardSpeed = 8.0
            self.tableView.reloadData()
        }))
        alertController.addAction(UIAlertAction(title: speedSixTitle, style: .default, handler: { (action) in
            Settings.customFastForwardSpeed = 16.0
            self.tableView.reloadData()
        }))
        alertController.addAction(.cancel)
        self.present(alertController, animated: true, completion: nil)
        
        if let indexPath = self.tableView.indexPathForSelectedRow
        {
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
        self.update()
    }
    
    @available(iOS 14, *)
    func showContributors()
    {
        let hostingController = ContributorsView.makeViewController()
        self.navigationController?.pushViewController(hostingController, animated: true)
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
            
        case .localControllerPlayerIndex, .preferredControllerSkin, .translucentControllerSkinOpacity, .respectSilentMode, .isButtonHapticFeedbackEnabled, .isThumbstickHapticFeedbackEnabled, .isCustomFastForwardEnabled, .customFastForwardSpeed, .isAltJITEnabled: break
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
            
        case .fastForward:
            switch FastForwardRow.allCases[indexPath.row]
            {
            case .speed:
                cell.detailTextLabel?.text = String(format: "%.f", Settings.customFastForwardSpeed * 100) + "%"
                
            case .enabled: break
            }
            
        case .skinDownloads, .controllerOpacity, .gameAudio, .rewind, .hapticFeedback, .hapticTouch, .fastForward, .patreon, .credits: break
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let cell = tableView.cellForRow(at: indexPath)
        let section = Section(rawValue: indexPath.section)!

        switch section
        {
        case .controllers: self.performSegue(withIdentifier: Segue.controllers.rawValue, sender: cell)
        case .controllerSkins: self.performSegue(withIdentifier: Segue.controllerSkins.rawValue, sender: cell)
        case .skinDownloads:
            let row = SkinDownloadsRow(rawValue: indexPath.row)!
            switch row
            {
            case .litDesign: self.openSkinWebsite(site: "https://design.litritt.com")
            case .skinGenerator: self.openSkinWebsite(site: "https://generator.skins4delta.com")
            case .deltaSkins: self.openSkinWebsite(site: "https://delta-skins.github.io")
            case .skins4Delta: self.openSkinWebsite(site: "https://skins4delta.com")
            }
        case .cores: self.performSegue(withIdentifier: Segue.dsSettings.rawValue, sender: cell)
        case .controllerOpacity, .gameAudio, .rewind, .hapticFeedback, .hapticTouch, .syncing: break
        case .fastForward:
            let row = FastForwardRow(rawValue: indexPath.row)!
            switch row
            {
            case .speed:
                self.changeCustomFastForwardSpeed()
            case .enabled: break
            }
        case .patreon:
            let patreonURL = URL(string: "https://www.patreon.com/litritt")!
            
            UIApplication.shared.open(patreonURL, options: [:]) { (success) in
                guard !success else { return }
                
                let patreonURL = URL(string: "https://www.patreon.com/litritt")!
                
                let safariViewController = SFSafariViewController(url: patreonURL)
                safariViewController.preferredControlTintColor = .deltaPurple
                self.present(safariViewController, animated: true, completion: nil)
            }
            
            tableView.deselectRow(at: indexPath, animated: true)
            
        case .credits:
            let row = CreditsRow(rawValue: indexPath.row)!
            switch row
            {
            case .riley: self.openTwitter(username: "rileytestut")
            case .shane: self.openTwitter(username: "shanegillio")
            case .litRitt: self.openTwitter(username: "lit_ritt")
            case .contributors:
                guard #available(iOS 14, *) else { return }
                self.showContributors()
                
            case .softwareLicenses: break
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
    primary:
        switch Section(rawValue: indexPath.section)!
        {
        case .credits:
            let row = CreditsRow(rawValue: indexPath.row)!
            switch row
            {
            case .contributors:
                // Hide row on iOS 13 and below
                guard #unavailable(iOS 14) else { break primary }
                return 0.0
                
            default: break
            }
            
        default: break
        }
        
        return super.tableView(tableView, heightForRowAt: indexPath)
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
