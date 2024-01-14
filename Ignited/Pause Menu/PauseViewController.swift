//
//  PauseViewController.swift
//  Ignited
//
//  Created by Riley Testut on 1/30/16.
//  Copyright © 2016 Riley Testut. All rights reserved.
//

import UIKit

import DeltaCore

class PauseViewController: UIViewController, PauseInfoProviding
{
    var emulatorCore: EmulatorCore? {
        didSet {
            self.updatePauseItems()
        }
    }
    
    var pauseItems: [MenuItem] {
        var items: [MenuItem?] = []
        
        for item in Settings.gameplayFeatures.pauseMenu.buttonOrder
        {
            items.append(self.pauseItem(for: item))
        }
        
        return items.compactMap { $0 }
    }
    
    /// Pause Items
    var saveStateItem: MenuItem?
    var loadStateItem: MenuItem?
    var restartItem: MenuItem?
    var screenshotItem: MenuItem?
    var statusBarItem: MenuItem?
    var cheatCodesItem: MenuItem?
    var fastForwardItem: MenuItem?
    var sustainButtonsItem: MenuItem?
    var rewindItem: MenuItem?
    var microphoneItem: MenuItem?
    var rotationLockItem: MenuItem?
    var paletteItem: MenuItem?
    var quickSettingsItem: MenuItem?
    var blurBackgroudItem: MenuItem?
    var altSkinItem: MenuItem?
    var debugModeItem: MenuItem?
    
    /// PauseInfoProviding
    var pauseText: String?
    
    /// Cheats
    weak var cheatsViewControllerDelegate: CheatsViewControllerDelegate?
    
    /// Save States
    weak var saveStatesViewControllerDelegate: SaveStatesViewControllerDelegate?
    
    private var saveStatesViewControllerMode = SaveStatesViewController.Mode.loading
    
    private var pauseNavigationController: UINavigationController!
    
    /// UIViewController
    override var preferredContentSize: CGSize {
        set { }
        get
        {
            var preferredContentSize = self.pauseNavigationController.topViewController?.preferredContentSize ?? CGSize.zero
            if preferredContentSize.height > 0
            {
                preferredContentSize.height += self.pauseNavigationController.navigationBar.bounds.height
            }
            
            return preferredContentSize
        }
    }
    
    override var navigationController: UINavigationController? {
        return self.pauseNavigationController
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        self.updateSafeAreaInsets()
    }
}

extension PauseViewController
{
    override func targetViewController(forAction action: Selector, sender: Any?) -> UIViewController?
    {
        return self.pauseNavigationController
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        guard let identifier = segue.identifier else { return }
        
        switch identifier
        {
        case "embedNavigationController":
            self.pauseNavigationController = segue.destination as? UINavigationController
            self.pauseNavigationController.delegate = self
            self.pauseNavigationController.navigationBar.tintColor = UIColor.themeColor
            self.pauseNavigationController.view.backgroundColor = UIColor.clear
            
            let gridMenuViewController = self.pauseNavigationController.topViewController as! GridMenuViewController
            
            let navigationBarAppearance = self.pauseNavigationController.navigationBar.standardAppearance.copy()
            navigationBarAppearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
//            navigationBarAppearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.2)
            
//            navigationBarAppearance.shadowColor = UIColor.label.withAlphaComponent(0.2)
            self.pauseNavigationController.navigationBar.standardAppearance = navigationBarAppearance
            
            let transparentBarAppearance = navigationBarAppearance.copy()
            transparentBarAppearance.backgroundColor = nil
            transparentBarAppearance.backgroundEffect = nil
            gridMenuViewController.navigationItem.standardAppearance = transparentBarAppearance
            
            gridMenuViewController.items = self.pauseItems
            
        case "saveStates":
            let saveStatesViewController = segue.destination as! SaveStatesViewController
            saveStatesViewController.delegate = self.saveStatesViewControllerDelegate
            saveStatesViewController.mode = self.saveStatesViewControllerMode
            saveStatesViewController.game = self.emulatorCore?.game as? Game
            saveStatesViewController.emulatorCore = self.emulatorCore
            
        case "cheats":
            let cheatsViewController = segue.destination as! CheatsViewController
            cheatsViewController.delegate = self.cheatsViewControllerDelegate
            cheatsViewController.game = self.emulatorCore?.game as? Game
            
        default: break
        }
    }
}

extension PauseViewController
{
    func dismiss()
    {
        self.performSegue(withIdentifier: "unwindFromPauseMenu", sender: self)
    }
}

extension PauseViewController: UINavigationControllerDelegate
{
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        let transitionCoordinator = PauseTransitionCoordinator(presentationController: self.presentationController!)
        transitionCoordinator.presenting = (operation == .push)
        return transitionCoordinator
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool)
    {
        self.updateSafeAreaInsets()
    }
}

