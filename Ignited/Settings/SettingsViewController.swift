//
//  SettingsViewController.swift
//  Ignited
//
//  Created by Riley Testut on 9/4/15.
//  Copyright © 2015 Riley Testut. All rights reserved.
//

import UIKit
import SwiftUI
import QuickLook
import MessageUI

import DeltaCore

import Roxas
import Harmony

private extension SettingsViewController
{
    enum Section: Int, CaseIterable
    {
        case features
        case cores
        case controllers
        case controllerSkins
        case pro
        case syncing
        case shortcuts
        case skinDownloads
        case credits
        case support
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
        case library
        case gameplay
        case airPlay
        case standardSkin
        case controllers
        case touchFeedback
        case advanced
    }
    
    enum CoresRow: Int, CaseIterable
    {
        case snes
        case n64
        case gbc
        case gba
        case ds
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
        case softwareLicenses
    }
    
    enum SupportRow: Int, CaseIterable
    {
        case contact
        case errorLog
    }
}

class SettingsViewController: UITableViewController
{
    @IBOutlet private var versionLabel: UILabel!
    
    @IBOutlet private var exportLogActivityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet private var syncingServiceLabel: UILabel!
    
    @IBOutlet private var purchaseLabel: UILabel!
    
    private var selectionFeedbackGenerator: UISelectionFeedbackGenerator?
    
    private var previousSelectedRowIndexPath: IndexPath?
    
    private var syncingConflictsCount = 0
    
    private var _exportedLogURL: URL?
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsViewController.settingsDidChange(with:)), name: Settings.didChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsViewController.externalGameControllerDidConnect(_:)), name: .externalGameControllerDidConnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsViewController.externalGameControllerDidDisconnect(_:)), name: .externalGameControllerDidDisconnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsViewController.shouldDismissViewController(_:)), name: .dismissSettings, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsViewController.purchasesUpdated(_:)), name: PurchaseManager.purchasesUpdatedNotification, object: nil)
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
        
        self.tableView.register(AttributedHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: AttributedHeaderFooterView.reuseIdentifier)
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
        
        self.purchaseLabel.text = PurchaseManager.shared.hasUnlockedPro ? NSLocalizedString("Ignited Pro Unlocked", comment: ""): NSLocalizedString("Join Ignited Pro", comment: "")
        
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
    func showFeatures(featureGroup: FeatureGroup)
    {
        let hostingController = FeaturesView.makeViewController(featureGroup: featureGroup)
        self.navigationController?.pushViewController(hostingController, animated: true)
    }
    
    func showProPurchases()
    {
        let hostingController = PurchaseView.makeViewController()
        self.navigationController?.pushViewController(hostingController, animated: true)
    }
    
    func exportErrorLog()
    {
        self.exportLogActivityIndicatorView.startAnimating()

        if let indexPath = self.tableView.indexPathForSelectedRow
        {
            self.tableView.deselectRow(at: indexPath, animated: true)
        }

        Task<Void, Never>.detached(priority: .userInitiated) {
            do
            {
                let store = try OSLogStore(scope: .currentProcessIdentifier)

                // All logs since the app launched.
                let position = store.position(timeIntervalSinceLatestBoot: 0)
                let predicate = NSPredicate(format: "subsystem IN %@", [Logger.ignitedSubsystem, Logger.harmonySubsystem])

                let entries = try store.getEntries(at: position, matching: predicate)
                    .compactMap { $0 as? OSLogEntryLog }
                    .map { "[\($0.date.formatted())] [\($0.category)] [\($0.level.localizedName)] \($0.composedMessage)" }

                let outputText = entries.joined(separator: "\n")

                let outputDirectory = FileManager.default.uniqueTemporaryURL()
                try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)

                let outputURL = outputDirectory.appendingPathComponent("Ignited-Errors.log")
                try outputText.write(to: outputURL, atomically: true, encoding: .utf8)

                await MainActor.run {
                    self._exportedLogURL = outputURL

                    let previewController = QLPreviewController()
                    previewController.delegate = self
                    previewController.dataSource = self
                    self.present(previewController, animated: true)
                }
            }
            catch
            {
                print("Failed to export Harmony logs.", error)
            }

            await self.exportLogActivityIndicatorView.stopAnimating()
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
    
    @objc func purchasesUpdated(_ notification: Notification)
    {
        self.update()
    }
}

