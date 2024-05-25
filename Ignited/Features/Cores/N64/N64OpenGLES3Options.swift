//
//  N64OpenGLES3Options.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 1/10/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import SwiftUI

import Features

struct N64OpenGLES3Options
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
            description: "Disable OpenGLES 3 for all games.",
            detailView: { _ in
        Button("Reset Enabled Games") {
            PowerUserOptions.resetFeature(.n64OpenGLES3)
        }
        .font(.system(size: 17, weight: .bold, design: .default))
        .foregroundColor(.red)
        .displayInline()
    })
    var reset: Bool = false
}

extension N64OpenGLES3Options
{
    static func removeGame(at offsets: IndexSet)
    {
        Settings.n64Features.openGLES2.enabledGames.remove(atOffsets: offsets)
    }
    
    static func getEnabledGames() -> [String]
    {
        var games: [String] = []
        
        let gameFetchRequest = Game.rst_fetchRequest() as! NSFetchRequest<Game>
        gameFetchRequest.predicate = NSPredicate(format: "%K IN %@", #keyPath(Game.identifier), Settings.n64Features.openGLES2.enabledGames)
        
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
