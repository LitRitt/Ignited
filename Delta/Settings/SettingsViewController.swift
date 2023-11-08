//
//  SettingsViewController.swift
//  Delta
//
//  Created by Riley Testut on 9/4/15.
//  Copyright © 2015 Riley Testut. All rights reserved.
//

import UIKit
import SwiftUI

import DeltaCore

import Roxas

private extension SettingsViewController
{
    enum Section: Int, CaseIterable
    {
        case patreon
        case syncing
        case features
        case cores
        case controllers
        case controllerSkins
        case shortcuts
        case skinDownloads
        case resourceLinks
        case credits
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
        case controllerSkins
        case gamesCollection
        case userInterface
        case touchFeedback
        case advanced
    }
    
    enum SkinDownloadsRow: Int, CaseIterable
    {
        case classicSkins
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
        case n64
        case gbc
        case ds
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
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsViewController.shouldDismissViewController(_:)), name: .dismissSettings, object: nil)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if let version = Bundle.main.versionNumber
        {
            self.versionLabel.text = NSLocalizedString(String(format: "Ignited v%@", version), comment: "Ignited Version")
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
            
            if indexPath.row < System.registeredSystems.count
            {
                let system = System.registeredSystems[indexPath.row]
                preferredControllerSkinsViewController.system = system
            }
            
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
    
    func showControllerSkinFeatures()
    {
        let hostingController = ControllerSkinFeaturesView.makeViewController()
        self.navigationController?.pushViewController(hostingController, animated: true)
    }
    
    func showGamesCollectionFeatures()
    {
        let hostingController = GamesCollectionFeaturesView.makeViewController()
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
    
    func showN64Features()
    {
        let hostingController = N64FeaturesView.makeViewController()
        self.navigationController?.pushViewController(hostingController, animated: true)
    }
    
    func showGBCFeatures()
    {
        let hostingController = GBCFeaturesView.makeViewController()
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
    
    @objc func shouldDismissViewController(_ notification: Notification)
    {
        self.dismiss(animated: true)
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
        case .controllerSkins: return System.registeredSystems.count + 1
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
            if indexPath.row < System.registeredSystems.count
            {
                cell.textLabel?.text = System.registeredSystems[indexPath.row].localizedName
            }
            else
            {
                cell.textLabel?.text = "All Systems"
            }
                        
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
            case .classicSkins: UIApplication.shared.openWebpage(site: "https://litritt.com/ignited/classic-skins")
            case .litDesign: UIApplication.shared.openWebpage(site: "https://design.litritt.com")
            case .skinGenerator: UIApplication.shared.openWebpage(site: "https://generator.skins4delta.com")
            case .deltaSkins: UIApplication.shared.openWebpage(site: "https://delta-skins.github.io")
            case .skins4Delta: UIApplication.shared.openWebpage(site: "https://skins4delta.com")
            }
            
        case .features:
            switch FeaturesRow.allCases[indexPath.row]
            {
            case .gameplay: self.showGameplayFeatures()
            case .controllerSkins: self.showControllerSkinFeatures()
            case .gamesCollection: self.showGamesCollectionFeatures()
            case .userInterface: self.showUserInterfaceFeatures()
            case .touchFeedback: self.showTouchFeedbackFeatures()
            case .advanced: self.showAdvancedFeatures()
            }
            
        case .resourceLinks:
            switch ResourceLinksRow.allCases[indexPath.row]
            {
            case .romPatcher: UIApplication.shared.openWebpage(site: "https://www.marcrobledo.com/RomPatcher.js/")
            case .saveConverter: UIApplication.shared.openWebpage(site: "https://www.save-editor.com/tools/wse_ds_save_converter.html")
            }
            
        case .officialLinks:
            switch OfficialLinksRow.allCases[indexPath.row]
            {
            case .github: UIApplication.shared.openAppOrWebpage(site: "https://github.com/LitRitt/Ignited")
            case .discord: UIApplication.shared.openAppOrWebpage(site: "https://discord.gg/qEtKFJt5dR")
            case .docs: UIApplication.shared.openWebpage(site: "https://docs.ignitedemulator.com")
            case .changelog: UIApplication.shared.openWebpage(site: "https://docs.ignitedemulator.com/release-notes")
            }
            
        case .cores:
            switch CoresRow.allCases[indexPath.row]
            {
            case .gbc:
                self.showGBCFeatures()
            case .n64:
                self.showN64Features()
            case .ds:
                self.performSegue(withIdentifier: Segue.dsSettings.rawValue, sender: cell)
            }
            
        case .patreon:
            switch PatreonRow.allCases[indexPath.row]
            {
            case .patreonLink: UIApplication.shared.openAppOrWebpage(site: "https://www.patreon.com/litritt")
            case .patrons: self.showPatrons()
            }
            
            tableView.deselectRow(at: indexPath, animated: true)
            
        case .credits:
            switch CreditsRow.allCases[indexPath.row]
            {
            case .developer: UIApplication.shared.openAppOrWebpage(site: "https://github.com/LitRitt")
            case .contributors: self.showContributors()
            case .softwareLicenses: break
            }
            
        default: break
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
        {
        primary:
            switch Section(rawValue: indexPath.section)!
            {
            case .cores:
                let row = CoresRow(rawValue: indexPath.row)!
                switch row
                {
                case .n64:
//                    return 0.0
                    break
                    
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
