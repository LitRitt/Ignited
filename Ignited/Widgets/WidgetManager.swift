//
//  WidgetManager.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 5/19/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import Foundation
import WidgetKit

struct WidgetManager {
    static let shared = WidgetManager()
    
    static func refresh() {
        DispatchQueue.main.async {
            WidgetManager.shared.updateWidgetData()
        }
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    private func updateWidgetData() {
        let gamesFetchRequest: NSFetchRequest<Game> = Game.fetchRequest()
        gamesFetchRequest.returnsObjectsAsFaults = false
        
        var games: [Game] = []
        var recentGames: [Game] = []
        var mostPlayedGames: [Game] = []
        
        do {
            games = try DatabaseManager.shared.viewContext.fetch(gamesFetchRequest)
            recentGames = try DatabaseManager.shared.viewContext.fetch(Game.recentlyPlayedFetchRequest)
            mostPlayedGames = try DatabaseManager.shared.viewContext.fetch(Game.mostPlayedFetchRequest)
        } catch {
            print(error)
        }
        
        SharedSettings.numberOfGames = games.count
        
        if let mostRecentGame = recentGames.first {
            SharedSettings.lastPlayedGameName = mostRecentGame.name
            SharedSettings.lastPlayedGameArtworkUrl = mostRecentGame.artworkURL
            SharedSettings.lastPlayedGameDate = mostRecentGame.playedDate ?? Date()
        } else {
            SharedSettings.lastPlayedGameName = "No Games Played"
            SharedSettings.lastPlayedGameArtworkUrl = nil
            SharedSettings.lastPlayedGameDate = Date.distantPast
        }
        
        if let mostPlayedGame = mostPlayedGames.first {
            SharedSettings.mostPlayedGameName = mostPlayedGame.name
            SharedSettings.mostPlayedGameArtworkUrl = mostPlayedGame.artworkURL
            SharedSettings.mostPlayedGameTime = Int(mostPlayedGame.playTime)
        } else {
            SharedSettings.mostPlayedGameName = "No Games Played"
            SharedSettings.mostPlayedGameArtworkUrl = nil
            SharedSettings.mostPlayedGameTime = 0
        }
    }
}
