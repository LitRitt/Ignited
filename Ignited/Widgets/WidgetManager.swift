//
//  WidgetManager.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 5/19/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import Foundation

enum WidgetError: Error {
    case update
}

class WidgetManager {
    static let shared = WidgetManager()
    
    private let suiteName: String = "group.com.litritt.ignitedemulator"
    
    private let keyNumberOfGames: String = "LitWidget.totalNumberOfGames"
    
    init() {}
    
    func updateWidgetData() throws {
        guard let userDefaults = UserDefaults(suiteName: self.suiteName) else { throw WidgetError.update }
        
        let gamesFetchRequest: NSFetchRequest<Game> = Game.fetchRequest()
        gamesFetchRequest.returnsObjectsAsFaults = false
        
        var games: [Game] = []
        
        do {
            games = try DatabaseManager.shared.viewContext.fetch(gamesFetchRequest)
        } catch {
            throw error
        }
        
        userDefaults.set(games.count, forKey: self.keyNumberOfGames)
    }
}

extension WidgetManager {
    static func refresh() {
        DispatchQueue.main.async {
            let manager = WidgetManager.shared
            do {
                try manager.updateWidgetData()
            } catch {
                print(error)
            }
        }
    }
}
