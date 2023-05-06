//
//  PauseViewController.swift
//  Delta
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
        return [self.saveStateItem, self.loadStateItem, self.restartItem, self.screenshotItem, self.statusBarItem, self.sustainButtonsItem, self.rewindItem, self.fastForwardItem, self.cheatCodesItem, self.altSkinItem, self.debugModeItem, self.debugDeviceItem].compactMap { $0 }
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
    var altSkinItem: MenuItem?
    var debugModeItem: MenuItem?
    var debugDeviceItem: MenuItem?
    
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
            navigationBarAppearance.backgroundEffect = UIBlurEffect(style: .dark)
            navigationBarAppearance.backgroundColor = UIColor.black.withAlphaComponent(0.2)
            navigationBarAppearance.shadowColor = UIColor.white.withAlphaComponent(0.2)
            navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
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
        self.sustainButtonsItem = nil
        self.fastForwardItem = nil
        self.debugModeItem = nil
        self.debugDeviceItem = nil
        
        guard self.emulatorCore != nil else { return }
        
        self.saveStateItem = MenuItem(text: NSLocalizedString("Save State", comment: ""), image: #imageLiteral(resourceName: "SaveSaveState"), action: { [unowned self] _ in
            self.saveStatesViewControllerMode = .saving
            self.performSegue(withIdentifier: "saveStates", sender: self)
        })
        
        self.loadStateItem = MenuItem(text: NSLocalizedString("Load State", comment: ""), image: #imageLiteral(resourceName: "LoadSaveState"), action: { [unowned self] _ in
            self.saveStatesViewControllerMode = .loading
            self.performSegue(withIdentifier: "saveStates", sender: self)
        })
        
        self.restartItem = MenuItem(text: NSLocalizedString("Restart", comment: ""), image: #imageLiteral(resourceName: "Restart"), action: { _ in })
        
        if GameplayFeatures.shared.screenshots.isEnabled
        {
            self.screenshotItem = MenuItem(text: NSLocalizedString("Screenshot", comment: ""), image: #imageLiteral(resourceName: "Screenshot"), action: { _ in })
        }
        
        if UserInterfaceFeatures.shared.statusBar.isEnabled && UserInterfaceFeatures.shared.statusBar.useToggle
        {
            self.statusBarItem = MenuItem(text: NSLocalizedString("Status Bar", comment: ""), image: #imageLiteral(resourceName: "StatusBar"), action: { _ in })
        }
        
        if GameplayFeatures.shared.rewind.isEnabled
        {
            self.rewindItem = MenuItem(text: NSLocalizedString("Rewind", comment: ""), image: #imageLiteral(resourceName: "Rewind"), action: { [unowned self] _ in
                self.saveStatesViewControllerMode = .rewind
                self.performSegue(withIdentifier: "saveStates", sender: self)
            })
        }
        
        if GameplayFeatures.shared.fastForward.isEnabled
        {
            self.fastForwardItem = MenuItem(text: NSLocalizedString("Fast Forward", comment: ""), image: #imageLiteral(resourceName: "FastForward"), action: { _ in })
        }
        
        if GameplayFeatures.shared.cheats.isEnabled {
            self.cheatCodesItem = MenuItem(text: NSLocalizedString("Cheat Codes", comment: ""), image: #imageLiteral(resourceName: "CheatCodes"), action: { [unowned self] _ in
                self.performSegue(withIdentifier: "cheats", sender: self)
            })
        }
        
        self.sustainButtonsItem = MenuItem(text: NSLocalizedString("Hold Buttons", comment: ""), image: #imageLiteral(resourceName: "SustainButtons"), action: { _ in })
        
        if AdvancedFeatures.shared.skinDebug.hasAlt
        {
            self.altSkinItem = MenuItem(text: NSLocalizedString("Alternate Skin", comment: ""), image: #imageLiteral(resourceName: "AltSkin"), action: { _ in })
        }
        
        if AdvancedFeatures.shared.skinDebug.isEnabled || AdvancedFeatures.shared.skinDebug.skinEnabled
        {
            self.debugModeItem = MenuItem(text: NSLocalizedString("Debug Mode", comment: ""), image: #imageLiteral(resourceName: "Debug"), action: { _ in })
            self.debugDeviceItem = MenuItem(text: NSLocalizedString("Debug Device", comment: ""), image: #imageLiteral(resourceName: "DebugDevice"), action: { _ in })
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
