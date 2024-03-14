//
//  GameViewController.swift
//  Ignited
//
//  Created by Riley Testut on 5/5/15.
//  Copyright © 2016 Riley Testut. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

import DeltaCore
import GBADeltaCore
import GBCDeltaCore
import N64DeltaCore
import MelonDSDeltaCore
import GPGXDeltaCore
import SNESDeltaCore
import Systems

import struct DSDeltaCore.DS

import Roxas
import AltKit

private var kvoContext = 0

private extension GameViewController
{
    struct PausedSaveState: SaveStateProtocol
    {
        var fileURL: URL
        var gameType: GameType
        
        var isSaved = false
        
        init(fileURL: URL, gameType: GameType)
        {
            self.fileURL = fileURL
            self.gameType = gameType
        }
    }
    
    struct DefaultInputMapping: GameControllerInputMappingProtocol
    {
        let gameController: GameController
        
        var gameControllerInputType: GameControllerInputType {
            return self.gameController.inputType
        }
        
        func input(forControllerInput controllerInput: Input) -> Input?
        {
            if let mappedInput = self.gameController.defaultInputMapping?.input(forControllerInput: controllerInput)
            {
                return mappedInput
            }
            
            // Only intercept controller skin inputs.
            guard controllerInput.type == .controller(.controllerSkin) else { return nil }
            
            let actionInput = ActionInput(stringValue: controllerInput.stringValue)
            return actionInput
        }
    }
    
    struct SustainInputsMapping: GameControllerInputMappingProtocol
    {
        let gameController: GameController
        
        var gameControllerInputType: GameControllerInputType {
            return self.gameController.inputType
        }
        
        func input(forControllerInput controllerInput: Input) -> Input?
        {
            if let mappedInput = self.gameController.defaultInputMapping?.input(forControllerInput: controllerInput), mappedInput == StandardGameControllerInput.menu
            {
                return mappedInput
            }
            
            return controllerInput
        }
    }
}

class GameViewController: DeltaCore.GameViewController
{
    /// Assumed to be Delta.Game instance
    override var game: GameProtocol? {
        willSet {
            self.emulatorCore?.removeObserver(self, forKeyPath: #keyPath(EmulatorCore.state), context: &kvoContext)
            
            let game = self.game as? Game
            NotificationCenter.default.removeObserver(self, name: .NSManagedObjectContextDidSave, object: game?.managedObjectContext)
        }
        didSet {
            self.emulatorCore?.addObserver(self, forKeyPath: #keyPath(EmulatorCore.state), options: [.old], context: &kvoContext)
            
            let game = self.game as? Game
            NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.managedObjectContextDidChange(with:)), name: .NSManagedObjectContextObjectsDidChange, object: game?.managedObjectContext)
            
            self.emulatorCore?.saveHandler = { [weak self] _ in self?.updateGameSave() }
            
            if oldValue?.fileURL != game?.fileURL
            {
                self.shouldResetSustainedInputs = true
            }
            
            self.updateControllers()
            self.updateCoreSettings()
            self.updateGraphics()
            self.updateAudio()
            
            self.presentedGyroAlert = false
            self.isEditingOverscanInsets = false
            self.overscanEditorView.isHidden = true
            
            self.clearRewindSaveStates()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.updateBackgroundBlur()
            }
        }
    }
    
    //MARK: - Private Properties -
    private var pauseViewController: PauseViewController?
    private var pausingGameController: GameController?
    
    // Prevents the same save state from being saved multiple times
    private var pausedSaveState: PausedSaveState? {
        didSet
        {
            if let saveState = oldValue, self.pausedSaveState == nil
            {
                do
                {
                    try FileManager.default.removeItem(at: saveState.fileURL)
                }
                catch
                {
                    print(error)
                }
            }
        }
    }
    
    private var _deepLinkResumingSaveState: SaveStateProtocol? {
        didSet {
            guard let saveState = oldValue, _deepLinkResumingSaveState == nil else { return }
            
            do
            {
                try FileManager.default.removeItem(at: saveState.fileURL)
            }
            catch
            {
                print(error)
            }
        }
    }
    
    private var _isLoadingSaveState = false
    private var _isQuickSettingsOpen = false
        
    // Sustain Buttons
    private var isSelectingSustainedButtons = false
    private var sustainInputsMapping: SustainInputsMapping?
    private var shouldResetSustainedInputs = false
    private var isSustainingInputs = false
    
    private var sustainButtonsContentView: UIView!
    private var sustainButtonsBlurView: UIVisualEffectView!
    private var sustainButtonsBackgroundView: RSTPlaceholderView!
    
    private var overscanEditorView: OverscanEditorView!
    private var isEditingOverscanInsets = false
    
    private var rewindTimer: Timer?
    
    private var buttonSoundFile: AVAudioFile?
    private var buttonSoundPlayer: AVAudioPlayer?
    
    private var isMicEnabled: Bool {
        get {
            if let game = self.game,
               game.type != .ds
            {
                return false
            }
            else
            {
                return Settings.gameplayFeatures.micSupport.isEnabled
            }
        }
    }
    
    private var batteryLowNotificationShown = false
    
    private var isGyroActive = false
    private var presentedGyroAlert = false
    
    private var isOrientationLocked = false
    private var lockedOrientation: UIInterfaceOrientationMask? = nil
    
    private var presentedJITAlert = false
    
    private var overrideToastNotification = false
    
    public var deepLinkSaveState: SaveState? {
        didSet {
            if let deepLinkSaveState = self.deepLinkSaveState
            {
                self._isLoadingSaveState = true
                self.overrideToastNotification = true
                
                self.load(deepLinkSaveState)
                
                self.deepLinkSaveState = nil
            }
        }
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if Settings.gameplayFeatures.rotationLock.isEnabled || self.isGyroActive,
           let orientation = self.lockedOrientation
        {
            return orientation
        }
        else
        {
            return .all
        }
    }
    
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return .all
    }
    
    override var prefersStatusBarHidden: Bool {
        return !Settings.userInterfaceFeatures.statusBar.isEnabled
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Settings.userInterfaceFeatures.statusBar.style.value
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.controllerView.invalidateImageCache()
        self.updateControllers()
        self.updateBackgroundBlur()
        self.updateStatusBar()
    }
    
    required init()
    {
        super.init()
        
        self.initialize()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        self.initialize()
    }
    
    private func initialize()
    {
        self.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.updateControllers), name: .externalGameControllerDidConnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.updateControllers), name: .externalGameControllerDidDisconnect, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.didEnterBackground(with:)), name: UIApplication.didEnterBackgroundNotification, object: UIApplication.shared)
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.appWillBecomeInactive(with:)), name: UIApplication.willResignActiveNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.settingsDidChange(with:)), name: Settings.didChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.deepLinkControllerLaunchGame(with:)), name: .deepLinkControllerLaunchGame, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.didActivateGyro(with:)), name: GBA.didActivateGyroNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.didDeactivateGyro(with:)), name: GBA.didDeactivateGyroNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.emulationDidQuit(with:)), name: EmulatorCore.emulationDidQuitNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.didEnableJIT(with:)), name: ServerManager.didEnableJITNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.sceneWillConnect(with:)), name: UIScene.willConnectNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.sceneDidDisconnect(with:)), name: UIScene.didDisconnectNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.unwindFromQuickSettings), name: .unwindFromSettings, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.deviceDidShake(with:)), name: UIDevice.deviceDidShakeNotification, object: nil)
        
        // Battery
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.batteryLevelDidChange(with:)), name: UIDevice.batteryLevelDidChangeNotification, object: nil)
    }
    
    deinit
    {
        self.emulatorCore?.removeObserver(self, forKeyPath: #keyPath(EmulatorCore.state), context: &kvoContext)
        
        self.invalidateRewindTimer()
    }
    
    // MARK: - GameControllerReceiver -
    override func gameController(_ gameController: GameController, didActivate input: Input, value: Double)
    {
        super.gameController(gameController, didActivate: input, value: value)
        
        if self.isSelectingSustainedButtons
        {
            guard let pausingGameController = self.pausingGameController, gameController == pausingGameController else { return }
            
            if input != StandardGameControllerInput.menu,
               input.stringValue != "quickSettings",
               let game = self.game as? Game
            {
                self.isSustainingInputs = true
                var inputsToSustain = self.getInputs(for: game)
                inputsToSustain[AnyInput(input)] = value
                Settings.gameplayFeatures.sustainButtons.heldInputs[game.identifier] = inputsToSustain
            }
            
            if input.stringValue == "quickSettings"
            {
                self.performQuickSettingsAction()
            }
        }
        else if let emulatorCore = self.emulatorCore, emulatorCore.state == .running
        {
            guard let actionInput = ActionInput(input: input) else { return }
            
            func fastForwardInput()
            {
                switch Settings.gameplayFeatures.fastForward.mode {
                case .toggle:
                    let isFastForwarding = (emulatorCore.rate != emulatorCore.deltaCore.supportedRates.lowerBound)
                    self.performFastForwardAction(activate: !isFastForwarding)
                    
                case .hold:
                    self.performFastForwardAction(activate: true)
                }
            }
            
            switch actionInput
            {
            case .null: break
            case .restart: self.performRestartAction()
            case .quickSave: self.performQuickSaveAction()
            case .quickLoad: self.performQuickLoadAction()
            case .screenshot: self.performScreenshotAction()
            case .statusBar: self.performStatusBarAction()
            case .toggleAltRepresentations: self.performAltRepresentationsAction()
                
            case .toggleFastForward, .fastForward: fastForwardInput()
                
            case .quickSettings:
                if let action = Settings.gameplayFeatures.quickSettings.buttonReplacement,
                   Settings.proFeaturesEnabled
                {
                    switch action
                    {
                    case .fastForward: fastForwardInput()
                    case .quickSave: self.performQuickSaveAction()
                    case .quickLoad: self.performQuickLoadAction()
                    case .screenshot: self.performScreenshotAction()
                    case .restart: self.performRestartAction()
                    default: break
                    }
                }
                else
                {
                    self.performQuickSettingsAction()
                }
                
            }
        }
    }
    
    override func gameController(_ gameController: GameController, didDeactivate input: Input)
    {
        super.gameController(gameController, didDeactivate: input)
        
        if self.isSelectingSustainedButtons
        {
            if input.isContinuous,
               let game = self.game as? Game
            {
                var inputsToSustain = self.getInputs(for: game)
                inputsToSustain[AnyInput(input)] = nil
                Settings.gameplayFeatures.sustainButtons.heldInputs[game.identifier] = inputsToSustain
            }
        }
        else
        {
            guard let actionInput = ActionInput(input: input) else { return }
            
            switch actionInput
            {
            case .null: break
            case .restart: break
            case .quickSave: break
            case .quickLoad: break
            case .screenshot: break
            case .statusBar: break
            case .quickSettings: break
            case .fastForward, .toggleFastForward:
                if Settings.gameplayFeatures.fastForward.mode == .hold
                {
                    self.performFastForwardAction(activate: false)
                }
            case .toggleAltRepresentations: break
            }
        }
    }
}