private extension PauseViewController
{
    func updatePauseItems()
    {
        self.saveStateItem = nil
        self.loadStateItem = nil
        self.restartItem = nil
        self.screenshotItem = nil
        self.statusBarItem = nil
        self.cheatCodesItem = nil
        self.paletteItem = nil
        self.quickSettingsItem = nil
        self.blurBackgroudItem = nil
        self.sustainButtonsItem = nil
        self.fastForwardItem = nil
        self.debugModeItem = nil
        
        guard self.emulatorCore != nil else { return }
        
        self.saveStateItem = MenuItem(text: NSLocalizedString("Save State", comment: ""),
                                      image: UIImage.symbolWithTemplate(name: "tray.and.arrow.down.fill"),
                                      action: { [unowned self] _ in
            self.saveStatesViewControllerMode = .saving
            self.performSegue(withIdentifier: "saveStates", sender: self)
        })
        
        self.loadStateItem = MenuItem(text: NSLocalizedString("Load State", comment: ""),
                                      image: UIImage.symbolWithTemplate(name: "tray.and.arrow.up.fill"),
                                      action: { [unowned self] _ in
            self.saveStatesViewControllerMode = .loading
            self.performSegue(withIdentifier: "saveStates", sender: self)
        })
        
        self.restartItem = MenuItem(text: NSLocalizedString("Restart", comment: ""),
                                    image: UIImage.symbolWithTemplate(name: "backward.end.fill"),
                                    action: { _ in })
        
        self.screenshotItem = MenuItem(text: NSLocalizedString("Screenshot", comment: ""),
                                       image: UIImage.symbolWithTemplate(name: "camera.fill"),
                                       action: { _ in })
        
        self.statusBarItem = MenuItem(text: NSLocalizedString("Status Bar", comment: ""),
                                      image: UIImage.symbolWithTemplate(name: "clock.fill"),
                                      action: { _ in })
        
        if Settings.gameplayFeatures.rewind.isEnabled
        {
            self.rewindItem = MenuItem(text: NSLocalizedString("Rewind", comment: ""),
                                       image: UIImage.symbolWithTemplate(name: "backward.frame.fill"),
                                       action: { [unowned self] _ in
                self.saveStatesViewControllerMode = .rewind
                self.performSegue(withIdentifier: "saveStates", sender: self)
            })
        }
        
        self.fastForwardItem = MenuItem(text: NSLocalizedString("Fast Forward", comment: ""),
                                        image: UIImage.symbolWithTemplate(name: "forward.fill"),
                                        action: { _ in })
        
        self.microphoneItem = MenuItem(text: NSLocalizedString("Microphone", comment: ""),
                                        image: UIImage.symbolWithTemplate(name: "mic.fill"),
                                        action: { _ in })
        
        if Settings.gameplayFeatures.rotationLock.isEnabled
        {
            self.rotationLockItem = MenuItem(text: NSLocalizedString("Rotation Lock", comment: ""),
                                             image: UIImage.symbolWithTemplate(name: "lock.fill"),
                                             action: { _ in })
        }
        
        if Settings.gameplayFeatures.cheats.isEnabled {
            self.cheatCodesItem = MenuItem(text: NSLocalizedString("Cheat Codes", comment: ""),
                                           image: UIImage.symbolWithTemplate(name: "key.fill"),
                                           action: { [unowned self] _ in
                self.performSegue(withIdentifier: "cheats", sender: self)
            })
        }
        
        self.paletteItem = MenuItem(text: NSLocalizedString("Color Palette", comment: ""),
                                    image: UIImage.symbolWithTemplate(name: "swatchpalette.fill"),
                                    action: { _ in })
        
        self.quickSettingsItem = MenuItem(text: NSLocalizedString("Quick Settings", comment: ""),
                                          image: UIImage.symbolWithTemplate(name: "gearshape.fill"),
                                          action: { _ in })
        
        self.blurBackgroudItem = MenuItem(text: NSLocalizedString("Background Blur", comment: ""),
                                              image: UIImage.symbolWithTemplate(name: "aqi.medium"),
                                              action: { _ in })
        
        self.sustainButtonsItem = MenuItem(text: NSLocalizedString("Hold Buttons", comment: ""),
                                           image: UIImage.symbolWithTemplate(name: "button.horizontal.top.press.fill", backupSymbolName: "digitalcrown.horizontal.press"),
                                           action: { _ in })
        
        if Settings.advancedFeatures.skinDebug.hasAlt
        {
            self.altSkinItem = MenuItem(text: NSLocalizedString("Alternate Skin", comment: ""),
                                        image: UIImage.symbolWithTemplate(name: "switch.2"),
                                        action: { _ in })
        }
        
        if Settings.advancedFeatures.skinDebug.isEnabled || Settings.advancedFeatures.skinDebug.skinEnabled
        {
            self.debugModeItem = MenuItem(text: NSLocalizedString("Debug Mode", comment: ""),
                                          image: UIImage.symbolWithTemplate(name: "ant.fill"),
                                          action: { _ in })
        }
    }
    func updateSafeAreaInsets()
    {
        if self.navigationController?.topViewController == self.navigationController?.viewControllers.first
        {
            self.additionalSafeAreaInsets.left = self.view.window?.safeAreaInsets.left ?? 0
            self.additionalSafeAreaInsets.right = self.view.window?.safeAreaInsets.right ?? 0
        }
        else
        {
            self.additionalSafeAreaInsets.left = 0
            self.additionalSafeAreaInsets.right = 0
        }
    }
}

private extension PauseViewController
{
    func pauseItem(for itemString: String) -> MenuItem?
    {
        switch itemString
        {
        case "Save State": return self.saveStateItem
        case "Load State": return self.loadStateItem
        case "Restart": return self.restartItem
        case "Screenshot": return self.screenshotItem
        case "Status Bar": return self.statusBarItem
        case "Sustain Buttons": return self.sustainButtonsItem
        case "Rewind": return self.rewindItem
        case "Fast Forward": return self.fastForwardItem
        case "Microphone": return self.microphoneItem
        case "Rotation Lock": return self.rotationLockItem
        case "Palettes": return self.paletteItem
        case "Quick Settings": return self.quickSettingsItem
        case "Backgroud Blur": return self.blurBackgroudItem
        case "Cheat Codes": return self.cheatCodesItem
        case "Alt Skin": return self.altSkinItem
        case "Debug Mode": return self.debugModeItem
        default: return nil
        }
    }
}