extension SettingsViewController
{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection sectionIndex: Int) -> Int
    {
        let section = Section(rawValue: sectionIndex)!
        
        if isSectionHidden(section)
        {
            return 0
        }
        else
        {
            switch section
            {
            case .controllers: return 4 // Temporarily hide other controller indexes until controller logic is finalized
            case .controllerSkins: return System.registeredSystems.count + 1
            case .syncing: return SyncManager.shared.coordinator?.account == nil ? 1 : super.tableView(tableView, numberOfRowsInSection: sectionIndex)
            default: return super.tableView(tableView, numberOfRowsInSection: sectionIndex)
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
                cell.detailTextLabel?.text = LocalDeviceController().name
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
            switch CoresRow.allCases[indexPath.row]
            {
            case .gbc:
                let preferredCore = Settings.preferredCore(for: .gbc)
                cell.detailTextLabel?.text = preferredCore?.metadata?.name.value ?? preferredCore?.name ?? NSLocalizedString("Unknown", comment: "")
                
            case .gba:
                let preferredCore = Settings.preferredCore(for: .gba)
                cell.detailTextLabel?.text = preferredCore?.metadata?.name.value ?? preferredCore?.name ?? NSLocalizedString("Unknown", comment: "")
                
            case .ds:
                let preferredCore = Settings.preferredCore(for: .ds)
                cell.detailTextLabel?.text = preferredCore?.metadata?.name.value ?? preferredCore?.name ?? NSLocalizedString("Unknown", comment: "")
                
            default: break
            }
            
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
            case .gameplay: self.showFeatures(featureGroup: .gameplay)
            case .standardSkin: self.showFeatures(featureGroup: .standardSkin)
            case .controllers: self.showFeatures(featureGroup: .controllers)
            case .airPlay: self.showFeatures(featureGroup: .airPlay)
            case .library: self.showFeatures(featureGroup: .library)
            case .userInterface: self.showFeatures(featureGroup: .userInterface)
            case .touchFeedback: self.showFeatures(featureGroup: .touchFeedback)
            case .advanced: self.showFeatures(featureGroup: .advanced)
            }
            
        case .cores:
            switch CoresRow.allCases[indexPath.row]
            {
            case .snes: self.showFeatures(featureGroup: .snes)
            case .gbc: self.showFeatures(featureGroup: .gbc)
            case .gba: self.showFeatures(featureGroup: .gba)
            case .n64: self.showFeatures(featureGroup: .n64)
            case .ds: self.performSegue(withIdentifier: Segue.dsSettings.rawValue, sender: cell)
            }
            
        case .pro:
            self.showProPurchases()
            
            tableView.deselectRow(at: indexPath, animated: true)
            
        case .credits:
            switch CreditsRow.allCases[indexPath.row]
            {
            case .developer: UIApplication.shared.openAppOrWebpage(site: "https://github.com/LitRitt")
            case .softwareLicenses: break
            }
            
        case .support:
            let row = SupportRow(rawValue: indexPath.row)!
            switch row
            {
            case .errorLog:
                self.exportErrorLog()

            case .contact:
                if MFMailComposeViewController.canSendMail()
                {
                    let mailViewController = MFMailComposeViewController()
                    mailViewController.mailComposeDelegate = self
                    mailViewController.setToRecipients(["support@ignitedemulator.com"])

                    if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
                    {
                        mailViewController.setSubject("Ignited \(version) Feedback")
                    }
                    else
                    {
                        mailViewController.setSubject("Ignited Feedback")
                    }

                    self.present(mailViewController, animated: true, completion: nil)
                }
                else
                {
                    ToastView.show(NSLocalizedString("Cannot Send Mail", comment: ""), in: self.navigationController?.view ?? self.view, onEdge: .bottom, duration: 4.0)
                }
                
                tableView.deselectRow(at: indexPath, animated: true)
            }
            
        default: break
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        let section = Section(rawValue: section)!
        guard !isSectionHidden(section) else { return nil }
        
        switch section
        {
        case .controllerSkins:
            guard let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: AttributedHeaderFooterView.reuseIdentifier) as? AttributedHeaderFooterView else { break }
            
            var attributedText = AttributedString(localized: "Customize the appearance of each system.")
            attributedText += " "
            
            var learnMore = AttributedString(localized: "Learn more…")
            learnMore.link = URL(string: "https://docs.ignitedemulator.com/using-ignited/settings/controller-skins")
            attributedText += learnMore
            
            footerView.attributedText = attributedText
            
            return footerView
            
        default: break
        }
        
        return super.tableView(tableView, viewForFooterInSection: section.rawValue)
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
        guard !isSectionHidden(section) else { return nil }
        
        switch section
        {
        case .controllerSkins: return nil
        default: return super.tableView(tableView, titleForFooterInSection: section.rawValue)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        let section = Section(rawValue: section)!
        guard !isSectionHidden(section) else { return 1 }
        
        return super.tableView(tableView, heightForHeaderInSection: section.rawValue)
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        let section = Section(rawValue: section)!
        guard !isSectionHidden(section) else { return 1 }
        
        switch section
        {
        case .controllerSkins: return UITableView.automaticDimension
        default: return super.tableView(tableView, heightForFooterInSection: section.rawValue)
        }
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat
    {
        let section = Section(rawValue: section)!
        guard !isSectionHidden(section) else { return 1 }
        
        switch section
        {
        case .controllerSkins: return 30
        default: return UITableView.automaticDimension
        }
    }
}

extension SettingsViewController: MFMailComposeViewControllerDelegate
{
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        if let error = error
        {
            let toastView = RSTToastView(error: error)
            toastView.show(in: self.navigationController?.view ?? self.view, duration: 4.0)
        }

        controller.dismiss(animated: true, completion: nil)
    }
}

extension SettingsViewController: QLPreviewControllerDataSource, QLPreviewControllerDelegate
{
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int
    {
        return 1
    }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem
    {
        return (_exportedLogURL as? NSURL) ?? NSURL()
    }

    func previewControllerDidDismiss(_ controller: QLPreviewController)
    {
        guard let exportedLogURL = _exportedLogURL else { return }

        let parentDirectory = exportedLogURL.deletingLastPathComponent()
        try? FileManager.default.removeItem(at: parentDirectory)

        _exportedLogURL = nil
    }
}