//MARK: - UIViewController -
/// UIViewController
extension GameViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Lays out self.gameView, so we can pin self.sustainButtonsContentView to it without resulting in a temporary "cannot satisfy constraints".
        self.view.layoutIfNeeded()
        
        self.controllerView.translucentControllerSkinOpacity = Settings.controllerFeatures.skin.opacity
        
        let overscanEditorNib = UINib(nibName: "OverscanEditorView", bundle: nil)
        self.overscanEditorView = overscanEditorNib.instantiate(withOwner: nil, options: nil)[0] as? OverscanEditorView
        self.overscanEditorView.isHidden = true
        self.view.insertSubview(self.overscanEditorView, aboveSubview: self.gameView)
        
        self.overscanEditorView.applyButton.addTarget(self, action: #selector(GameViewController.applyOverscanInsets), for: .touchDown)
        self.overscanEditorView.doneButton.addTarget(self, action: #selector(GameViewController.finishEditingOverscanInsets), for: .touchDown)
        self.overscanEditorView.resetButton.addTarget(self, action: #selector(GameViewController.resetOverscanInsets), for: .touchDown)
        
        self.overscanEditorView.topInsetIncreaseButton.addTarget(self, action: #selector(GameViewController.overscanTopInsetIncrease), for: .touchDown)
        self.overscanEditorView.topInsetDecreaseButton.addTarget(self, action: #selector(GameViewController.overscanTopInsetDecrease), for: .touchDown)
        self.overscanEditorView.bottomInsetIncreaseButton.addTarget(self, action: #selector(GameViewController.overscanBottomInsetIncrease), for: .touchDown)
        self.overscanEditorView.bottomInsetDecreaseButton.addTarget(self, action: #selector(GameViewController.overscanBottomInsetDecrease), for: .touchDown)
        self.overscanEditorView.leftInsetIncreaseButton.addTarget(self, action: #selector(GameViewController.overscanLeftInsetIncrease), for: .touchDown)
        self.overscanEditorView.leftInsetDecreaseButton.addTarget(self, action: #selector(GameViewController.overscanLeftInsetDecrease), for: .touchDown)
        self.overscanEditorView.rightInsetIncreaseButton.addTarget(self, action: #selector(GameViewController.overscanRightInsetIncrease), for: .touchDown)
        self.overscanEditorView.rightInsetDecreaseButton.addTarget(self, action: #selector(GameViewController.overscanRightInsetDecrease), for: .touchDown)
        
        self.sustainButtonsContentView = UIView(frame: CGRect(x: 0, y: 0, width: self.gameView.bounds.width, height: self.gameView.bounds.height))
        self.sustainButtonsContentView.translatesAutoresizingMaskIntoConstraints = false
        self.sustainButtonsContentView.isHidden = true
        self.view.insertSubview(self.sustainButtonsContentView, aboveSubview: self.gameView)
        
        let blurEffect = UIBlurEffect(style: .systemThinMaterial)
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        
        self.sustainButtonsBlurView = UIVisualEffectView(effect: blurEffect)
        self.sustainButtonsBlurView.frame = CGRect(x: 0, y: 0, width: self.sustainButtonsContentView.bounds.width, height: self.sustainButtonsContentView.bounds.height)
        self.sustainButtonsBlurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.sustainButtonsContentView.addSubview(self.sustainButtonsBlurView)
        
        let sustainButtonsVibrancyView = UIVisualEffectView(effect: vibrancyEffect)
        sustainButtonsVibrancyView.frame = CGRect(x: 0, y: 0, width: self.sustainButtonsBlurView.contentView.bounds.width, height: self.sustainButtonsBlurView.contentView.bounds.height)
        sustainButtonsVibrancyView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.sustainButtonsBlurView.contentView.addSubview(sustainButtonsVibrancyView)
        
        self.sustainButtonsBackgroundView = RSTPlaceholderView(frame: CGRect(x: 0, y: 0, width: sustainButtonsVibrancyView.contentView.bounds.width, height: sustainButtonsVibrancyView.contentView.bounds.height))
        self.sustainButtonsBackgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.sustainButtonsBackgroundView.textLabel.text = NSLocalizedString("Select Buttons to Hold Down", comment: "")
        self.sustainButtonsBackgroundView.textLabel.numberOfLines = 1
        self.sustainButtonsBackgroundView.textLabel.minimumScaleFactor = 0.5
        self.sustainButtonsBackgroundView.textLabel.adjustsFontSizeToFitWidth = true
        self.sustainButtonsBackgroundView.detailTextLabel.text = NSLocalizedString("Press the Menu button or Quick Settings button when finished.", comment: "")
        self.sustainButtonsBackgroundView.alpha = 0.0
        sustainButtonsVibrancyView.contentView.addSubview(self.sustainButtonsBackgroundView)
        
        // Auto Layout
        self.overscanEditorView.translatesAutoresizingMaskIntoConstraints = false
        self.overscanEditorView.leadingAnchor.constraint(equalTo: self.gameView.leadingAnchor).isActive = true
        self.overscanEditorView.trailingAnchor.constraint(equalTo: self.gameView.trailingAnchor).isActive = true
        self.overscanEditorView.topAnchor.constraint(equalTo: self.gameView.topAnchor).isActive = true
        self.overscanEditorView.bottomAnchor.constraint(equalTo: self.gameView.bottomAnchor).isActive = true
        
        self.sustainButtonsContentView.leadingAnchor.constraint(equalTo: self.gameView.leadingAnchor).isActive = true
        self.sustainButtonsContentView.trailingAnchor.constraint(equalTo: self.gameView.trailingAnchor).isActive = true
        self.sustainButtonsContentView.topAnchor.constraint(equalTo: self.gameView.topAnchor).isActive = true
        self.sustainButtonsContentView.bottomAnchor.constraint(equalTo: self.gameView.bottomAnchor).isActive = true
        
        self.updateControllers()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        if self.emulatorCore?.deltaCore == DS.core, UserDefaults.standard.desmumeDeprecatedAlertCount < 3
        {
            ToastView.show(NSLocalizedString("DeSmuME Core Deprecated", comment: ""), in: self.view, detailText: NSLocalizedString("Switch to the melonDS core in Settings for latest improvements.", comment: ""), onEdge: .top, duration: 5.0)
            
            UserDefaults.standard.desmumeDeprecatedAlertCount += 1
        }
        else if self.emulatorCore?.deltaCore == MelonDS.core, ProcessInfo.processInfo.isJITAvailable
        {
            self.showJITEnabledAlert()
        }
        
        self.activateRewindTimer()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
    {
        super.viewWillTransition(to: size, with: coordinator)
        
        guard UIApplication.shared.applicationState != .background else { return }
                
        coordinator.animate(alongsideTransition: { (context) in
            self.updateControllerSkin()
        }, completion: nil)        
    }
    
    // MARK: - Segues
    /// KVO
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        guard let identifier = segue.identifier else { return }
        
        switch identifier
        {
        case "showInitialGamesViewController":
            let gamesViewController = (segue.destination as! UINavigationController).topViewController as! GamesViewController
            
            gamesViewController.theme = .opaque
            
        case "showGamesViewController":
            let gamesViewController = (segue.destination as! UINavigationController).topViewController as! GamesViewController
            
            if let emulatorCore = self.emulatorCore
            {
                gamesViewController.theme = .translucent
                gamesViewController.activeEmulatorCore = emulatorCore
                
                self.updateAutoSaveState()
            }
            else
            {
                gamesViewController.theme = .opaque
            }
            
            gamesViewController.updatePlayMenu()
            
        case "pause":
            
            if let game = self.game
            {
                let fileURL = FileManager.default.uniqueTemporaryURL()
                self.pausedSaveState = PausedSaveState(fileURL: fileURL, gameType: game.type)
                
                self.emulatorCore?.saveSaveState(to: fileURL)
            }

            guard let gameController = sender as? GameController else {
                fatalError("sender for pauseSegue must be the game controller that pressed the Menu button")
            }
            
            self.pausingGameController = gameController
            
            let pauseViewController = segue.destination as! PauseViewController
            pauseViewController.pauseText = (self.game as? Game)?.name ?? NSLocalizedString("Ignited", comment: "")
            pauseViewController.emulatorCore = self.emulatorCore
            pauseViewController.saveStatesViewControllerDelegate = self
            if Settings.gameplayFeatures.cheats.isEnabled {
                pauseViewController.cheatsViewControllerDelegate = self
            }
            
            pauseViewController.saveStateItem?.holdAction = { [unowned self] item in
                self.performQuickSaveAction()
            }
            pauseViewController.loadStateItem?.holdAction = { [unowned self] item in
                self.performQuickLoadAction()
            }
            
            pauseViewController.restartItem?.action = { [unowned self] item in
                self.performRestartAction()
            }
            
            pauseViewController.screenshotItem?.action = { [unowned self] item in
                self.performScreenshotAction()
            }
            pauseViewController.screenshotItem?.holdAction = { [unowned self] item in
                self.performScreenshotAction(hold: true)
            }
            
            pauseViewController.statusBarItem?.isSelected = Settings.userInterfaceFeatures.statusBar.isEnabled
            pauseViewController.statusBarItem?.action = { [unowned self] item in
                self.performStatusBarAction()
            }
            pauseViewController.statusBarItem?.holdAction = { [unowned self] item in
                self.performStatusBarAction(hold: true)
            }
            
            pauseViewController.microphoneItem?.isSelected = Settings.gameplayFeatures.micSupport.isEnabled
            pauseViewController.microphoneItem?.action = { [unowned self] item in
                self.performMicrophoneAction()
            }
            
            func makeFastForwardSpeedMenu() -> UIMenu
            {
                var fastForwardOptions: [UIMenuElement] = []
                
                for speed in FastForwardSpeed.allCases
                {
                    fastForwardOptions.append(
                        UIAction(title: speed.description,
                                 image: speed.rawValue > 1 ? UIImage(systemName: "hare") : UIImage(systemName: "tortoise"),
                                 state: Settings.gameplayFeatures.fastForward.speed == speed.rawValue ? .on : .off,
                                 handler: { action in
                                     self.updateFastForwardSpeed(speed: speed.rawValue)
                                     pauseViewController.fastForwardItem?.menu = makeFastForwardSpeedMenu()
                        })
                    )
                }
                
                return UIMenu(title: NSLocalizedString("Fast Forward Speed", comment: ""),
                              children: fastForwardOptions)
            }
            
            pauseViewController.fastForwardItem?.isSelected = (self.emulatorCore?.rate != self.emulatorCore?.deltaCore.supportedRates.lowerBound)
            pauseViewController.fastForwardItem?.action = { [unowned self] item in
                self.performFastForwardAction(activate: item.isSelected)
            }
            pauseViewController.fastForwardItem?.menu = makeFastForwardSpeedMenu()
            
            pauseViewController.rotationLockItem?.isSelected = self.isOrientationLocked
            pauseViewController.rotationLockItem?.action = { [unowned self] item in
                self.performRotationLockAction()
            }
            
            pauseViewController.paletteItem?.action = { [unowned self] item in
                self.performPaletteAction()
            }
            
            pauseViewController.quickSettingsItem?.action = { [unowned self] item in
                self.performQuickSettingsAction()
            }
            
            pauseViewController.blurBackgroudItem?.isSelected = Settings.controllerFeatures.backgroundBlur.isEnabled
            pauseViewController.blurBackgroudItem?.action = { [unowned self] item in
                self.performBackgroundBlurAction()
            }
            
            pauseViewController.overscanEditorItem?.isSelected = self.isEditingOverscanInsets
            pauseViewController.overscanEditorItem?.action = { [unowned self] item in
                self.performOverscanEditorAction()
            }
            
            pauseViewController.altSkinItem?.isSelected = Settings.advancedFeatures.skinDebug.useAlt
            pauseViewController.altSkinItem?.action = { [unowned self] item in
                self.performAltRepresentationsAction()
            }
            
            pauseViewController.debugModeItem?.isSelected = Settings.advancedFeatures.skinDebug.isOn
            pauseViewController.debugModeItem?.action = { [unowned self] item in
                self.performDebugModeAction()
            }
            
            pauseViewController.sustainButtonsItem?.isSelected = gameController.sustainedInputs.count > 0 || self.isSustainingInputs
            pauseViewController.sustainButtonsItem?.action = { [unowned self, unowned pauseViewController] item in
                
                guard let game = self.game as? Game else { return }
                
                let heldInputs = self.getInputs(for: game)
                
                if heldInputs.count == 0
                {
                    for input in gameController.sustainedInputs.keys
                    {
                        gameController.unsustain(input)
                    }
                    
                    if item.isSelected
                    {
                        self.showSustainButtonView()
                        pauseViewController.dismiss()
                    }
                }
                else
                {
                    if Settings.gameplayFeatures.pauseMenu.holdButtonsDismisses
                    {
                        pauseViewController.dismiss()
                    }
                    
                    self.updateSustainedButtons(gameController: gameController)
                }
                
                // Re-set gameController as pausingGameController.
                self.pausingGameController = gameController
            }
            pauseViewController.sustainButtonsItem?.holdAction = { [unowned self, unowned pauseViewController] item in
                
                for input in gameController.sustainedInputs.keys
                {
                    gameController.unsustain(input)
                }
                
                if item.isSelected
                {
                    self.showSustainButtonView()
                    pauseViewController.dismiss()
                }
            }
            
            if let game = self.game,
               game.type != .gbc || game.fileURL.pathExtension.lowercased() != "gb"
            {
                pauseViewController.paletteItem = nil
            }
            
            if let game = self.game,
               game.type != .ds
            {
                pauseViewController.microphoneItem = nil
            }
            
            if let game = self.game,
               game.type != .n64
            {
                pauseViewController.overscanEditorItem = nil
            }
            
            switch self.game?.type
            {
            case .ds? where self.emulatorCore?.deltaCore == DS.core:
                // Cheats are not supported by DeSmuME core.
                pauseViewController.cheatCodesItem = nil
                // Microphone is not supported by DeSmuME core.
                pauseViewController.microphoneItem = nil
                
            case .genesis?, .ms?, .gg?:
                // GPGX core does not support cheats yet.
                pauseViewController.cheatCodesItem = nil
                
            case .gbc?:
                // Rewind is disabled on GBC. Crashes gambette
                pauseViewController.rewindItem = nil

            default: break
            }
            
            if let url = self.game?.fileURL,
               let fileName = url.path.components(separatedBy: "/").last
            {
                switch fileName
                {
                case "dsi.bios":
                    pauseViewController.rewindItem = nil
                    pauseViewController.saveStateItem = nil
                    pauseViewController.loadStateItem = nil
                    pauseViewController.cheatCodesItem = nil
                    
                case "nds.bios":
                    pauseViewController.cheatCodesItem = nil
                    
                default: break
                }
            }
            
            self.pauseViewController = pauseViewController
            
        default: break
        }
    }
    
    @IBAction private func unwindFromPauseViewController(_ segue: UIStoryboardSegue)
    {
        self.pauseViewController = nil
        self.pausingGameController = nil
        
        guard let identifier = segue.identifier else { return }
        
        switch identifier
        {
        case "unwindFromPauseMenu":
            
            self.pausedSaveState = nil
            
            DispatchQueue.main.async {
                
                if self._isLoadingSaveState
                {
                    // If loading save state, resume emulation immediately (since the game view needs to be updated ASAP)
                    
                    if self.resumeEmulation()
                    {
                        // Temporarily disable audioManager to prevent delayed audio bug when using 3D Touch Peek & Pop
                        self.emulatorCore?.audioManager.isEnabled = false
                        
                        // Re-enable after delay
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self.emulatorCore?.audioManager.isEnabled = true
                        }
                    }
                }
                else
                {
                    // Otherwise, wait for the transition to complete before resuming emulation
                    self.transitionCoordinator?.animate(alongsideTransition: nil, completion: { (context) in
                        self.resumeEmulation()
                    })
                }
                
                self._isLoadingSaveState = false
                
                if self.emulatorCore?.deltaCore == MelonDS.core, ProcessInfo.processInfo.isJITAvailable
                {
                    self.transitionCoordinator?.animate(alongsideTransition: nil, completion: { (context) in
                        self.showJITEnabledAlert()
                    })
                }
            }
            
        case "unwindToGames":
            DispatchQueue.main.async {
                self.transitionCoordinator?.animate(alongsideTransition: nil, completion: { (context) in
                    self.performSegue(withIdentifier: "showGamesViewController", sender: nil)
                })
            }
            
        default: break
        }
    }
    
    @IBAction private func unwindFromGamesViewController(with segue: UIStoryboardSegue)
    {
        self.pausedSaveState = nil
        
        if let emulatorCore = self.emulatorCore, emulatorCore.state == .paused
        {
            emulatorCore.resume()
        }
    }
    
    // MARK: - KVO
    /// KVO
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
    {
        guard context == &kvoContext else { return super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context) }
        
        guard let rawValue = change?[.oldKey] as? Int, let previousState = EmulatorCore.State(rawValue: rawValue) else { return }
        
        if let saveState = _deepLinkResumingSaveState, let emulatorCore = self.emulatorCore, emulatorCore.state == .running
        {
            emulatorCore.pause()
            
            do
            {
                try emulatorCore.load(saveState)
            }
            catch
            {
                print(error)
            }
            
            _deepLinkResumingSaveState = nil
            emulatorCore.resume()
        }
        
        if previousState == .stopped
        {
            self.emulatorCore?.updateCheats()
        }
        
        if self.emulatorCore?.state == .running
        {
            DatabaseManager.shared.performBackgroundTask { (context) in
                guard let game = self.game as? Game else { return }
                
                let backgroundGame = context.object(with: game.objectID) as! Game
                backgroundGame.playedDate = Date()
                
                context.saveWithErrorLogging()
            }
        }
    }
}

//MARK: - Controllers -
private extension GameViewController
{
    @objc func updateControllers()
    {
        let isExternalGameControllerConnected = ExternalGameControllerManager.shared.connectedControllers.contains(where: { $0.playerIndex != nil })
        if !isExternalGameControllerConnected && Settings.localControllerPlayerIndex == nil
        {
            Settings.localControllerPlayerIndex = 0
        }
        
        // If Settings.localControllerPlayerIndex is non-nil, and there isn't a connected controller with same playerIndex, show controller view.
        if let index = Settings.localControllerPlayerIndex, !ExternalGameControllerManager.shared.connectedControllers.contains(where: { $0.playerIndex == index })
        {
            self.controllerView.playerIndex = index
            self.controllerView.isHidden = self.isEditingOverscanInsets
        }
        else
        {
            if let game = self.game,
               let traits = self.controllerView.controllerSkinTraits,
               let standardSkin = StandardControllerSkin(for: game.type),
               standardSkin.hasTouchScreen(for: traits)
            {
                if Settings.controllerFeatures.controller.hideSkin
                {
                    Settings.localControllerPlayerIndex = nil
                }
                else
                {
                    Settings.localControllerPlayerIndex = 0
                }
                self.controllerView.isHidden = false
                self.controllerView.playerIndex = 0
            }
            else
            {
                if Settings.controllerFeatures.controller.hideSkin || self.isEditingOverscanInsets
                {
                    self.controllerView.isHidden = true
                    self.controllerView.playerIndex = nil // TODO: Does this need changed to 0?
                    Settings.localControllerPlayerIndex = nil
                }
                else
                {
                    self.controllerView.isHidden = false
                    self.controllerView.playerIndex = 0
                    Settings.localControllerPlayerIndex = 0
                }
            }
        }
        
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        
        // Roundabout way of combining arrays to prevent rare runtime crash in + operator :(
        var controllers = [GameController]()
        controllers.append(self.controllerView)
        controllers.append(contentsOf: ExternalGameControllerManager.shared.connectedControllers)
        
        if let emulatorCore = self.emulatorCore, let game = self.game
        {
            for gameController in controllers
            {
                if gameController.playerIndex != nil
                {
                    let inputMapping: GameControllerInputMappingProtocol
                    
                    if let mapping = GameControllerInputMapping.inputMapping(for: gameController, gameType: game.type, in: DatabaseManager.shared.viewContext)
                    {
                        inputMapping = mapping
                    }
                    else
                    {
                        inputMapping = DefaultInputMapping(gameController: gameController)
                    }
                    
                    gameController.addReceiver(self, inputMapping: inputMapping)
                    gameController.addReceiver(emulatorCore, inputMapping: inputMapping)
                }
                else
                {
                    gameController.removeReceiver(self)
                    gameController.removeReceiver(emulatorCore)
                }
            }
        }
        
        if self.shouldResetSustainedInputs
        {
            for controller in controllers
            {
                for input in controller.sustainedInputs.keys
                {
                    controller.unsustain(input)
                }
            }
            
            self.shouldResetSustainedInputs = false
        }
        
        let vibrationEnabled = Settings.touchFeedbackFeatures.touchVibration.isEnabled
        self.controllerView.isButtonHapticFeedbackEnabled = Settings.touchFeedbackFeatures.touchVibration.buttonsEnabled && vibrationEnabled
        self.controllerView.isThumbstickHapticFeedbackEnabled = Settings.touchFeedbackFeatures.touchVibration.sticksEnabled && vibrationEnabled
        self.controllerView.isClickyHapticEnabled = Settings.touchFeedbackFeatures.touchVibration.releaseEnabled && vibrationEnabled
        self.controllerView.hapticFeedbackStrength = Settings.touchFeedbackFeatures.touchVibration.strength
        
        self.controllerView.isButtonTouchOverlayEnabled = Settings.touchFeedbackFeatures.touchOverlay.isEnabled
        self.controllerView.touchOverlayOpacity = Settings.touchFeedbackFeatures.touchOverlay.opacity
        self.controllerView.touchOverlaySize = Settings.touchFeedbackFeatures.touchOverlay.size
        self.controllerView.touchOverlayColor = Settings.touchFeedbackFeatures.touchOverlay.color.uiColor
        self.controllerView.touchOverlayStyle = Settings.touchFeedbackFeatures.touchOverlay.style
        
        self.controllerView.isAltRepresentationsEnabled = Settings.advancedFeatures.skinDebug.useAlt
        self.controllerView.isDebugModeEnabled = Settings.advancedFeatures.skinDebug.isOn && Settings.advancedFeatures.skinDebug.isEnabled
        
        self.controllerView.updateControllerSkin()
        self.updateControllerSkin()
        
        self.updateButtonAudioFeedbackSound()
        self.updateGameboyPalette()
        self.updateBackgroundBlur()
        self.updateControllerSkinCustomization()
        self.updateControllerTriggerDeadzone()
    }
    
    func getInputs(for game: Game) -> [AnyInput: Double]
    {
        if let heldInputs = Settings.gameplayFeatures.sustainButtons.heldInputs[game.identifier]
        {
            return heldInputs
        }
        else
        {
            Settings.gameplayFeatures.sustainButtons.heldInputs[game.identifier] = [:]
            
            return [:]
        }
    }
    
    func updateControllerTriggerDeadzone()
    {
        for gameController in ExternalGameControllerManager.shared.connectedControllers
        {
            gameController.triggerDeadzone = Float(Settings.controllerFeatures.controller.triggerDeadzone)
        }
    }
    
    func updateButtonAudioFeedbackSound()
    {
        let sound = Settings.touchFeedbackFeatures.touchAudio.sound
        
        guard let buttonSoundURL = Bundle.main.url(forResource: sound.fileName, withExtension: sound.fileExtension) else
        {
            fatalError("Audio file not found")
        }
        
        do
        {
            try self.buttonSoundFile = AVAudioFile(forReading: buttonSoundURL)
            try self.buttonSoundPlayer = AVAudioPlayer(contentsOf: buttonSoundURL)
            
            self.buttonSoundPlayer?.volume = Float(Settings.touchFeedbackFeatures.touchAudio.useGameVolume ? Settings.gameplayFeatures.gameAudio.volume : Settings.touchFeedbackFeatures.touchAudio.buttonVolume)
        }
        catch
        {
            print(error)
        }
        
        self.controllerView.buttonPressedHandler = { [weak self] () in
            if Settings.touchFeedbackFeatures.touchAudio.isEnabled,
               let buttonSoundPlayer = self?.buttonSoundPlayer
            {
                buttonSoundPlayer.play()
            }
        }
    }
    
    func playButtonAudioFeedbackSound()
    {
        if let buttonSoundPlayer = self.buttonSoundPlayer
        {
            buttonSoundPlayer.volume = 1.0
            buttonSoundPlayer.play()
            buttonSoundPlayer.volume = Float(Settings.touchFeedbackFeatures.touchAudio.useGameVolume ? Settings.gameplayFeatures.gameAudio.volume : Settings.touchFeedbackFeatures.touchAudio.buttonVolume)
        }
    }
    
    func updateStatusBar()
    {
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    func updateControllerSkin()
    {
        guard let game = self.game as? Game, let window = self.view.window else { return }
        
        var traits = DeltaCore.ControllerSkin.Traits.defaults(for: window)
        
        if (Settings.advancedFeatures.skinDebug.skinEnabled || Settings.advancedFeatures.skinDebug.isEnabled) && Settings.advancedFeatures.skinDebug.traitOverride
        {
            switch Settings.advancedFeatures.skinDebug.device
            {
            case .iphone: traits.device = .iphone
            case .ipad: traits.device = .ipad
            case .tv: traits.device = .tv
            }
            
            switch Settings.advancedFeatures.skinDebug.displayType
            {
            case .standard: traits.displayType = .standard
            case .edgeToEdge: traits.displayType = .edgeToEdge
            case .splitView: traits.displayType = .splitView
            }
            
            self.controllerView.overrideControllerSkinTraits = traits
        }
        else
        {
            self.controllerView.overrideControllerSkinTraits = nil
        }
        
        if Settings.localControllerPlayerIndex != nil
        {
            let controllerSkin = Settings.preferredControllerSkin(for: game, traits: traits)
            
            if let controllerSkin = controllerSkin,
               controllerSkin.isStandard
            {
                let standardSkin = StandardControllerSkin(for: game.type)
                self.controllerView.controllerSkin = standardSkin
            }
            else
            {
                self.controllerView.controllerSkin = controllerSkin
            }
        }
        else if let standardSkin = StandardControllerSkin(for: game.type), standardSkin.hasTouchScreen(for: traits)
        {
            var touchControllerSkin = TouchControllerSkin(controllerSkin: standardSkin)
            
            if UIApplication.shared.isExternalDisplayConnected,
               Settings.airplayFeatures.device.bottomScreenOnly
            {
                // Only show touch screen if external display is connected.
                touchControllerSkin.screenPredicate = { $0.isTouchScreen }
            }
            
            if self.view.bounds.width > self.view.bounds.height
            {
                touchControllerSkin.screenLayoutAxis = .horizontal
            }
            else
            {
                touchControllerSkin.screenLayoutAxis = .vertical
            }
            
            self.controllerView.controllerSkin = touchControllerSkin
        }
        
        Settings.advancedFeatures.skinDebug.skinEnabled = self.controllerView.controllerSkin?.isDebugModeEnabled ?? false
        Settings.advancedFeatures.skinDebug.hasAlt = self.controllerView.controllerSkin?.hasAltRepresentations ?? false
        
        self.updateExternalDisplay()
        
        self.view.setNeedsLayout()
    }
    
    func updateGameViews()
    {
        if UIApplication.shared.isExternalDisplayConnected,
           Settings.airplayFeatures.device.disableScreen
        {
            // AirPlaying, hide all screens except touchscreens and blur screens.
                 
            if let traits = self.controllerView.controllerSkinTraits,
               let screens = self.screens(for: traits)
            {
                for (screen, gameView) in zip(screens, self.gameViews)
                {
                    let enabled = screen.isTouchScreen
                    
                    gameView.isEnabled = enabled
                    
                    if gameView == self.gameView
                    {
                        // Always show AirPlay indicator on self.gameView
                        if !gameView.isTouchScreen
                        {
                            gameView.isAirPlaying = true
                        }
                        gameView.isHidden = false
                    }
                    else
                    {
                        gameView.isHidden = !enabled
                    }
                }
            }
            else
            {
                // Either self.controllerView.controllerSkin is `nil`, or it doesn't support these traits.
                // Most likely this system only has 1 screen, so just hide self.gameView.
                     
                self.gameView.isEnabled = false
                self.gameView.isHidden = false
                if !self.gameView.isTouchScreen
                {
                    self.gameView.isAirPlaying = Settings.airplayFeatures.device.disableScreen
                }
            }
        }
        else
        {
            // Not AirPlaying, show all screens.
                 
            for gameView in self.gameViews
            {
                gameView.isEnabled = true
                gameView.isHidden = false
                gameView.isAirPlaying = false
            }
        }
    }
    
    @objc func unwindFromQuickSettings()
    {
        self._isQuickSettingsOpen = false
        
        self.updateBackgroundBlur()
        self.controllerView.invalidateImageCache()
        self.updateControllerSkin()
    }
    
    func updateBackgroundBlur()
    {
        switch Settings.controllerFeatures.backgroundBlur.tintColor
        {
        case .none: self.blurTintView.backgroundColor = Settings.controllerFeatures.backgroundBlur.tintColor.uiColor.withAlphaComponent(0)
        default: self.blurTintView.backgroundColor = Settings.controllerFeatures.backgroundBlur.tintColor.uiColor.withAlphaComponent(Settings.controllerFeatures.backgroundBlur.tintOpacity)
        }
        
        self.blurGameViewBlurView.effect = UIBlurEffect(style: Settings.controllerFeatures.backgroundBlur.style.blurStyle)
        
        self.blurScreenKeepAspect = Settings.controllerFeatures.backgroundBlur.maintainAspect
        self.blurScreenEnabled = Settings.controllerFeatures.backgroundBlur.isEnabled && !self.isEditingOverscanInsets
        
        if let scene = UIApplication.shared.externalDisplayScene
        {
            switch Settings.controllerFeatures.backgroundBlur.tintColor
            {
            case .none: scene.gameViewController.blurTintView.backgroundColor = Settings.controllerFeatures.backgroundBlur.tintColor.uiColor.withAlphaComponent(0)
            default: scene.gameViewController.blurTintView.backgroundColor = Settings.controllerFeatures.backgroundBlur.tintColor.uiColor.withAlphaComponent(Settings.controllerFeatures.backgroundBlur.tintOpacity)
            }
            
            scene.gameViewController.blurGameViewBlurView.effect = UIBlurEffect(style: Settings.controllerFeatures.backgroundBlur.style.blurStyle)
            
            scene.gameViewController.blurScreenKeepAspect = Settings.controllerFeatures.backgroundBlur.maintainAspect
            scene.gameViewController.blurScreenEnabled = Settings.controllerFeatures.backgroundBlur.isEnabled && Settings.airplayFeatures.display.backgroundBlur
        }
    }
    
    func updateGameboyPalette()
    {
        if let bridge = self.emulatorCore?.deltaCore.emulatorBridge as? GBCEmulatorBridge
        {
            if Settings.gbFeatures.palettes.multiPalette
            {
                setMultiPalette(palette1: Settings.gbFeatures.palettes.palette.colors,
                                palette2: Settings.gbFeatures.palettes.spritePalette1.colors,
                                palette3: Settings.gbFeatures.palettes.spritePalette2.colors)
            }
            else
            {
                setSinglePalette(palette: Settings.gbFeatures.palettes.palette.colors)
            }
            
            bridge.updatePalette()
            
            
            func setSinglePalette(palette: [UInt32])
            {
                bridge.palette0color0 = palette[0]
                bridge.palette0color1 = palette[1]
                bridge.palette0color2 = palette[2]
                bridge.palette0color3 = palette[3]
                bridge.palette1color0 = palette[0]
                bridge.palette1color1 = palette[1]
                bridge.palette1color2 = palette[2]
                bridge.palette1color3 = palette[3]
                bridge.palette2color0 = palette[0]
                bridge.palette2color1 = palette[1]
                bridge.palette2color2 = palette[2]
                bridge.palette2color3 = palette[3]
            }
            
            func setMultiPalette(palette1: [UInt32], palette2: [UInt32], palette3: [UInt32])
            {
                bridge.palette0color0 = palette1[0]
                bridge.palette0color1 = palette1[1]
                bridge.palette0color2 = palette1[2]
                bridge.palette0color3 = palette1[3]
                bridge.palette1color0 = palette2[0]
                bridge.palette1color1 = palette2[1]
                bridge.palette1color2 = palette2[2]
                bridge.palette1color3 = palette2[3]
                bridge.palette2color0 = palette3[0]
                bridge.palette2color1 = palette3[1]
                bridge.palette2color2 = palette3[2]
                bridge.palette2color3 = palette3[3]
            }
        }
    }
    
    func updateControllerSkinCustomization()
    {
        self.controllerView.translucentControllerSkinOpacity = Settings.controllerFeatures.skin.opacity
        
        self.controllerView.isDiagonalDpadInputsEnabled = Settings.controllerFeatures.skin.diagonalDpad
        
        self.backgroundColor = self.isEditingOverscanInsets ? UIColor.red : Settings.controllerFeatures.skin.colorMode.uiColor
    }
    
    func updateSustainedButtons(gameController: GameController)
    {
        if self.isSustainingInputs
        {
            self.isSustainingInputs = false
            
            for input in gameController.sustainedInputs.keys
            {
                gameController.unsustain(input)
            }
        }
        else if let game = self.game as? Game
        {
            self.isSustainingInputs = true
            
            let inputsToSustain = self.getInputs(for: game)
            
            for (input, value) in inputsToSustain
            {
                gameController.sustain(input, value: value)
            }
        }
    }
}

//MARK: - Game Saves -
/// Game Saves
private extension GameViewController
{
    func updateGameSave()
    {
        guard let game = self.game as? Game else { return }
        
        DatabaseManager.shared.performBackgroundTask { (context) in
            do
            {
                let game = context.object(with: game.objectID) as! Game
                
                let hash = try RSTHasher.sha1HashOfFile(at: game.gameSaveURL)
                let previousHash = game.gameSave?.sha1
                
                guard hash != previousHash else { return }
                
                if let gameSave = game.gameSave
                {
                    gameSave.modifiedDate = Date()
                    gameSave.sha1 = hash
                }
                else
                {
                    let gameSave = GameSave(context: context)
                    gameSave.identifier = game.identifier
                    gameSave.sha1 = hash
                    game.gameSave = gameSave
                }
                
                try context.save()
                if Settings.userInterfaceFeatures.toasts.gameSave
                {
                    let text = NSLocalizedString("Game Saved", comment: "")
                    self.presentToastView(text: text)
                }
                
                // update auto save state to prevent overwriting newer game saves when loading latest auto save
                if game.type != .n64 // N64 saves game when saving state, causing loop
                {
                    self.updateAutoSaveState()
                }
            }
            catch CocoaError.fileNoSuchFile
            {
                // Ignore
            }
            catch
            {
                print("Error updating game save.", error)
            }
        }
    }
}

//MARK: - Save States -
/// Save States
extension GameViewController: SaveStatesViewControllerDelegate
{
    private func updateAutoSaveState(_ ignoringAutoSaveOption: Bool = false, shouldSuspendEmulation: Bool = true)
    {
        guard Settings.gameplayFeatures.saveStates.autoSave || ignoringAutoSaveOption else { return }
        
        // Ensures game is non-nil and also a Game subclass
        guard let game = self.game as? Game else { return }
        
        guard let emulatorCore = self.emulatorCore, emulatorCore.state != .stopped else { return }
        
        // If pausedSaveState exists and has already been saved, don't update auto save state
        // This prevents us from filling our auto save state slots with the same save state
        let savedPausedSaveState = self.pausedSaveState?.isSaved ?? false
        guard !savedPausedSaveState else { return }
        
        self.pausedSaveState?.isSaved = true
        
        // Must be done synchronously
        let backgroundContext = DatabaseManager.shared.newBackgroundContext()
        backgroundContext.performAndWait {
            
            let game = backgroundContext.object(with: game.objectID) as! Game
            
            let fetchRequest = SaveState.fetchRequest(for: game, type: .auto)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(SaveState.creationDate), ascending: true)]
            
            do
            {
                let saveStates = try fetchRequest.execute()
                
                if let saveState = saveStates.first, saveStates.count >= 2
                {
                    // If there are two or more auto save states, update the oldest one
                    self.update(saveState, with: self.pausedSaveState, shouldSuspendEmulation: shouldSuspendEmulation)
                    
                    // Tiny hack: SaveStatesViewController sorts save states by creation date, so we update the creation date too
                    // Simpler than deleting old save states ¯\_(ツ)_/¯
                    saveState.creationDate = saveState.modifiedDate
                }
                else
                {
                    // Otherwise, create a new one
                    let saveState = SaveState.insertIntoManagedObjectContext(backgroundContext)
                    saveState.type = .auto
                    saveState.game = game
                    
                    self.update(saveState, with: self.pausedSaveState)
                }
            }
            catch
            {
                print(error)
            }

            backgroundContext.saveWithErrorLogging()
        }
    }
    
    private func clearRewindSaveStates(afterDate: Date? = nil)
    {
        guard let game = self.game as? Game,
              Settings.gameplayFeatures.rewind.keepStates == false else { return }
        
        let fetchRequest = SaveState.fetchRequest(for: game, type: .rewind)
        fetchRequest.includesPropertyValues = false
        
        // if afterDate is included, we have rewound and should clear any rewind states that exist after our new time location
        if let afterDate = afterDate
        {
            fetchRequest.predicate = NSPredicate(format: "%K == %@ AND %K >= %@", #keyPath(SaveState.type), NSNumber(value: SaveStateType.rewind.rawValue), #keyPath(SaveState.creationDate), afterDate as NSDate)
        }
        else
        {
            fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(SaveState.type), NSNumber(value: SaveStateType.rewind.rawValue))
        }
        
        DatabaseManager.shared.performBackgroundTask { (context) in
            do
            {
                let saveStates = try context.fetch(fetchRequest)
                for saveState in saveStates {
                    let temporarySaveState = context.object(with: saveState.objectID)
                    context.delete(temporarySaveState)
                }
                context.saveWithErrorLogging()
            }
            catch
            {
                print(error)
            }
        }
    }
    
    private func update(_ saveState: SaveState, with replacementSaveState: SaveStateProtocol? = nil, shouldSuspendEmulation: Bool = true)
    {
        let isRunning = (self.emulatorCore?.state == .running)
        
        if isRunning && shouldSuspendEmulation
        {
            self.pauseEmulation()
        }
        
        if let replacementSaveState = replacementSaveState
        {
            do
            {
                if FileManager.default.fileExists(atPath: saveState.fileURL.path)
                {
                    // Don't use replaceItem(), since that removes the original file as well
                    try FileManager.default.removeItem(at: saveState.fileURL)
                }
                
                try FileManager.default.copyItem(at: replacementSaveState.fileURL, to: saveState.fileURL)
            }
            catch
            {
                print(error)
            }
        }
        else
        {
            self.emulatorCore?.saveSaveState(to: saveState.fileURL)
        }
        
        if let snapshot = self.emulatorCore?.videoManager.snapshot(), let data = snapshot.pngData()
        {
            do
            {
                try data.write(to: saveState.imageFileURL, options: [.atomicWrite])
            }
            catch
            {
                print(error)
            }
        }
        
        saveState.modifiedDate = Date()
        saveState.coreIdentifier = self.emulatorCore?.deltaCore.identifier
        
        if Settings.userInterfaceFeatures.toasts.stateSave
        {
            let text: String
            switch saveState.type
            {
            case .general, .locked: text = NSLocalizedString("Saved State " + saveState.localizedName, comment: "")
            case .quick: text = NSLocalizedString("Quick Saved", comment: "")
            default: text = NSLocalizedString("Saved State ", comment: "")
            }
            
            if saveState.type != .auto, saveState.type != .rewind
            {
                self.presentToastView(text: text)
            }
        }
        
        if isRunning && shouldSuspendEmulation
        {
            self.resumeEmulation()
        }
    }
    
    private func load(_ saveState: SaveStateProtocol)
    {
        let isRunning = (self.emulatorCore?.state == .running)
        
        if isRunning
        {
            self.pauseEmulation()
        }
        
        // If we're loading the auto save state, we need to create a temporary copy of saveState.
        // Then, we update the auto save state, but load our copy so everything works out.
        var temporarySaveState: SaveStateProtocol? = nil
        
        if let autoSaveState = saveState as? SaveState, autoSaveState.type == .auto
        {
            let temporaryURL = FileManager.default.uniqueTemporaryURL()
            
            do
            {
                try FileManager.default.moveItem(at: saveState.fileURL, to: temporaryURL)
                temporarySaveState = DeltaCore.SaveState(fileURL: temporaryURL, gameType: saveState.gameType)
            }
            catch
            {
                print(error)
            }
        }
        
        self.updateAutoSaveState(true)
        
        do
        {
            if let temporarySaveState = temporarySaveState
            {
                try self.emulatorCore?.load(temporarySaveState)
                try FileManager.default.removeItem(at: temporarySaveState.fileURL)
            }
            else
            {
                try self.emulatorCore?.load(saveState)
            }
            
            if Settings.userInterfaceFeatures.toasts.stateLoad,
               !self.overrideToastNotification
            {
                let text: String
                if let state = saveState as? SaveState
                {
                    switch state.type
                    {
                    case .quick: text = NSLocalizedString("Quick Loaded", comment: "")
                    case .rewind: text = NSLocalizedString("Rewound to " + state.localizedName, comment: "")
                    default: text = NSLocalizedString("Loaded State " + state.localizedName, comment: "")
                    }
                    self.presentToastView(text: text)
                }
                else
                {
                    text = NSLocalizedString("Loaded State", comment: "")
                    self.presentToastView(text: text)
                }
                self.overrideToastNotification = false
            }
        }
        catch EmulatorCore.SaveStateError.doesNotExist
        {
            print("Save State does not exist.")
        }
        catch let error as NSError
        {
            print(error)
        }
        
        // delay by 0.5 so as not to interfere with other operations
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let rewindSaveState = saveState as? SaveState, rewindSaveState.type == .rewind
            {
                self.clearRewindSaveStates(afterDate: rewindSaveState.creationDate)
            }
            else
            {
                self.clearRewindSaveStates()
            }
        }
        
        if isRunning
        {
            self.resumeEmulation()
        }
    }
    
    //MARK: - SaveStatesViewControllerDelegate
    
    func saveStatesViewController(_ saveStatesViewController: SaveStatesViewController, updateSaveState saveState: SaveState)
    {
        let updatingExistingSaveState = FileManager.default.fileExists(atPath: saveState.fileURL.path)
        
        self.update(saveState)
        
        // Dismiss if updating an existing save state.
        // If creating a new one, don't dismiss.
        if updatingExistingSaveState
        {
            self.pauseViewController?.dismiss()
        }
    }
    
    func saveStatesViewController(_ saveStatesViewController: SaveStatesViewController, loadSaveState saveState: SaveStateProtocol)
    {
        self._isLoadingSaveState = true
        
        self.load(saveState)
        
        self.pauseViewController?.dismiss()
    }
}

//MARK: - Cheats -
/// Cheats
extension GameViewController: CheatsViewControllerDelegate
{
    func cheatsViewController(_ cheatsViewController: CheatsViewController, activateCheat cheat: Cheat)
    {
        if Settings.gameplayFeatures.cheats.isEnabled {
            self.emulatorCore?.activateCheatWithErrorLogging(cheat)
        }
    }
    
    func cheatsViewController(_ cheatsViewController: CheatsViewController, deactivateCheat cheat: Cheat)
    {
        if Settings.gameplayFeatures.cheats.isEnabled {
            self.emulatorCore?.deactivate(cheat)
        }
    }
}

//MARK: - Core Settings -
/// Core Settings
private extension GameViewController
{
    func updateCoreSettings()
    {
        guard let emulatorCore = self.emulatorCore,
              let game = self.game as? Game else { return }
        
        if let emulatorBridge = emulatorCore.deltaCore.emulatorBridge as? SNESEmulatorBridge
        {
            let gameEnabled = Settings.snesFeatures.allowInvalidVRAMAccess.enabledGames.contains(where: { $0 == game.identifier })
            emulatorBridge.isInvalidVRAMAccessEnabled = Settings.snesFeatures.allowInvalidVRAMAccess.isEnabled && gameEnabled
        }
        else if let emulatorBridge = emulatorCore.deltaCore.emulatorBridge as? N64EmulatorBridge
        {
            emulatorBridge.overscanTop = game.overscanTop
            emulatorBridge.overscanBottom = game.overscanBottom
            emulatorBridge.overscanLeft = game.overscanLeft
            emulatorBridge.overscanRight = game.overscanRight
            
            self.overscanEditorView.topInsetLabel.text = "\(game.overscanTop)"
            self.overscanEditorView.bottomInsetLabel.text = "\(game.overscanBottom)"
            self.overscanEditorView.leftInsetLabel.text = "\(game.overscanLeft)"
            self.overscanEditorView.rightInsetLabel.text = "\(game.overscanRight)"
            
            emulatorBridge.updateOverscanConfig()
        }
    }
    
    func updateOverscanInset(for edge: OverscanInsetEdge, increase: Bool)
    {
        guard let game = self.game as? Game else { return }
        
        DatabaseManager.shared.performBackgroundTask { (context) in
            let game = context.object(with: game.objectID) as! Game
            
            switch edge
            {
            case .top:
                let oldInset = game.overscanTop
                let newInset = increase ? min(oldInset + 1, N64OverscanOptions.maxValue) : (oldInset == 0 ? 0 : oldInset - 1)
                game.overscanTop = newInset
                
                DispatchQueue.main.async{ self.overscanEditorView.topInsetLabel.text = "\(newInset)" }
                
            case .bottom:
                let oldInset = game.overscanBottom
                let newInset = increase ? min(oldInset + 1, N64OverscanOptions.maxValue) : (oldInset == 0 ? 0 : oldInset - 1)
                game.overscanBottom = newInset
                
                DispatchQueue.main.async{ self.overscanEditorView.bottomInsetLabel.text = "\(newInset)" }
                
            case .left:
                let oldInset = game.overscanLeft
                let newInset = increase ? min(oldInset + 1, N64OverscanOptions.maxValue) : (oldInset == 0 ? 0 : oldInset - 1)
                game.overscanLeft = newInset
                    
                DispatchQueue.main.async{ self.overscanEditorView.leftInsetLabel.text = "\(newInset)" }
                
            case .right:
                let oldInset = game.overscanRight
                let newInset = increase ? min(oldInset + 1, N64OverscanOptions.maxValue) : (oldInset == 0 ? 0 : oldInset - 1)
                game.overscanRight = newInset
                    
                DispatchQueue.main.async{ self.overscanEditorView.rightInsetLabel.text = "\(newInset)" }
            }
            
            context.saveWithErrorLogging()
        }
    }
    
    @objc func finishEditingOverscanInsets()
    {
        self.performOverscanEditorAction()
    }
    
    @objc func resetOverscanInsets()
    {
        guard let game = self.game as? Game else { return }
        
        DatabaseManager.shared.performBackgroundTask { (context) in
            let game = context.object(with: game.objectID) as! Game
            
            game.overscanTop = 0
            game.overscanBottom = 0
            game.overscanLeft = 0
            game.overscanRight = 0
            
            context.saveWithErrorLogging()
        }
        
        self.overscanEditorView.topInsetLabel.text = "0"
        self.overscanEditorView.bottomInsetLabel.text = "0"
        self.overscanEditorView.leftInsetLabel.text = "0"
        self.overscanEditorView.rightInsetLabel.text = "0"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.applyOverscanInsets()
        }
    }
    
    
    @objc func applyOverscanInsets()
    {
        guard let emulatorCore = self.emulatorCore,
              let game = self.game as? Game else { return }
        
        self.updateAutoSaveState()
        self.updateCoreSettings()
        
        emulatorCore.stop()
        emulatorCore.start()
        
        let fetchRequest = SaveState.rst_fetchRequest() as! NSFetchRequest<SaveState>
        fetchRequest.predicate = NSPredicate(format: "%K == %@ AND %K == %d", #keyPath(SaveState.game), game, #keyPath(SaveState.type), SaveStateType.auto.rawValue)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(SaveState.creationDate), ascending: true)]
        
        do
        {
            let saveStates = try game.managedObjectContext?.fetch(fetchRequest)
            if let activeSaveState = saveStates?.last
            {
                self.overrideToastNotification = true
                self.load(activeSaveState)
            }
        }
        catch
        {
            print(error)
        }
    }
    
    @objc func overscanTopInsetIncrease()
    {
        self.updateOverscanInset(for: .top, increase: true)
    }
    
    @objc func overscanTopInsetDecrease()
    {
        self.updateOverscanInset(for: .top, increase: false)
    }
    
    @objc func overscanBottomInsetIncrease()
    {
        self.updateOverscanInset(for: .bottom, increase: true)
    }
    
    @objc func overscanBottomInsetDecrease()
    {
        self.updateOverscanInset(for: .bottom, increase: false)
    }
    
    @objc func overscanLeftInsetIncrease()
    {
        self.updateOverscanInset(for: .left, increase: true)
    }
    
    @objc func overscanLeftInsetDecrease()
    {
        self.updateOverscanInset(for: .left, increase: false)
    }
    
    @objc func overscanRightInsetIncrease()
    {
        self.updateOverscanInset(for: .right, increase: true)
    }
    
    @objc func overscanRightInsetDecrease()
    {
        self.updateOverscanInset(for: .right, increase: false)
    }
}

//MARK: - Debug -
/// Debug
private extension GameViewController
{
    func updateDebug()
    {
        self.controllerView?.isDebugModeEnabled = Settings.advancedFeatures.skinDebug.isOn
    }
}

//MARK: - Graphics -
/// Graphics
private extension GameViewController
{
    func updateGraphics()
    {
        guard let game = self.game as? Game else { return }
        
        guard game.type == .n64 else { return }
        
        if Settings.n64Features.openGLES3.isEnabled,
           Settings.n64Features.openGLES3.enabledGames.contains(where: { $0 == game.identifier }) {
            self.emulatorCore?.videoManager.renderingAPI = .openGLES3
            Settings.currentOpenGLESVersion = 3
        }
        else
        {
            self.emulatorCore?.videoManager.renderingAPI = .openGLES2
            Settings.currentOpenGLESVersion = 2
        }
    }
}

//MARK: - Audio -
/// Audio
private extension GameViewController
{
    func updateAudio()
    {
        if self.emulatorCore?.audioManager.isMicEnabled != self.isMicEnabled {
            self.emulatorCore?.audioManager.isMicEnabled = self.isMicEnabled
            
            if let emulatorCore = self.emulatorCore,
               let emulatorBridge = emulatorCore.deltaCore.emulatorBridge as? MelonDSEmulatorBridge
            {
                emulatorBridge.prepareAudioEngine()
            }
        }
        
        if self.emulatorCore?.audioManager.respectsSilentMode != Settings.gameplayFeatures.gameAudio.respectSilent {
            self.emulatorCore?.audioManager.respectsSilentMode = Settings.gameplayFeatures.gameAudio.respectSilent
        }
        
        if self.emulatorCore?.audioManager.playWithOtherMedia != Settings.gameplayFeatures.gameAudio.playOver {
            self.emulatorCore?.audioManager.playWithOtherMedia = Settings.gameplayFeatures.gameAudio.playOver
        }
        
        let isFastForwarding = self.emulatorCore?.rate != self.emulatorCore?.deltaCore.supportedRates.lowerBound
        let mutedByFastForward = Settings.gameplayFeatures.gameAudio.fastForwardMutes && isFastForwarding
        
        if self.emulatorCore?.audioManager.mutedByFastForward != mutedByFastForward {
            self.emulatorCore?.audioManager.mutedByFastForward = mutedByFastForward
        }
        
        self.emulatorCore?.audioManager.audioVolume = Float(Settings.gameplayFeatures.gameAudio.volume)
    }
}

//MARK: - Sustain Buttons -
private extension GameViewController
{
    func showSustainButtonView()
    {
        guard let gameController = self.pausingGameController,
              let game = self.game as? Game else { return }
        
        self.isSelectingSustainedButtons = true
        
        Settings.gameplayFeatures.sustainButtons.heldInputs[game.identifier] = [:]
        
        let sustainInputsMapping = SustainInputsMapping(gameController: gameController)
        gameController.addReceiver(self, inputMapping: sustainInputsMapping)
        
        let blurEffect = self.sustainButtonsBlurView.effect
        self.sustainButtonsBlurView.effect = nil
        
        self.sustainButtonsContentView.isHidden = false
        
        UIView.animate(withDuration: 0.4) {
            self.sustainButtonsBlurView.effect = blurEffect
            self.sustainButtonsBackgroundView.alpha = 1.0
        } completion: { _ in
            self.controllerView.becomeFirstResponder()
        }
    }
    
    func hideSustainButtonView()
    {
        guard let gameController = self.pausingGameController,
              let game = self.game as? Game else { return }
        
        self.isSelectingSustainedButtons = false
        
        self.updateControllers()
        self.sustainInputsMapping = nil
        
        // Activate all sustained inputs, since they will now be mapped to game inputs.
        let inputsToSustain = self.getInputs(for: game)
        
        for (input, value) in inputsToSustain
        {
            gameController.sustain(input, value: value)
        }
        
        if gameController.sustainedInputs.count > 0
        {
            self.isSustainingInputs = true
        }
        else
        {
            self.isSustainingInputs = false
        }
        
        let blurEffect = self.sustainButtonsBlurView.effect
        
        UIView.animate(withDuration: 0.4, animations: {
            self.sustainButtonsBlurView.effect = nil
            self.sustainButtonsBackgroundView.alpha = 0.0
        }) { (finished) in
            self.sustainButtonsContentView.isHidden = true
            self.sustainButtonsBlurView.effect = blurEffect
        }
    }
}

//MARK: - Action Inputs -
/// Action Inputs
extension GameViewController
{
    func performRestartAction()
    {
        let alertController = UIAlertController(title: NSLocalizedString("Restart Game?", comment: ""), message: NSLocalizedString("An autosave will be made for you.", comment: ""), preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Restart", comment: ""), style: .destructive, handler: { (action) in
            self.updateAutoSaveState(true)
            self.game = self.game
            self.resumeEmulation()
            if Settings.userInterfaceFeatures.toasts.restart
            {
                self.presentToastView(text: NSLocalizedString("Game Restarted", comment: ""))
            }
        }))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
            self.resumeEmulation()
        }))
        
        if let pauseView = self.pauseViewController
        {
            pauseView.dismiss()
        }
        self.present(alertController, animated: true)
    }
    
    func performStatusBarAction(hold: Bool = false)
    {
        if let pauseView = self.pauseViewController,
           Settings.gameplayFeatures.pauseMenu.statusBarDismisses
        {
            pauseView.dismiss()
        }
        
        let text: String
        
        if hold
        {
            if Settings.userInterfaceFeatures.statusBar.style == .dark {
                Settings.userInterfaceFeatures.statusBar.style = .light
                text = NSLocalizedString("Status Bar: Light Content", comment: "")
            } else {
                Settings.userInterfaceFeatures.statusBar.style = .dark
                text = NSLocalizedString("Status Bar: Dark Content", comment: "")
            }
        }
        else
        {
            if Settings.userInterfaceFeatures.statusBar.isEnabled {
                Settings.userInterfaceFeatures.statusBar.isEnabled = false
                text = NSLocalizedString("Status Bar: Disabled", comment: "")
            } else {
                Settings.userInterfaceFeatures.statusBar.isEnabled = true
                text = NSLocalizedString("Status Bar: Enabled", comment: "")
            }
        }
        
        self.updateStatusBar()
        
        if Settings.userInterfaceFeatures.toasts.statusBar
        {
            self.presentToastView(text: text)
        }
    }
    
    func performMicrophoneAction()
    {
        if let pauseView = self.pauseViewController,
           Settings.gameplayFeatures.pauseMenu.microphoneDismisses
        {
            pauseView.dismiss()
        }
        
        let text: String
        
        if Settings.gameplayFeatures.micSupport.isEnabled {
            Settings.gameplayFeatures.micSupport.isEnabled = false
            text = NSLocalizedString("Microphone Disabled", comment: "")
        } else {
            Settings.gameplayFeatures.micSupport.isEnabled = true
            text = NSLocalizedString("Microphone Enabled", comment: "")
        }
        
        self.updateAudio()
        
        if Settings.userInterfaceFeatures.toasts.microphone
        {
            self.presentToastView(text: text)
        }
    }
    
    func performRotationLockAction()
    {
        if let pauseView = self.pauseViewController,
           Settings.gameplayFeatures.pauseMenu.rotationLockDismisses
        {
            pauseView.dismiss()
        }
        
        let text: String
        
        if self.isOrientationLocked
        {
            self.isOrientationLocked = false
            self.unlockOrientation()
            text = NSLocalizedString("Rotation Lock Disabled", comment: "")
        }
        else
        {
            self.isOrientationLocked = true
            self.lockOrientation()
            text = NSLocalizedString("Rotation Lock Enabled", comment: "")
        }
        
        if Settings.userInterfaceFeatures.toasts.rotationLock
        {
            self.presentToastView(text: text)
        }
        
        self.setNeedsUpdateOfSupportedInterfaceOrientations()
    }
    
    func lockOrientation()
    {
        guard self.lockedOrientation == nil else { return }
        
        switch UIDevice.current.orientation
        {
        case .portrait: self.lockedOrientation = .portrait
        case .landscapeLeft: self.lockedOrientation = .landscapeRight
        case .landscapeRight: self.lockedOrientation = .landscapeLeft
        case .portraitUpsideDown: self.lockedOrientation = .portraitUpsideDown
        default: self.lockedOrientation = .portrait
        }
    }
    
    func unlockOrientation()
    {
        guard !self.isOrientationLocked else { return }
        
        self.lockedOrientation = nil
    }
    
    func performScreenshotAction(hold: Bool = false)
    {
        if hold
        {
            if let pauseView = self.pauseViewController
            {
                pauseView.dismiss()
            }
            
            self.presentToastView(text: "3", duration: 1)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1)
            {
                self.presentToastView(text: "2", duration: 1)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2)
            {
                self.presentToastView(text: "1", duration: 1)
            }
        }
        else
        {
            if let pauseView = self.pauseViewController,
               Settings.gameplayFeatures.pauseMenu.screenshotDismisses
            {
                pauseView.dismiss()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + (hold ? 3 : 0))
        {
            guard let snapshot = self.emulatorCore?.videoManager.snapshot() else { return }

            let imageScale = Settings.gameplayFeatures.screenshots.size?.rawValue ?? 1.0
            let imageSize = CGSize(width: snapshot.size.width * imageScale, height: snapshot.size.height * imageScale)
            
            let screenshotData: Data
            if imageScale == 1, let data = snapshot.pngData()
            {
                screenshotData = data
            }
            else
            {
                let format = UIGraphicsImageRendererFormat()
                format.scale = 1
                
                let renderer = UIGraphicsImageRenderer(size: imageSize, format: format)
                screenshotData = renderer.pngData { (context) in
                    context.cgContext.interpolationQuality = .none
                    snapshot.draw(in: CGRect(origin: .zero, size: imageSize))
                }
            }
            
            let saveLocation = Settings.gameplayFeatures.screenshots.saveLocation
            
            if saveLocation == .photos || saveLocation == .both
            {
                PHPhotoLibrary.runIfAuthorized
                {
                    PHPhotoLibrary.saveImageData(screenshotData)
                }
            }
            
            if saveLocation == .files || saveLocation == .both
            {
                let screenshotsDirectory = FileManager.default.documentsDirectory.appendingPathComponent("Screenshots")
                
                do
                {
                    try FileManager.default.createDirectory(at: screenshotsDirectory, withIntermediateDirectories: true, attributes: nil)
                }
                catch
                {
                    print(error)
                }
                
                let date = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
                
                let fileName: URL
                if let game = self.game as? Game
                {
                    let filename = game.name + "_" + dateFormatter.string(from: date) + ".png"
                    fileName = screenshotsDirectory.appendingPathComponent(filename)
                }
                else
                {
                    fileName = screenshotsDirectory.appendingPathComponent(dateFormatter.string(from: date) + ".png")
                }
                
                do
                {
                    try screenshotData.write(to: fileName)
                }
                catch
                {
                    print(error)
                }
            }
            
            if Settings.userInterfaceFeatures.toasts.screenshot
            {
                self.presentToastView(text: NSLocalizedString("Screenshot Captured", comment: ""))
            }
        }
    }
    
    func performQuickSaveAction()
    {
        guard let game = self.game as? Game else { return }
        
        self.dismissQuickSettings()
        
        if let pauseView = self.pauseViewController { pauseView.dismiss() }
        
        let backgroundContext = DatabaseManager.shared.newBackgroundContext()
        backgroundContext.performAndWait {
            
            let game = backgroundContext.object(with: game.objectID) as! Game
            let fetchRequest = SaveState.fetchRequest(for: game, type: .quick)
            
            do
            {
                if let quickSaveState = try fetchRequest.execute().first
                {
                    self.update(quickSaveState)
                }
                else
                {
                    let saveState = SaveState(context: backgroundContext)
                    saveState.type = .quick
                    saveState.game = game
                    
                    self.update(saveState)
                }
            }
            catch
            {
                print(error)
            }
            
            backgroundContext.saveWithErrorLogging()
        }
        
        
    }
    
    func performQuickLoadAction()
    {
        guard let game = self.game as? Game else { return }
        
        self.dismissQuickSettings()
        
        let fetchRequest = SaveState.fetchRequest(for: game, type: .quick)
        
        do
        {
            if let quickSaveState = try DatabaseManager.shared.viewContext.fetch(fetchRequest).first
            {
                self.load(quickSaveState)
            }
        }
        catch
        {
            print(error)
        }
        
        if let pauseView = self.pauseViewController { pauseView.dismiss() }
    }
    
    func performFastForwardAction(activate: Bool)
    {
        if let pauseView = self.pauseViewController,
           Settings.gameplayFeatures.pauseMenu.fastForwardDismisses
        {
            pauseView.dismiss()
        }
        
        guard let emulatorCore = self.emulatorCore else { return }
        let text: String
        
        if activate
        {
            emulatorCore.rate = Settings.gameplayFeatures.fastForward.speed
            text = NSLocalizedString("Fast Forward: " + String(format: "%.f", emulatorCore.rate * 100) + "%", comment: "")
        }
        else
        {
            emulatorCore.rate = emulatorCore.deltaCore.supportedRates.lowerBound
            text = NSLocalizedString("Fast Forward: Disabled", comment: "")
        }
        
        if Settings.userInterfaceFeatures.toasts.fastForward,
           Settings.gameplayFeatures.fastForward.mode == .toggle
        {
            self.presentToastView(text: text)
        }
        
        self.updateAudio()
    }
    
    func updateFastForwardSpeed(speed: Double)
    {
        guard let emulatorCore = self.emulatorCore else { return }
        
        Settings.gameplayFeatures.fastForward.speed = speed
        
        if emulatorCore.rate != emulatorCore.deltaCore.supportedRates.lowerBound
        {
            emulatorCore.rate = speed
        }
        
        self.updateAudio()
    }
    
    func performQuickSettingsAction()
    {
        if self.isSelectingSustainedButtons
        {
            if self.presentedViewController == nil
            {
                self.pauseEmulation()
                self.controllerView.resignFirstResponder()
                self._isQuickSettingsOpen = false
                
                self.performSegue(withIdentifier: "pause", sender: self.controllerView)
            }
            
            self.hideSustainButtonView()
        }
        else
        {
            if self._isQuickSettingsOpen
            {
                self._isQuickSettingsOpen = false
                
                self.dismissQuickSettings()
            }
            else
            {
                if let pauseView = self.pauseViewController
                {
                    pauseView.dismiss()
                }
                
                let quickSettingsView = QuickSettingsView.makeViewController(gameViewController: self)
                
                if let sheet = quickSettingsView.sheetPresentationController {
                    sheet.detents = [.medium(), .large()]
                    sheet.largestUndimmedDetentIdentifier = nil
                    sheet.prefersScrollingExpandsWhenScrolledToEdge = true
                    sheet.prefersEdgeAttachedInCompactHeight = true
                    sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = false
                    sheet.prefersGrabberVisible = true
                }
                
                self.present(quickSettingsView, animated: true, completion: nil)
                
                self._isQuickSettingsOpen = true
                
                self.resumeEmulation()
            }
        }
    }
    
    func dismissQuickSettings()
    {
        if let presentedViewController = self.sheetPresentationController
        {
            presentedViewController.presentedViewController.dismiss(animated: true)
        }
    }
    
    func performPauseAction()
    {
        self.dismissQuickSettings()
        self.pauseEmulation()
        self.controllerView.resignFirstResponder()
        self._isQuickSettingsOpen = false
        
        self.performSegue(withIdentifier: "pause", sender: self.controllerView)
    }
    
    func performMainMenuAction()
    {
        self.dismissQuickSettings()
        self.updateAutoSaveState()
        self.pauseEmulation()
        self.controllerView.resignFirstResponder()
        self._isQuickSettingsOpen = false
        
        DispatchQueue.main.async {
            self.transitionCoordinator?.animate(alongsideTransition: nil, completion: { (context) in
                self.performSegue(withIdentifier: "showGamesViewController", sender: nil)
            })
        }
    }
    
    func performBackgroundBlurAction()
    {
        if let pauseView = self.pauseViewController,
           Settings.gameplayFeatures.pauseMenu.backgroundBlurDismisses
        {
            pauseView.dismiss()
        }
        
        let enabled = !Settings.controllerFeatures.backgroundBlur.isEnabled
        self.blurScreenEnabled = enabled
        Settings.controllerFeatures.backgroundBlur.isEnabled = enabled
        
        if Settings.userInterfaceFeatures.toasts.backgroundBlur
        {
            let text: String
            if enabled
            {
                text = NSLocalizedString("Background Blur Enabled", comment: "")
            }
            else
            {
                text = NSLocalizedString("Background Blur Disabled", comment: "")
            }
            self.presentToastView(text: text)
        }
    }
    
    func performOverscanEditorAction()
    {
        if let pauseView = self.pauseViewController
        {
            pauseView.dismiss()
        }
        
        let enabled = !self.isEditingOverscanInsets
        
        UIView.animate(withDuration: 0.2) {
            self.overscanEditorView.isHidden = !enabled
            self.isEditingOverscanInsets = enabled
            
            self.updateControllers()
        }
        
        if Settings.userInterfaceFeatures.toasts.overscan
        {
            let text: String
            if enabled
            {
                text = NSLocalizedString("Overscan Editor Enabled", comment: "")
            }
            else
            {
                text = NSLocalizedString("Overscan Editor Disabled", comment: "")
            }
            self.presentToastView(text: text)
        }
    }
    
    func performAltRepresentationsAction()
    {
        if let pauseView = self.pauseViewController,
           Settings.gameplayFeatures.pauseMenu.alternateSkinDismisses
        {
            pauseView.dismiss()
        }
        
        let enabled = !Settings.advancedFeatures.skinDebug.useAlt
        self.controllerView.isAltRepresentationsEnabled = enabled
        Settings.advancedFeatures.skinDebug.useAlt = enabled
        
        if Settings.userInterfaceFeatures.toasts.altSkin
        {
            let text: String
            if enabled
            {
                text = NSLocalizedString("Alternate Skin Enabled", comment: "")
            }
            else
            {
                text = NSLocalizedString("Alternate Skin Disabled", comment: "")
            }
            self.presentToastView(text: text)
        }
    }
    
    func performDebugModeAction()
    {
        if let pauseView = self.pauseViewController,
           Settings.gameplayFeatures.pauseMenu.debugModeDismisses
        {
            pauseView.dismiss()
        }
        
        let enabled = !Settings.advancedFeatures.skinDebug.isOn
        Settings.advancedFeatures.skinDebug.isOn = enabled
        self.controllerView.isDebugModeEnabled = enabled
        
        if Settings.userInterfaceFeatures.toasts.debug
        {
            let text: String
            if enabled
            {
                text = NSLocalizedString("Debug Mode Enabled", comment: "")
            }
            else
            {
                text = NSLocalizedString("Debug Mode Disabled", comment: "")
            }
            self.presentToastView(text: text)
        }
    }
    
    func performDebugDeviceAction()
    {
        if let pauseView = self.pauseViewController
        {
            pauseView.dismiss()
        }
        
        let alertController = UIAlertController(title: NSLocalizedString("Choose Device Override", comment: ""), message: NSLocalizedString("This allows you to test your skins on devices that you don't have access to.", comment: ""), preferredStyle: .actionSheet)
        alertController.preparePopoverPresentationController(self.view)
        
        alertController.addAction(UIAlertAction(title: "iPhone", style: .default, handler: { (action) in
            Settings.advancedFeatures.skinDebug.device = .iphone
            self.resumeEmulation()
            if Settings.userInterfaceFeatures.toasts.debug
            {
                self.presentToastView(text: NSLocalizedString("Device Override set to iPhone", comment: ""))
            }
        }))
        alertController.addAction(UIAlertAction(title: "iPad", style: .default, handler: { (action) in
            Settings.advancedFeatures.skinDebug.device = .ipad
            self.resumeEmulation()
            if Settings.userInterfaceFeatures.toasts.debug
            {
                self.presentToastView(text: NSLocalizedString("Device Override set to iPad", comment: ""))
            }
        }))
        alertController.addAction(UIAlertAction(title: "AirPlay TV", style: .default, handler: { (action) in
            Settings.advancedFeatures.skinDebug.device = .tv
            self.resumeEmulation()
            if Settings.userInterfaceFeatures.toasts.debug
            {
                self.presentToastView(text: NSLocalizedString("Device Override set to AirPlay TV", comment: ""))
            }
        }))
        alertController.addAction(UIAlertAction(title: "Reset Device", style: .default, handler: { (action) in
            Settings.advancedFeatures.skinDebug.device = Settings.advancedFeatures.skinDebug.defaultDevice
            self.resumeEmulation()
            if Settings.userInterfaceFeatures.toasts.debug
            {
                self.presentToastView(text: NSLocalizedString("Device Override has been reset", comment: ""))
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            self.resumeEmulation()
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func performDebugDisplayTypeAction()
    {
        if let pauseView = self.pauseViewController
        {
            pauseView.dismiss()
        }
        
        let alertController = UIAlertController(title: NSLocalizedString("Choose Display Type Override", comment: ""), message: NSLocalizedString("This allows you to test your skins on display types that you don't have access to.", comment: ""), preferredStyle: .actionSheet)
        alertController.preparePopoverPresentationController(self.view)
        
        alertController.addAction(UIAlertAction(title: "Standard", style: .default, handler: { (action) in
            Settings.advancedFeatures.skinDebug.displayType = .standard
            self.resumeEmulation()
            if Settings.userInterfaceFeatures.toasts.debug
            {
                self.presentToastView(text: NSLocalizedString("Display Type Override set to Standard", comment: ""))
            }
        }))
        alertController.addAction(UIAlertAction(title: "EdgeToEdge", style: .default, handler: { (action) in
            Settings.advancedFeatures.skinDebug.displayType = .edgeToEdge
            self.resumeEmulation()
            if Settings.userInterfaceFeatures.toasts.debug
            {
                self.presentToastView(text: NSLocalizedString("Display Type Override set to EdgeToEdge", comment: ""))
            }
        }))
        alertController.addAction(UIAlertAction(title: "SplitView", style: .default, handler: { (action) in
            Settings.advancedFeatures.skinDebug.displayType = .splitView
            self.resumeEmulation()
            if Settings.userInterfaceFeatures.toasts.debug
            {
                self.presentToastView(text: NSLocalizedString("Display Type Override set to SplitView", comment: ""))
            }
        }))
        alertController.addAction(UIAlertAction(title: "Reset Device", style: .default, handler: { (action) in
            Settings.advancedFeatures.skinDebug.displayType = Settings.advancedFeatures.skinDebug.defaultDisplayType
            self.resumeEmulation()
            if Settings.userInterfaceFeatures.toasts.debug
            {
                self.presentToastView(text: NSLocalizedString("Display Type Override has been reset", comment: ""))
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            self.resumeEmulation()
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func performPresetTraitsAction()
    {
        if let pauseView = self.pauseViewController
        {
            pauseView.dismiss()
        }
        
        let alertController = UIAlertController(title: NSLocalizedString("Choose Preset Traits", comment: ""), message: NSLocalizedString("Set your override traits based on existing device and display type combinations.", comment: ""), preferredStyle: .actionSheet)
        alertController.preparePopoverPresentationController(self.view)
        
        alertController.addAction(UIAlertAction(title: "Standard iPhone", style: .default, handler: { (action) in
            Settings.advancedFeatures.skinDebug.device = .iphone
            Settings.advancedFeatures.skinDebug.displayType = .standard
            self.resumeEmulation()
            if Settings.userInterfaceFeatures.toasts.debug
            {
                self.presentToastView(text: NSLocalizedString("Override Traits set to Standard iPhone", comment: ""))
            }
        }))
        alertController.addAction(UIAlertAction(title: "EdgeToEdge iPhone", style: .default, handler: { (action) in
            Settings.advancedFeatures.skinDebug.device = .iphone
            Settings.advancedFeatures.skinDebug.displayType = .edgeToEdge
            self.resumeEmulation()
            if Settings.userInterfaceFeatures.toasts.debug
            {
                self.presentToastView(text: NSLocalizedString("Override Traits set to EdgeToEdge iPhone", comment: ""))
            }
        }))
        alertController.addAction(UIAlertAction(title: "Standard iPad", style: .default, handler: { (action) in
            Settings.advancedFeatures.skinDebug.device = .ipad
            Settings.advancedFeatures.skinDebug.displayType = .standard
            self.resumeEmulation()
            if Settings.userInterfaceFeatures.toasts.debug
            {
                self.presentToastView(text: NSLocalizedString("Override Traits set to Standard iPad", comment: ""))
            }
        }))
        alertController.addAction(UIAlertAction(title: "SplitView iPad", style: .default, handler: { (action) in
            Settings.advancedFeatures.skinDebug.device = .ipad
            Settings.advancedFeatures.skinDebug.displayType = .splitView
            self.resumeEmulation()
            if Settings.userInterfaceFeatures.toasts.debug
            {
                self.presentToastView(text: NSLocalizedString("Override Traits set to SplitView iPad", comment: ""))
            }
        }))
        alertController.addAction(UIAlertAction(title: "AirPlay TV", style: .default, handler: { (action) in
            Settings.advancedFeatures.skinDebug.device = .tv
            Settings.advancedFeatures.skinDebug.displayType = .standard
            self.resumeEmulation()
            if Settings.userInterfaceFeatures.toasts.debug
            {
                self.presentToastView(text: NSLocalizedString("Override Traits set to AirPlay TV", comment: ""))
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            self.resumeEmulation()
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func performPaletteAction()
    {
        if let pauseView = self.pauseViewController
        {
            pauseView.dismiss()
        }
        
        if Settings.gbFeatures.palettes.multiPalette
        {
            let alertController = UIAlertController(title: NSLocalizedString("Change Which Palette?", comment: ""), message: nil, preferredStyle: .actionSheet)
            alertController.preparePopoverPresentationController(self.view)
            
            alertController.addAction(UIAlertAction(title: "Main Palette", style: .default, handler: { (action) in
                let paletteAlertController = UIAlertController(title: NSLocalizedString("Choose Main Palette", comment: ""), message: nil, preferredStyle: .actionSheet)
                paletteAlertController.preparePopoverPresentationController(self.view)
                
                for palette in GameboyPalette.allCases
                {
                    let text = (Settings.gbFeatures.palettes.palette.rawValue == palette.rawValue) ? ("✓ " + palette.description) : palette.description
                    paletteAlertController.addAction(UIAlertAction(title: text, style: .default, handler: { (action) in
                        Settings.gbFeatures.palettes.palette = palette
                        self.resumeEmulation()
                        if Settings.userInterfaceFeatures.toasts.palette
                        {
                            self.presentToastView(text: NSLocalizedString("Changed Main Palette to \(palette.description)", comment: ""))
                        }
                    }))
                }
                
                paletteAlertController.addAction(.cancel)
                self.present(paletteAlertController, animated: true, completion: nil)
            }))
            alertController.addAction(UIAlertAction(title: "Sprite Palette 1", style: .default, handler: { (action) in
                let paletteAlertController = UIAlertController(title: NSLocalizedString("Choose Sprite Palette 1", comment: ""), message: nil, preferredStyle: .actionSheet)
                paletteAlertController.preparePopoverPresentationController(self.view)
                
                for palette in GameboyPalette.allCases
                {
                    let text = (Settings.gbFeatures.palettes.spritePalette1.rawValue == palette.rawValue) ? ("✓ " + palette.description) : palette.description
                    paletteAlertController.addAction(UIAlertAction(title: text, style: .default, handler: { (action) in
                        Settings.gbFeatures.palettes.spritePalette1 = palette
                        self.resumeEmulation()
                        if Settings.userInterfaceFeatures.toasts.palette
                        {
                            self.presentToastView(text: NSLocalizedString("Changed Sprite Palette 1 to \(palette.description)", comment: ""))
                        }
                    }))
                }
                
                paletteAlertController.addAction(.cancel)
                self.present(paletteAlertController, animated: true, completion: nil)
            }))
            alertController.addAction(UIAlertAction(title: "Sprite Palette 2", style: .default, handler: { (action) in
                let paletteAlertController = UIAlertController(title: NSLocalizedString("Choose Sprite Palette 2", comment: ""), message: nil, preferredStyle: .actionSheet)
                paletteAlertController.preparePopoverPresentationController(self.view)
                
                for palette in GameboyPalette.allCases
                {
                    let text = (Settings.gbFeatures.palettes.spritePalette2.rawValue == palette.rawValue) ? ("✓ " + palette.description) : palette.description
                    paletteAlertController.addAction(UIAlertAction(title: text, style: .default, handler: { (action) in
                        Settings.gbFeatures.palettes.spritePalette2 = palette
                        self.resumeEmulation()
                        if Settings.userInterfaceFeatures.toasts.palette
                        {
                            self.presentToastView(text: NSLocalizedString("Changed Sprite Palette 2 to \(palette.description)", comment: ""))
                        }
                    }))
                }
                
                paletteAlertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                    self.resumeEmulation()
                }))
                self.present(paletteAlertController, animated: true, completion: nil)
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                self.resumeEmulation()
            }))
            self.present(alertController, animated: true, completion: nil)
        }
        else
        {
            let alertController = UIAlertController(title: NSLocalizedString("Choose Color Palette", comment: ""), message: nil, preferredStyle: .actionSheet)
            alertController.preparePopoverPresentationController(self.view)
            
            for palette in GameboyPalette.allCases.filter { !$0.pro || Settings.proFeaturesEnabled }
            {
                let text = (Settings.gbFeatures.palettes.palette.rawValue == palette.rawValue) ? ("✓ " + palette.description) : palette.description
                alertController.addAction(UIAlertAction(title: text, style: .default, handler: { (action) in
                    Settings.gbFeatures.palettes.palette = palette
                    self.resumeEmulation()
                    if Settings.userInterfaceFeatures.toasts.palette
                    {
                        self.presentToastView(text: NSLocalizedString("Changed Palette to \(palette.description)", comment: ""))
                    }
                }))
            }
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                self.resumeEmulation()
            }))
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

//MARK: - Toast Notifications -
/// Toast Notifications
extension GameViewController
{
    func presentToastView(text: String, duration: Double? = nil)
    {
        guard Settings.userInterfaceFeatures.toasts.isEnabled else { return }
        
        DispatchQueue.main.async {
            ToastView.show(text, in: self.view, onEdge: .top, duration: duration ?? Settings.userInterfaceFeatures.toasts.duration)
        }
    }
}

private extension GameViewController
{
    func connectExternalDisplay(for scene: ExternalDisplayScene)
    {
        // We need to receive gameViewController(_:didUpdateGameViews) callback.
        scene.gameViewController.delegate = self
        
        self.updateControllerSkin()
        self.updateBackgroundBlur()

        // Implicitly called from updateControllerSkin()
        // self.updateExternalDisplay()
        
        if let gameView = self.gameView
        {
            gameView.isAirPlaying = !gameView.isTouchScreen && Settings.airplayFeatures.device.disableScreen
        }
    }

    func updateExternalDisplay()
    {
        guard let scene = UIApplication.shared.externalDisplayScene else { return }

        if scene.game?.fileURL != self.game?.fileURL
        {
            scene.game = self.game
        }

        var controllerSkin: ControllerSkinProtocol?

        if let game = self.game, let traits = scene.gameViewController.controllerView.controllerSkinTraits
        {
            if let preferredControllerSkin = Settings.airplayFeatures.skins.preferredAirPlayControllerSkin(for: game.type),
               preferredControllerSkin.supports(traits, alt: Settings.advancedFeatures.skinDebug.useAlt)
            {
                // Use preferredControllerSkin directly.
                controllerSkin = preferredControllerSkin
            }
            else if let standardSkin = StandardControllerSkin(for: game.type),
                    standardSkin.supports(traits, alt: false)
            {
                if standardSkin.hasTouchScreen(for: traits)
                {
                    // Only use TouchControllerSkin for standard controller skins with touch screens.
                             
                    var touchControllerSkin = DeltaCore.TouchControllerSkin(controllerSkin: standardSkin)
                    touchControllerSkin.screenLayoutAxis = Settings.airplayFeatures.display.layoutAxis

                    if Settings.airplayFeatures.display.topScreenOnly
                    {
                        touchControllerSkin.screenPredicate = { !$0.isTouchScreen }
                    }

                    controllerSkin = touchControllerSkin
                }
                else
                {
                    controllerSkin = standardSkin
                }
            }
        }

        scene.gameViewController.controllerView.controllerSkin = controllerSkin

        // Implicitly called when assigning controllerSkin.
        // self.updateExternalDisplayGameViews()
        
        self.gameView?.updateAirPlayView()
        
        if let gameView = self.gameView
        {
            gameView.isAirPlaying = !gameView.isTouchScreen && Settings.airplayFeatures.device.disableScreen
        }
    }

    func updateExternalDisplayGameViews()
    {
        guard let scene = UIApplication.shared.externalDisplayScene, let emulatorCore = self.emulatorCore else { return }

        for gameView in scene.gameViewController.gameViews
        {
            emulatorCore.add(gameView)
        }
        
        emulatorCore.add(scene.gameViewController.blurGameView)
    }

    func disconnectExternalDisplay(for scene: ExternalDisplayScene)
    {
        scene.gameViewController.delegate = nil
        
        for gameView in scene.gameViewController.gameViews
        {
            self.emulatorCore?.remove(gameView)
        }
        
        self.emulatorCore?.remove(scene.gameViewController.blurGameView)

        self.updateControllerSkin() // Reset TouchControllerSkin + GameViews
        
        self.gameView?.isAirPlaying = false
    }
}

//MARK: - GameViewControllerDelegate -
/// GameViewControllerDelegate
extension GameViewController: GameViewControllerDelegate
{
    func gameViewController(_ gameViewController: DeltaCore.GameViewController, handleMenuInputFrom gameController: GameController)
    {
        guard gameViewController == self else { return }
        
        if let pausingGameController = self.pausingGameController
        {
            guard pausingGameController == gameController else { return }
        }
        
        if let pauseViewController = self.pauseViewController, !self.isSelectingSustainedButtons
        {
            pauseViewController.dismiss()
        }
        else if self.presentedViewController == nil
        {
            self.pauseEmulation()
            self.controllerView.resignFirstResponder()
            self._isQuickSettingsOpen = false
            
            self.performSegue(withIdentifier: "pause", sender: gameController)
        }
        
        if self.isSelectingSustainedButtons
        {
            self.hideSustainButtonView()
        }
    }
    
    func gameViewControllerShouldResumeEmulation(_ gameViewController: DeltaCore.GameViewController) -> Bool
    {
        guard gameViewController == self else { return false }
        
        var result = false
        
        rst_dispatch_sync_on_main_thread {
            result = (self.presentedViewController == nil || self.presentedViewController?.isDisappearing == true) && !self.isSelectingSustainedButtons && self.view.window != nil
        }
        
        return result
    }
    
    func gameViewController(_ gameViewController: DeltaCore.GameViewController, didUpdateGameViews gameViews: [GameView])
    {
        // gameViewController could be `self` or ExternalDisplayScene.gameViewController.
             
        if gameViewController == self
        {
            self.updateGameViews()
        }
        else
        {
            self.updateExternalDisplayGameViews()
        }
    }
}

private extension GameViewController
{
    func showJITEnabledAlert()
    {
        guard !self.presentedJITAlert, self.presentedViewController == nil, self.game != nil else { return }
        self.presentedJITAlert = true
        
        func presentToastView()
        {
            let detailText: String?
            let duration: TimeInterval
            
            if UserDefaults.standard.jitEnabledAlertCount < 3
            {
                detailText = NSLocalizedString("You can now Fast Forward DS games up to 3x speed.", comment: "")
                duration = 5.0
            }
            else
            {
                detailText = nil
                duration = 2.0
            }
            
            ToastView.show(NSLocalizedString("JIT Compilation Enabled", comment: ""), in: self.view, detailText: detailText, duration: duration)
            
            UserDefaults.standard.jitEnabledAlertCount += 1
        }
        
        DispatchQueue.main.async {
            if let transitionCoordinator = self.transitionCoordinator
            {
                transitionCoordinator.animate(alongsideTransition: nil) { (context) in
                    presentToastView()
                }
            }
            else
            {
                presentToastView()
            }
        }
    }
}

//MARK: - Notifications -
private extension GameViewController
{
    @objc func didEnterBackground(with notification: Notification)
    {
        self.updateAutoSaveState(true, shouldSuspendEmulation: false)
    }
    
    @objc func appWillBecomeInactive(with notification: Notification)
    {
        if let presentedViewController = self.sheetPresentationController,
           self._isQuickSettingsOpen
        {
            presentedViewController.presentedViewController.dismiss(animated: true)
        }
    }
    
    @objc func managedObjectContextDidChange(with notification: Notification)
    {
        guard let deletedObjects = notification.userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject> else { return }
        guard let game = self.game as? Game else { return }
        
        if deletedObjects.contains(game)
        {
            self.emulatorCore?.gameViews.forEach { $0.inputImage = nil }
            self.game = nil
        }
    }
    
    @objc func settingsDidChange(with notification: Notification)
    {
        guard let settingsName = notification.userInfo?[Settings.NotificationUserInfoKey.name] as? Settings.Name else { return }
        
        switch settingsName
        {
        case .localControllerPlayerIndex, Settings.touchFeedbackFeatures.touchVibration.$buttonsEnabled.settingsKey, Settings.touchFeedbackFeatures.touchVibration.$sticksEnabled.settingsKey, Settings.advancedFeatures.skinDebug.$useAlt.settingsKey, Settings.controllerFeatures.controller.$hideSkin.settingsKey, Settings.advancedFeatures.skinDebug.$isOn.settingsKey, Settings.advancedFeatures.skinDebug.$device.settingsKey, Settings.advancedFeatures.skinDebug.$displayType.settingsKey, Settings.advancedFeatures.skinDebug.$traitOverride.settingsKey, Settings.touchFeedbackFeatures.touchVibration.$releaseEnabled.settingsKey, Settings.touchFeedbackFeatures.touchOverlay.settingsKey:
            self.updateControllers()

        case .preferredControllerSkin:
            guard
                let system = notification.userInfo?[Settings.NotificationUserInfoKey.system] as? System,
                let traits = notification.userInfo?[Settings.NotificationUserInfoKey.traits] as? DeltaCore.ControllerSkin.Traits
            else { return }
                        
            if system.gameType == self.game?.type && traits.orientation == self.controllerView.controllerSkinTraits?.orientation
            {
                self.updateControllerSkin()
            }
            
        case Settings.userInterfaceFeatures.theme.$color.settingsKey, Settings.userInterfaceFeatures.theme.$style.settingsKey:
            self.controllerView.invalidateImageCache()
            self.updateControllerSkin()
            
        case Settings.controllerFeatures.controller.$triggerDeadzone.settingsKey:
            self.updateControllerTriggerDeadzone()
            
        case Settings.controllerFeatures.skin.settingsKey, Settings.controllerFeatures.skin.$opacity.settingsKey, Settings.controllerFeatures.skin.$backgroundColor.settingsKey, Settings.controllerFeatures.skin.$colorMode.settingsKey, Settings.controllerFeatures.skin.$diagonalDpad.settingsKey:
            self.updateControllerSkinCustomization()
            
        case Settings.touchFeedbackFeatures.touchVibration.$strength.settingsKey:
            self.controllerView.hapticFeedbackStrength = Settings.touchFeedbackFeatures.touchVibration.strength
            
        case Settings.touchFeedbackFeatures.touchOverlay.$color.settingsKey, Settings.touchFeedbackFeatures.touchOverlay.$customColor.settingsKey:
            self.controllerView.touchOverlayColor = Settings.touchFeedbackFeatures.touchOverlay.color.uiColor
            
        case Settings.touchFeedbackFeatures.touchOverlay.$opacity.settingsKey:
            self.controllerView.touchOverlayOpacity = Settings.touchFeedbackFeatures.touchOverlay.opacity
            
        case Settings.touchFeedbackFeatures.touchOverlay.$size.settingsKey:
            self.controllerView.touchOverlaySize = Settings.touchFeedbackFeatures.touchOverlay.size
            
        case Settings.touchFeedbackFeatures.touchOverlay.$style.settingsKey:
            self.controllerView.touchOverlayStyle = Settings.touchFeedbackFeatures.touchOverlay.style
            
        case Settings.snesFeatures.allowInvalidVRAMAccess.settingsKey:
            self.updateCoreSettings()
            
        case Settings.gameplayFeatures.gameAudio.$respectSilent.settingsKey, Settings.gameplayFeatures.gameAudio.$playOver.settingsKey, Settings.gameplayFeatures.gameAudio.$volume.settingsKey, Settings.gameplayFeatures.gameAudio.$fastForwardMutes.settingsKey:
            self.updateAudio()
            
        case Settings.touchFeedbackFeatures.touchAudio.$sound.settingsKey:
            self.updateButtonAudioFeedbackSound()
            self.playButtonAudioFeedbackSound()
            
        case Settings.touchFeedbackFeatures.touchAudio.settingsKey, Settings.touchFeedbackFeatures.touchAudio.$useGameVolume.settingsKey, Settings.touchFeedbackFeatures.touchAudio.$buttonVolume.settingsKey:
            self.updateButtonAudioFeedbackSound()
            
        case Settings.userInterfaceFeatures.statusBar.settingsKey:
            self.updateStatusBar()
            
        case Settings.gbFeatures.palettes.$palette.settingsKey, Settings.gbFeatures.palettes.settingsKey, Settings.gbFeatures.palettes.$spritePalette1.settingsKey, Settings.gbFeatures.palettes.$spritePalette2.settingsKey, Settings.gbFeatures.palettes.$multiPalette.settingsKey, Settings.gbFeatures.palettes.$customPalette1Color1.settingsKey, Settings.gbFeatures.palettes.$customPalette1Color2.settingsKey, Settings.gbFeatures.palettes.$customPalette1Color3.settingsKey, Settings.gbFeatures.palettes.$customPalette1Color4.settingsKey, Settings.gbFeatures.palettes.$customPalette2Color1.settingsKey, Settings.gbFeatures.palettes.$customPalette2Color2.settingsKey, Settings.gbFeatures.palettes.$customPalette2Color3.settingsKey, Settings.gbFeatures.palettes.$customPalette2Color4.settingsKey, Settings.gbFeatures.palettes.$customPalette3Color1.settingsKey, Settings.gbFeatures.palettes.$customPalette3Color2.settingsKey, Settings.gbFeatures.palettes.$customPalette3Color3.settingsKey, Settings.gbFeatures.palettes.$customPalette3Color4.settingsKey:
            self.updateGameboyPalette()
            
        case Settings.airplayFeatures.display.$topScreenOnly.settingsKey, Settings.airplayFeatures.display.$layoutAxis.settingsKey:
            self.updateExternalDisplay()
            
        case Settings.airplayFeatures.display.$backgroundBlur.settingsKey:
            self.updateBackgroundBlur()
            
        case _ where settingsName.rawValue.hasPrefix(Settings.airplayFeatures.device.settingsKey.rawValue):
            // Update whenever any of the AirPlay device settings have changed.
            self.updateControllerSkin()
            
        case _ where settingsName.rawValue.hasPrefix(Settings.airplayFeatures.skins.settingsKey.rawValue):
            // Update whenever any of the AirPlay skins have changed.
            self.updateExternalDisplay()
            
        case _ where settingsName.rawValue.hasPrefix(Settings.controllerFeatures.backgroundBlur.settingsKey.rawValue):
            // Update whenever any of the background blur settings have changed.
            self.updateBackgroundBlur()
            
        case _ where settingsName.rawValue.hasPrefix(Settings.standardSkinFeatures.styleAndColor.settingsKey.rawValue):
            // Update whenever any of the standard skin settings have changed.
            self.controllerView.invalidateImageCache()
            
        case _ where settingsName.rawValue.hasPrefix(Settings.standardSkinFeatures.gameScreen.settingsKey.rawValue):
            // Update whenever any of the standard skin settings have changed.
            self.controllerView.invalidateImageCache()
            
        case _ where settingsName.rawValue.hasPrefix(Settings.standardSkinFeatures.inputsAndLayout.settingsKey.rawValue):
            // Update whenever any of the standard skin settings have changed.
            self.controllerView.invalidateImageCache()
            
        default: break
        }
    }
    
    @objc func deepLinkControllerLaunchGame(with notification: Notification)
    {
        guard let game = notification.userInfo?[DeepLink.Key.game] as? Game else { return }
        
        let previousGame = self.game
        self.game = game
        
        if Settings.gameplayFeatures.saveStates.autoLoad
        {
            let fetchRequest = SaveState.rst_fetchRequest() as! NSFetchRequest<SaveState>
            fetchRequest.predicate = NSPredicate(format: "%K == %@ AND %K == %d", #keyPath(SaveState.game), game, #keyPath(SaveState.type), SaveStateType.auto.rawValue)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(SaveState.creationDate), ascending: true)]

            do
            {
                let saveStates = try game.managedObjectContext?.fetch(fetchRequest)
                if let autoLoadSaveState = saveStates?.last
                {
                    let temporaryURL = FileManager.default.uniqueTemporaryURL()
                    try FileManager.default.copyItem(at: autoLoadSaveState.fileURL, to: temporaryURL)
                    
                    _deepLinkResumingSaveState = DeltaCore.SaveState(fileURL: temporaryURL, gameType: game.type)
                }
            }
            catch
            {
                print(error)
            }
        }
        else if let pausedSaveState = self.pausedSaveState, game == (previousGame as? Game)
        {
            // Launching current game via deep link, so we store a copy of the paused save state to resume when emulator core is started.
            
            do
            {
                let temporaryURL = FileManager.default.uniqueTemporaryURL()
                try FileManager.default.copyItem(at: pausedSaveState.fileURL, to: temporaryURL)
                
                _deepLinkResumingSaveState = DeltaCore.SaveState(fileURL: temporaryURL, gameType: game.type)
            }
            catch
            {
                print(error)
            }
        }
        
        if let pauseViewController = self.pauseViewController
        {
            let segue = UIStoryboardSegue(identifier: "unwindFromPauseMenu", source: pauseViewController, destination: self)
            self.unwindFromPauseViewController(segue)
        }
        else if
            let navigationController = self.presentedViewController as? UINavigationController,
            let pageViewController = navigationController.topViewController?.children.first as? UIPageViewController,
            let gameCollectionViewController = pageViewController.viewControllers?.first as? GameCollectionViewController
        {
            NotificationCenter.default.post(name: .dismissSettings, object: self)
            
            let segue = UIStoryboardSegue(identifier: "unwindFromGames", source: gameCollectionViewController, destination: self)
            self.unwindFromGamesViewController(with: segue)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func didActivateGyro(with notification: Notification)
    {
        self.isGyroActive = true
        self.lockOrientation()
        
        // Needs called on main thread
        DispatchQueue.main.async{
            self.setNeedsUpdateOfSupportedInterfaceOrientations()
        }
        
        guard !self.presentedGyroAlert else { return }
        
        self.presentedGyroAlert = true
        
        func presentToastView()
        {
            ToastView.show(NSLocalizedString("Autorotation Disabled", comment: ""), in: self.view, detailText: NSLocalizedString("Pause game to change orientation.", comment: ""))
        }
        
        DispatchQueue.main.async {
            if let transitionCoordinator = self.transitionCoordinator
            {
                transitionCoordinator.animate(alongsideTransition: nil) { (context) in
                    presentToastView()
                }
            }
            else
            {
                presentToastView()
            }
        }
    }
    
    @objc func didDeactivateGyro(with notification: Notification)
    {
        self.isGyroActive = false
        self.unlockOrientation()
        
        // Needs called on main thread
        DispatchQueue.main.async{
            self.setNeedsUpdateOfSupportedInterfaceOrientations()
        }
    }
    
    @objc func didEnableJIT(with notification: Notification)
    {
        DispatchQueue.main.async {
            self.showJITEnabledAlert()
        }
        
        DispatchQueue.global(qos: .utility).async {
            guard let emulatorCore = self.emulatorCore, let emulatorBridge = emulatorCore.deltaCore.emulatorBridge as? MelonDSEmulatorBridge, !emulatorBridge.isJITEnabled
            else { return }
            
            guard emulatorCore.state != .stopped else {
                // Emulator core is not running, which means we can set
                // isJITEnabled to true without resetting the core.
                emulatorBridge.isJITEnabled = true
                return
            }
            
            let isVideoEnabled = emulatorCore.videoManager.isEnabled
            emulatorCore.videoManager.isEnabled = false
            
            let isRunning = (emulatorCore.state == .running)
            if isRunning
            {
                self.pauseEmulation()
            }
            
            let temporaryFileURL = FileManager.default.uniqueTemporaryURL()
            
            let saveState = emulatorCore.saveSaveState(to: temporaryFileURL)
            emulatorCore.stop()
            
            emulatorBridge.isJITEnabled = true
            
            emulatorCore.start()
            emulatorCore.pause()
            
            do
            {
                try emulatorCore.load(saveState)
            }
            catch
            {
                print("Failed to load save state after enabling JIT.", error)
            }
            
            if isRunning
            {
                self.resumeEmulation()
            }
            
            emulatorCore.videoManager.isEnabled = isVideoEnabled
        }
    }
    
    @objc func emulationDidQuit(with notification: Notification)
    {
        DispatchQueue.main.async {
            guard self.presentedViewController == nil else { return }
            
            // Wait for emulation to stop completely before performing segue.
            var token: NSKeyValueObservation?
            token = self.emulatorCore?.observe(\.state, options: [.initial]) { (emulatorCore, change) in
                guard emulatorCore.state == .stopped else { return }
                
                DispatchQueue.main.async {
                    self.game = nil
                    self.performSegue(withIdentifier: "showGamesViewController", sender: nil)
                }
                
                token?.invalidate()
            }
        }
    }
    
    @objc func sceneWillConnect(with notification: Notification)
    {
        guard let scene = notification.object as? ExternalDisplayScene else { return }
        self.connectExternalDisplay(for: scene)
    }

    @objc func sceneDidDisconnect(with notification: Notification)
    {
        guard let scene = notification.object as? ExternalDisplayScene else { return }
        self.disconnectExternalDisplay(for: scene)
    }
    
    @objc func batteryLevelDidChange(with notification: Notification)
    {
        guard let emulatorCore = self.emulatorCore,
              let game = self.game else { return }
        
        let currentBatteryLevel = Double(UIDevice.current.batteryLevel)
        let lowBatteryLevel = Settings.advancedFeatures.lowBattery.lowLevel
        let criticalBatteryLevel = Settings.advancedFeatures.lowBattery.criticalLevel
        
        // Battery low, create auto save state
        if currentBatteryLevel < lowBatteryLevel
        {
            self.updateAutoSaveState(true)
            
            // Battery critical, quit emulation
            if currentBatteryLevel < criticalBatteryLevel,
               !Settings.advancedFeatures.lowBattery.disableCriticalBattery
            {
                NotificationCenter.default.post(name: EmulatorCore.emulationDidQuitNotification, object: nil)
                
                self.emulatorCore?.stop()
                
                return
            }
            
            if !self.batteryLowNotificationShown
            {
                self.showBatteryLowNotification()
            }
        }
        
        if Settings.controllerFeatures.backgroundBlur.tintColor == .battery
        {
            self.updateBackgroundBlur()
        }
        
        if Settings.standardSkinFeatures.styleAndColor.color == .battery
        {
            self.controllerView.invalidateImageCache()
            self.updateControllerSkin()
        }
    }
    
    func showBatteryLowNotification()
    {
        let lowBatteryLevel = Settings.advancedFeatures.lowBattery.lowLevel
        let criticalBatteryLevel = Settings.advancedFeatures.lowBattery.criticalLevel
        
        self.pauseEmulation()
        
        let alertController = UIAlertController(title: NSLocalizedString(String(format: "Battery At %.f%!", lowBatteryLevel * 100), comment: ""), message: NSLocalizedString(String(format: "Ignited will begin creating auto save states in case your device suddenly powers off. At %.f% battery your game session will end and you won't be able to launch a game until you charge your device.", criticalBatteryLevel * 100), comment: ""), preferredStyle: .alert)
        alertController.popoverPresentationController?.sourceView = self.view
        alertController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY, width: 0, height: 0)
        alertController.popoverPresentationController?.permittedArrowDirections = []
        
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
            self.resumeEmulation()
        }))
        self.present(alertController, animated: true, completion: nil)
        
        self.batteryLowNotificationShown = true
    }
    
    @objc func deviceDidShake(with notification: Notification)
    {
        guard self.emulatorCore?.state == .running else { return }
        
        guard Settings.advancedFeatures.skinDebug.isEnabled,
              Settings.advancedFeatures.skinDebug.traitOverride else
        {
            guard Settings.gameplayFeatures.quickSettings.shakeToOpen else
            {
                switch Settings.gameplayFeatures.pauseMenu.shakeToPause
                {
                case .enabled: self.performPauseAction()
                case .gyroDisables where !self.isGyroActive: self.performPauseAction()
                default: break
                }
                return
            }
            
            self.performQuickSettingsAction()
            return
        }
        
        self.pauseEmulation()
        
        let alertController = UIAlertController(title: NSLocalizedString("Override Traits Menu", comment: ""), message: NSLocalizedString("This popup was activated by shaking your device while using the Override Traits feature. You can use it to change or reset your override traits, or to recover from situations where you can't access the main menu.", comment: ""), preferredStyle: .actionSheet)
        alertController.preparePopoverPresentationController(self.view)
        
        alertController.addAction(UIAlertAction(title: "Choose Preset Traits", style: .default, handler: { (action) in
            self.performPresetTraitsAction()
        }))
        alertController.addAction(UIAlertAction(title: "Change Device", style: .default, handler: { (action) in
            self.performDebugDeviceAction()
        }))
        alertController.addAction(UIAlertAction(title: "Change Display Type", style: .default, handler: { (action) in
            self.performDebugDisplayTypeAction()
        }))
        alertController.addAction(UIAlertAction(title: "Reset Traits", style: .default, handler: { (action) in
            Settings.advancedFeatures.skinDebug.device = Settings.advancedFeatures.skinDebug.defaultDevice
            Settings.advancedFeatures.skinDebug.displayType = Settings.advancedFeatures.skinDebug.defaultDisplayType
            self.resumeEmulation()
            if Settings.userInterfaceFeatures.toasts.debug
            {
                self.presentToastView(text: NSLocalizedString("Trait Overrides have been reset", comment: ""))
            }
        }))
        alertController.addAction(UIAlertAction(title: "Open Pause Menu", style: .default, handler: { (action) in
            self.performPauseAction()
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            self.resumeEmulation()
        }))
        self.present(alertController, animated: true, completion: nil)
    }
}

private extension UserDefaults
{
    @NSManaged var desmumeDeprecatedAlertCount: Int
    
    @NSManaged var jitEnabledAlertCount: Int
}

//MARK: - Timer -
private extension GameViewController
{
    func activateRewindTimer()
    {
        self.invalidateRewindTimer()
        guard Settings.gameplayFeatures.rewind.isEnabled else { return }
        let interval = TimeInterval(Settings.gameplayFeatures.rewind.interval)
        self.rewindTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(rewindPollFunction), userInfo: nil, repeats: true)
    }
    
    func invalidateRewindTimer()
    {
        self.rewindTimer?.invalidate()
    }
    
    @objc func rewindPollFunction() {
        
        guard Settings.gameplayFeatures.rewind.isEnabled,
              self.emulatorCore?.state == .running,
              let game = self.game as? Game else { return }
        
        // disable on GBC. saving state without pausing emulation crashes gambette
        guard self.game?.type != .gbc else { return }
        
        let fetchRequest: NSFetchRequest<SaveState> = SaveState.fetchRequest()
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(SaveState.creationDate), ascending: true)]
        
        if let system = System(gameType: game.type)
        {
            fetchRequest.predicate = NSPredicate(format: "%K == %@ AND %K == %@ AND %K == %@", #keyPath(SaveState.game), game, #keyPath(SaveState.coreIdentifier), system.deltaCore.identifier, #keyPath(SaveState.type), NSNumber(value: SaveStateType.rewind.rawValue))
        }
        else
        {
            fetchRequest.predicate = NSPredicate(format: "%K == %@ AND %K == %@", #keyPath(SaveState.game), game, #keyPath(SaveState.type), NSNumber(value: SaveStateType.rewind.rawValue))
        }
        
        do
        {
            let rewindStateCount = try DatabaseManager.shared.viewContext.count(for: fetchRequest) + 1 // + 1 to account for state to be saved after deleting
            let rewindStatesOverLimit = rewindStateCount - Int(floor(Settings.gameplayFeatures.rewind.maxStates))
            if rewindStatesOverLimit > 0
            {
                fetchRequest.fetchLimit = rewindStatesOverLimit
                for rewindStateToDelete in try DatabaseManager.shared.viewContext.fetch(fetchRequest)
                {
                    DatabaseManager.shared.performBackgroundTask { (context) in
                        let temporarySaveState = context.object(with: rewindStateToDelete.objectID)
                        context.delete(temporarySaveState)
                        context.saveWithErrorLogging()
                    }
                }
            }
        }
        catch
        {
            print(error)
        }
        
        let backgroundContext = DatabaseManager.shared.newBackgroundContext()
        backgroundContext.perform {
            
            let game = backgroundContext.object(with: game.objectID) as! Game
            
            let saveState = SaveState(context: backgroundContext)
            saveState.type = .rewind
            saveState.game = game
            
            self.update(saveState, shouldSuspendEmulation: false)
            
            backgroundContext.saveWithErrorLogging()
        }
    }
}
