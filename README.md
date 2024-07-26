# Ignited Emulator

[![Swift Version](https://img.shields.io/badge/swift-5.0-orange.svg)](https://swift.org/)
[![License: AGPL v3](https://img.shields.io/badge/License-AGPL%20v3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)

A feature packed and customizable emulator made for the modern era.

## Supported Systems
- Nintendo Entertainment System (NES)
- Super Nintendo Entertainment System (SNES)
- Nintendo 64 (N64)
- Game Boy (GB)
- Game Boy Color (GBC)
- Game Boy Advance (GBA)
- Nintendo DS (DS)
- Sega Genesis / Mega Drive (GEN)
- Sega Master System (SMS)
- Sega Game Gear (GG)

## Features

- Full Controller Support - Use any modern bluetooth or MFi controller
- Customizable Controller Skins - Change the color, style, and layout of the standard skins
- Custom Controller Skins - Create or download new skins to enhance your gameplay
- Adjustable Fast Forward - Use hold, toggle, or cycle modes to change to game speed to faster or slower than normal
- Cheats - Adds cheat codes to modify your games
- Save states - Save and load states, automatic save states, and quick saves
- Rewind - Go back to a previous point in gameplay within 1-5 minutes on supported systems
- Ignited Sync - Backup your games and saves
- App Theming - Choose a theme color to use for the UI, skins, and more
- Toast Notifications - Get notified when saving, loading, and performing other actions
- Favorite Games - Mark games as favorites to make them easier to find and play
- Animated Artwork - Use GIFs as your game artwork
- Customizable Audio - Choose when game audio plays and how loud
- Game Screenshots - Save the game screen to Files or Photos with an optional countdown
- Quick Settings - Access actions and settings quickly during gameplay
- AirPlay Support - Play your games on an external display
- Background Blur - Beautiful and customizable background for skins featuring a blurring version of the game screen
- Vibration - Feel your buttons with customizable vibration feedback
- Button Sounds - Hear your buttons with customizable audio feedback
- Touch Overlay - See your buttons with customizable visual feedback

## Installation

Install via the public TestFlight invite - https://testflight.apple.com/join/ExWvtjcq

## Project Overview

Ignited was designed from the beginning to be modular, and for that reason each "Delta Core" has its own GitHub repo and is added as a submodule to the main Ignited project. Additionally, Ignited uses two of [Riley Testut](https://github.com/rileytestut)'s private frameworks to share common functionality between apps: Roxas and Harmony.

[**Ignited**](https://github.com/LitRitt/Ignited)  
Ignited is just a regular, sandboxed iOS application. The Ignited app repo (aka this one) contains all the code specific to the Ignited app itself, such as storyboards, app-specific view controllers, database logic, etc.

[**DeltaCore**](https://github.com/LitRitt/DeltaCore)  
DeltaCore serves as the “middle-man” between the high-level app code and the specific emulation cores. By working with this framework, you have access to all the core Ignited features, such as emulation, controller skins, save states, cheat codes, etc. Other potential emulator apps will use this framework extensively.

[**Roxas**](https://github.com/LitRitt/Roxas)    
Roxas is [Riley Testut](https://github.com/rileytestut)'s framework used across his projects, developed to simplify a variety of common tasks used in iOS development.

[**Harmony**](https://github.com/LitRitt/Harmony)   
Harmony is [Riley Testut](https://github.com/rileytestut)'s personal syncing framework designed to sync Core Data databases. Harmony listens for changes to an app's persistent store, then syncs any changes with a remote file service (such as Google Drive or Dropbox).

**Delta Cores**
Each system in Ignited is implemented as its own "Delta Core", which serves as a standard emulation API Ignited can understand regardless of the underlying core. For the most part, you don't interact directly with specific Delta Cores, but rather indirectly through `DeltaCore`.

- [NESDeltaCore](https://github.com/LitRitt/NESDeltaCore)
- [SNESDeltaCore](https://github.com/LitRitt/SNESDeltaCore)
- [N64DeltaCore](https://github.com/LitRitt/N64DeltaCore)
- [GBCDeltaCore](https://github.com/LitRitt/GBCDeltaCore)
- [mGBADeltaCore](https://github.com/LitRitt/mGBADeltaCore)
- [GBADeltaCore](https://github.com/LitRitt/GBADeltaCore) **Legacy*
- [MelonDSDeltaCore](https://github.com/LitRitt/MelonDSDeltaCore)
- [DSDeltaCore](https://github.com/LitRitt/DSDeltaCore) **Legacy*
- [GPGXDeltaCore](https://github.com/LitRitt/GPGXDeltaCore)

## Project Requirements

- Xcode 12
- Swift 5+
- iOS 16 or later

## Compilation Instructions

1. Clone this repository by running the following command in Terminal*  
```bash
$ git clone https://github.com/LitRitt/Ignited.git --recursive
```  
2. Open `Ignited/Config/CodeSigning.xcconfig` and fill it out with your correct details.
3. Open `Ignited/Delta.xcworkspace` in Xcode
4. Build + run app! 🎉

## Licensing

Ignited is licensed under the **AGPLv3 license** which ensures that all improvements made to forks of this project must be made open source in order to benefit all users.

## Contact Me

* Discord: [Ignited Emulator](https://discord.gg/qEtKFJt5dR)
