//
//  SNESInvalidVRAMOptions.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 1/9/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import SwiftUI

import Features

struct SNESInvalidVRAMOptions
{
    @Option
    var enabledGames: [String] = []
    
    @Option(name: "View Enabled Games", description: "View Enabled Games", detailView: { _ in
        List {
            ForEach(getEnabledGames(), id: \.self) { game in
                Text(game)
            }
            .onDelete(perform: removeGame)
        }
    })
    var viewEnabledGames: String = ""
    
    @Option(name: "Reset Enabled Games",
            description: "Disable Invalid VRAM Access for all games.",
            detailView: { _ in
        Button("Reset Enabled Games") {
            PowerUserOptions.resetFeature(.snesInvalidVRAM)
        }
        .font(.system(size: 17, weight: .bold, design: .default))
        .foregroundColor(.red)
        .displayInline()
    })
    var reset: Bool = false
}

extension SNESInvalidVRAMOptions
{
    static func removeGame(at offsets: IndexSet)
    {
        Settings.snesFeatures.allowInvalidVRAMAccess.enabledGames.remove(atOffsets: offsets)
    }
    
    static func getEnabledGames() -> [String]
    {
        var games: [String] = []
        
        let gameFetchRequest = Game.rst_fetchRequest() as! NSFetchRequest<Game>
        gameFetchRequest.predicate = NSPredicate(format: "%K IN %@", #keyPath(Game.identifier), Settings.snesFeatures.allowInvalidVRAMAccess.enabledGames)
        
        do
        {
            let enabledGames = try DatabaseManager.shared.viewContext.fetch(gameFetchRequest)
            
            for game in enabledGames
            {
                games.append(game.name)
            }
        }
        catch
        {
            print(error)
        }
        
        return games
    }
}
