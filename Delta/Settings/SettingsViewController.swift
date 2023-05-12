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
    enum Section: Int, CaseIterable
    {
        case patreon
        case syncing
        case cores
        case features
        case controllers
        case controllerSkins
        case shortcuts
        case skinDownloads
        case resourceLinks
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
        case gameplay
        case userInterface
        case touchFeedback
        case advanced
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
    
    enum ResourceLinksRow: Int, CaseIterable
    {
        case romPatcher
        case saveConverter
    }
    
    enum PatreonRow: Int, CaseIterable
    {
        case patreonLink
        case patrons
    }
    
    enum CoresRow: Int, CaseIterable
    {
        case ds
        case gbc
    }
}

class SettingsViewController: UITableViewController
{
    @IBOutlet private var versionLabel: UILabel!
    
    @IBOutlet private var syncingServiceLabel: UILabel!
    
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
        
        self.view.tintColor = UIColor.themeColor
        
        self.tableView.reloadData()
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
    
    func showGameplayFeatures()
    {
        let hostingController = GameplayFeaturesView.makeViewController()
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
    
    func showAdvancedFeatures()
    {
        let hostingController = AdvancedFeaturesView.makeViewController()
        self.navigationController?.pushViewController(hostingController, animated: true)
    }
    
    func showGBCDeltaCoreFeatures()
    {
        let hostingController = GBCDeltaCoreFeaturesView.makeViewController()
        self.navigationController?.pushViewController(hostingController, animated: true)
    }
    
    func resetBuildCounter()
    {
        Settings.lastUpdateShown = 1
    }
    
    func clearAutoSaveStates()
    {
        let alertController = UIAlertController(title: NSLocalizedString("⚠️ Clear States? ⚠️", comment: ""), message: NSLocalizedString("This will delete all auto save states from every game. The auto-load save states feature relies on these auto save states to resume your game where you left off. Deleting them can be useful to reduce the size of your Sync backup.", comment: ""), preferredStyle: .alert)
        alertController.popoverPresentationController?.sourceView = self.view
        alertController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY, width: 0, height: 0)
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
    
    func updateAppIcon()
    {
        if UserInterfaceFeatures.shared.appIcon.isEnabled
        {
            if UserInterfaceFeatures.shared.appIcon.useTheme
            {
                guard UserInterfaceFeatures.shared.theme.isEnabled else
                {
                    UIApplication.shared.setAlternateIconName(nil)
                    return
                }
                
                switch UserInterfaceFeatures.shared.theme.accentColor
                {
                case .pink: UIApplication.shared.setAlternateIconName("IconPink")
                case .red: UIApplication.shared.setAlternateIconName("IconRed")
                case .orange: UIApplication.shared.setAlternateIconName(nil)
                case .yellow: UIApplication.shared.setAlternateIconName("IconYellow")
                case .green: UIApplication.shared.setAlternateIconName("IconGreen")
                case .mint: UIApplication.shared.setAlternateIconName("IconMint")
                case .teal: UIApplication.shared.setAlternateIconName("IconTeal")
                case .blue: UIApplication.shared.setAlternateIconName("IconBlue")
                case .purple: UIApplication.shared.setAlternateIconName("IconPurple")
                }
            }
            else
            {
                UIApplication.shared.setAlternateIconName(nil)
            }
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
            
        case AdvancedFeatures.shared.powerUser.$clearAutoSaves.settingsKey:
            guard let value = notification.userInfo?[Settings.NotificationUserInfoKey.value] as? Bool else { break }
            if value
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    AdvancedFeatures.shared.powerUser.clearAutoSaves = false
                    self.clearAutoSaveStates()
                }
            }
            
        case AdvancedFeatures.shared.powerUser.$resetBuildCounter.settingsKey:
            guard let value = notification.userInfo?[Settings.NotificationUserInfoKey.value] as? Bool else { break }
            if value
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    AdvancedFeatures.shared.powerUser.resetBuildCounter = false
                    self.resetBuildCounter()
                }
            }
            
        case UserInterfaceFeatures.shared.appIcon.settingsKey, UserInterfaceFeatures.shared.appIcon.$useTheme.settingsKey, UserInterfaceFeatures.shared.theme.settingsKey, UserInterfaceFeatures.shared.theme.$accentColor.settingsKey:
            self.updateAppIcon()
            
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
            case .gameplay: self.showGameplayFeatures()
            case .userInterface: self.showUserInterfaceFeatures()
            case .touchFeedback: self.showTouchFeedbackFeatures()
            case .advanced: self.showAdvancedFeatures()
            }
            
        case .resourceLinks:
            switch ResourceLinksRow.allCases[indexPath.row]
            {
            case .romPatcher: self.openWebsite(site: "https://www.marcrobledo.com/RomPatcher.js/")
            case .saveConverter: self.openWebsite(site: "https://www.save-editor.com/tools/wse_ds_save_converter.html")
            }
            
        case .cores:
            switch CoresRow.allCases[indexPath.row]
            {
            case .ds:
                self.performSegue(withIdentifier: Segue.dsSettings.rawValue, sender: cell)
            case .gbc:
                self.showGBCDeltaCoreFeatures()
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
            switch CreditsRow.allCases[indexPath.row]
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
        case .shortcuts where self.view.traitCollection.forceTouchCapability == .available: return NSLocalizedString("3D Touch", comment: "")
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
