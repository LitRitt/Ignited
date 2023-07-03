# Ignited Emulator

[![Swift Version](https://img.shields.io/badge/swift-5.0-orange.svg)](https://swift.org/)
[![License: AGPL v3](https://img.shields.io/badge/License-AGPL%20v3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)

Ignited is a multi-core emulator front-end for iOS devices. It provides a beautiful user interface and rich features that other emulators lack. An experience that feels right at home on your premium devices. Join the [Discord](https://discord.gg/qEtKFJt5dR) to follow along with development, suggest new features, and chat. Become a [Patron](https://patreon.com/litritt) to support development and unlock benefits, such as being able to install Ignited straight from this page without having to sideload it.

<p align="center">
  <img src="https://f005.backblazeb2.com/file/lit-apps/assets/ignited/device-previews.png" width=100%><br/>
  <em>Mario and Metroid are properties of Nintendo Co., Ltd. and are not associated with Ignited or LitRitt.</em>
</p>

## Supported Systems
- Nintendo Entertainment System (NES)
- Super Nintendo Entertainment System (SNES)
- Nintendo 64 (N64)
- Game Boy / Game Boy Color (GBC)
- Game Boy Advance (GBA)
- Nintendo DS (DS)
- Sega Genesis / Mega Drive (GEN)

## Features
- Accurate, full speed emulation thanks to mature underlying emulator cores.
    - NES: [Nestopia](https://github.com/0ldsk00l/nestopia)
    - SNES: [Snes9x](https://github.com/snes9xgit/snes9x)
    - N64: [mupen64plus](https://github.com/mupen64plus/mupen64plus-core)
    - GBC: [Gambatte](https://github.com/sinamas/gambatte)
    - GBA: [visualboyadvance-m](https://github.com/visualboyadvance-m/visualboyadvance-m)
    - DS: [melonDS](https://github.com/Arisotura/melonDS)
    - GEN: [Genesis Plus GX](https://github.com/ekeeke/Genesis-Plus-GX)
- Beautiful, native UI.
    - Browse and play your favorite games with a UI designed from the ground up for iOS.
    - Automatically displays appropriate box art for imported games.
    - Change a game’s artwork to anything you want, or select from the built-in game artwork database.
- Controller Support
    - Supports PS4, PS5, Xbox One S, Xbox Series X, and MFi game controllers.
    - Supports bluetooth (and wired) keyboards, as well as the Apple Smart Keyboard.
    - Completely customize button mappings on a per-system, per-controller basis.
    - Map buttons to special “Quick Save”, “Quick Load,” and “Fast Forward” actions.
- Custom Controller Skins
    - Beautiful built-in controller skins for all systems.
    - Import controller skins made by others, or even make your own to share with the world!
- Save States
    - Save and load save states for any game from the pause menu.
    - Lock save states to prevent them from being accidentally overwritten.
    - Automatically makes backup save states to ensure you never lose your progress.
    - Support for “Quick Saves,” save states that can be quickly saved/loaded with a single button press (requires external controller).
- Fast Forwarding
    - Speed through slower parts of games by running the game much faster than normal.
    - Easily enable or disable from the pause menu, or optionally with a mapped button on an external controller.
- Ignited Sync
    - Sync your games, game saves, save states, cheats, controller skins, and controller mappings between devices.
    - View version histories of everything you sync and optionally restore them to earlier versions.
    - Supports both Google Drive and Dropbox.
- Hold Button
    - Choose buttons for Ignited to hold down on your behalf, freeing up your thumbs to press other buttons instead.
    - Perfect for games that typically require one button be held down constantly (ex: run button in Mario games, or the A button in Mario Kart).
- 3D/Haptic Touch
    - Use 3D or Haptic Touch to “peek” at games, save states, and cheat codes.
    - App icon shortcuts allow quick access to your most recently played games, or optionally customize the shortcuts to always include certain games.
- Cheat Codes
    - NES
        - Game Genie
    - SNES: 
        - Game Genie
        - Pro Action Replay
    - N64
        - GameShark
    - GBC
        - Game Genie
        - GameShark
    - GBA
        - Action Replay
        - Code Breaker
        - GameShark
    - DS
        - Action Replay
- Gyroscope support  **(WarioWare: Twisted! only)**
- Microphone support **(DS only)**

## Installation

Patrons can install Ignited OTA directly from my site, without needing to sideload it. Non-patrons can still use AltStore to download and update Ignited.

<p align="center">
  <img src="https://user-images.githubusercontent.com/705880/114452847-c1db4980-9b8d-11eb-8f8f-de7998562222.png" width=100px height=100px>
</p>

1. Download AltServer for Mac or PC from https://altstore.io
2. Connect your iOS device to your computer via lightning cable (or USB-C for iPads).
3. [Follow these instructions](https://altstore.io/faq/) to install AltStore onto your device with AltServer.
4. Navigate to https://litritt.com/ignited
5. Click on the `AltStore Install` link of the Downloads section

Once you've installed Ignited with AltStore, **you'll need to refresh it at least once every 7 days to prevent it from expiring** and requiring a re-installation. AltStore will periodically attempt to refresh your apps in the background when on the same WiFi as AltServer, but you can also manually refresh apps by pressing "Refresh All" in AltStore. AltStore will also let you know whenever a new update is released, allowing you to update Ignited directly within AltStore.

Alternatively, you are welcome to download the compiled `.ipa`'s from [Releases](https://github.com/LitRitt/Ignited/releases) and sideload them using whatever sideloading method you prefer, but you will not receive automatic updates and will have to manually update Ignited by re-sideloading each new version.

## Project Overview

Ignited was designed from the beginning to be modular, and for that reason each "Delta Core" has its own GitHub repo and is added as a submodule to the main Ignited project. Additionally, Ignited uses two forks of Riley Testut's private frameworks to share common functionality between apps: Roxas and Harmony.

[**Ignited**](https://github.com/LitRitt/Ignited)  
Ignited is just a regular, sandboxed iOS application. The Ignited app repo (aka this one) contains all the code specific to the Ignited app itself, such as storyboards, app-specific view controllers, database logic, etc.

[**DeltaCore**](https://github.com/LitRitt/DeltaCore)  
DeltaCore serves as the “middle-man” between the high-level app code and the specific emulation cores. By working with this framework, you have access to all the core Ignited features, such as emulation, controller skins, save states, cheat codes, etc. Other potential emulator apps will use this framework extensively.

[**Roxas**](https://github.com/LitRitt/Roxas)    
Roxas is my own framework used across my projects, developed to simplify a variety of common tasks used in iOS development.

[**Harmony**](https://github.com/LitRitt/Harmony)   
Harmony is my personal syncing framework designed to sync Core Data databases. Harmony listens for changes to an app's persistent store, then syncs any changes with a remote file service (such as Google Drive or Dropbox).

**Delta Cores**  
Each system in Ignited is implemented as its own "Delta Core", which serves as a standard emulation API Ignited can understand regardless of the underlying core. For the most part, you don't interact directly with specific Delta Cores, but rather indirectly through `DeltaCore`.
- [NESDeltaCore](https://github.com/LitRitt/NESDeltaCore)
- [SNESDeltaCore](https://github.com/LitRitt/SNESDeltaCore)
- [N64DeltaCore](https://github.com/LitRitt/N64DeltaCore)
- [GBCDeltaCore](https://github.com/LitRitt/GBCDeltaCore)
- [GBADeltaCore](https://github.com/LitRitt/GBADeltaCore)
- [MelonDSDeltaCore](https://github.com/LitRitt/MelonDSDeltaCore)
- [GPGXDeltaCore](https://github.com/LitRitt/GPGXDeltaCore)

## Project Requirements
- Xcode 12
- Swift 5+
- iOS 14 or later

## Compilation Instructions

> Ignited uses Git LFS to manage large files, so first make sure you have [installed Git LFS](https://git-lfs.github.com).

1. Clone this repository by running the following command in Terminal*  
```bash
$ git clone https://github.com/LitRitt/Ignited.git
```  

1. Update Git submodules
```bash
$ cd Ignited
$ git submodule update --init --recursive
```  

1. Open `Systems/Systems.xcworkspace` and select the "Systems" project in the project navigator (a.k.a. the left sidebar).
2. Select "Systems" under `Targets`, then click the `Signing & Capabilities` tab.
3. Change `Team` from "Yvette Testut" to your own account.
4. Close `Systems/Systems.xcworkspace`, then open `Delta.xcworkspace`.
5. Repeat steps 4 & 5 with the "Delta" target.
6. Change Delta's `Bundle Identifier` to something unique, such as by appending your GitHub username (ex: `com.litritt.ignited.MyGitHubUsername`).
7. Build + run app! 🎉

## Licensing
Due to the licensing of emulator cores used by Ignited, I have no choice but to distribute Ignited under the **AGPLv3 license**. That being said, I explicitly give permission for anyone to use, modify, and distribute all *my* original code for this project in any form, with or without attribution, without fear of legal consequences (dependencies remain under their original licenses, however).

## Contact Me

* Email: dev@litritt.com
* Discord: [Ignited Emulator](https://discord.gg/qEtKFJt5dR)
