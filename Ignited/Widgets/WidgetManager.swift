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
    
    func updateWidgetData() {
        let gamesFetchRequest: NSFetchRequest<Game> = Game.fetchRequest()
        gamesFetchRequest.returnsObjectsAsFaults = false
        
        var games: [Game] = []
        
        do {
            games = try DatabaseManager.shared.viewContext.fetch(gamesFetchRequest)
        } catch {
            print(error)
        }
        
        SharedSettings.numberOfGames = games.count
        
        gamesFetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Game.playedDate), ascending: false)]
        
        var recentGames: [Game] = []
        
        do {
            recentGames = try DatabaseManager.shared.viewContext.fetch(gamesFetchRequest)
        } catch {
            print(error)
        }
        
        if let mostRecentGame = recentGames.first {
            SharedSettings.lastPlayedGameName = mostRecentGame.name
            SharedSettings.lastPlayedGameArtworkUrl = mostRecentGame.artworkURL
            SharedSettings.lastPlayedGameDate = mostRecentGame.playedDate ?? Date()
        }
    }
}

extension WidgetManager {
    static func refresh() {
        DispatchQueue.main.async {
            WidgetManager.shared.updateWidgetData()
        }
        WidgetCenter.shared.reloadAllTimelines()
    }
}
