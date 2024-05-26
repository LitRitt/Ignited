//
//  SharedSettings.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 5/22/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import UIKit

extension FileManager {
    static let sharedContainerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.litritt.ignited")!
    static let recentGameArtworkURL = FileManager.sharedContainerURL.appending(component: "recentGameArtwork").appendingPathExtension("png")
    static let mostPlayedGameArtworkURL = FileManager.sharedContainerURL.appending(component: "mostPlayedGameArtwork").appendingPathExtension("png")
}

extension URLSession {
    static func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
}

extension UserDefaults {
    static let shared = UserDefaults(suiteName: "group.com.litritt.ignited")!
}

extension UserDefaults {
    // Games counter Widget
    @NSManaged var numberOfGames: Int
    
    // Recently Played Widget
    @NSManaged var lastPlayedGameName: String
    @NSManaged var lastPlayedGameArtworkURL: String?
    @NSManaged var lastPlayedGameDate: Double
    
    // Most Played Widget
    @NSManaged var mostPlayedGameName: String
    @NSManaged var mostPlayedGameArtworkURL: String?
    @NSManaged var mostPlayedGameTime: Int
}

struct SharedSettings {
    static func registerDefaults() {
        let defaults = [
            #keyPath(UserDefaults.numberOfGames): 0,
            #keyPath(UserDefaults.lastPlayedGameName): "None",
            #keyPath(UserDefaults.lastPlayedGameDate): 0,
            #keyPath(UserDefaults.mostPlayedGameName): "None",
            #keyPath(UserDefaults.mostPlayedGameTime): 0
        ] as [String : Any]
        UserDefaults.shared.register(defaults: defaults)
    }
}

extension SharedSettings {
    // Games counter Widget
    static var numberOfGames: Int {
        set { UserDefaults.shared.numberOfGames = newValue }
        get {
            return UserDefaults.shared.integer(forKey: #keyPath(UserDefaults.numberOfGames))
        }
    }
    
    // Recently Played Widget
    static var lastPlayedGameName: String {
        set { UserDefaults.shared.lastPlayedGameName = newValue }
        get {
            return UserDefaults.shared.string(forKey: #keyPath(UserDefaults.lastPlayedGameName)) ?? "No Games Played"
        }
    }
    
    static var lastPlayedGameDate: Date {
        set { UserDefaults.shared.lastPlayedGameDate = newValue.timeIntervalSince1970 }
        get { return Date(timeIntervalSince1970: UserDefaults.shared.double(forKey: #keyPath(UserDefaults.lastPlayedGameDate))) }
    }
    
    static var lastPlayedGameArtworkUrl: URL? {
        set {
            UserDefaults.shared.lastPlayedGameArtworkURL = newValue?.path()
            guard let artworkURL = newValue else { return }
            if artworkURL.isFileURL {
                do {
                    let data = try Data(contentsOf: artworkURL)
                    try data.write(to: FileManager.recentGameArtworkURL)
                } catch {
                    print(error)
                }
            } else {
                URLSession.getData(from: artworkURL) { data, response, error in
                    guard let data = data, error == nil else { return }
                    do {
                        try data.write(to: FileManager.recentGameArtworkURL)
                    } catch {
                        print(error)
                    }
                }
            }
        }
        get {
            guard let lastPlayedGameArtworkURL = UserDefaults.shared.string(forKey: #keyPath(UserDefaults.lastPlayedGameArtworkURL)) else { return nil }
            return URL(fileURLWithPath: lastPlayedGameArtworkURL)
        }
    }
    
    static var lastPlayedGameArtwork: UIImage? {
        guard let data = try? Data(contentsOf: FileManager.recentGameArtworkURL),
              let artworkImage = UIImage(data: data) else { return nil }
        return artworkImage
    }
    
    // Most Played Widget
    static var mostPlayedGameName: String {
        set { UserDefaults.shared.mostPlayedGameName = newValue }
        get {
            return UserDefaults.shared.string(forKey: #keyPath(UserDefaults.mostPlayedGameName)) ?? "No Games Played"
        }
    }
    
    static var mostPlayedGameTime: Int {
        set { UserDefaults.shared.mostPlayedGameTime = newValue }
        get { return UserDefaults.shared.integer(forKey: #keyPath(UserDefaults.mostPlayedGameTime)) }
    }
    
    static var mostPlayedGameArtworkUrl: URL? {
        set {
            UserDefaults.shared.mostPlayedGameArtworkURL = newValue?.path()
            guard let artworkURL = newValue else { return }
            if artworkURL.isFileURL {
                do {
                    let data = try Data(contentsOf: artworkURL)
                    try data.write(to: FileManager.mostPlayedGameArtworkURL)
                } catch {
                    print(error)
                }
            } else {
                URLSession.getData(from: artworkURL) { data, response, error in
                    guard let data = data, error == nil else { return }
                    do {
                        try data.write(to: FileManager.mostPlayedGameArtworkURL)
                    } catch {
                        print(error)
                    }
                }
            }
        }
        get {
            guard let mostPlayedGameArtworkURL = UserDefaults.shared.string(forKey: #keyPath(UserDefaults.mostPlayedGameArtworkURL)) else { return nil }
            return URL(fileURLWithPath: mostPlayedGameArtworkURL)
        }
    }
    
    static var mostPlayedGameArtwork: UIImage? {
        guard let data = try? Data(contentsOf: FileManager.mostPlayedGameArtworkURL),
              let artworkImage = UIImage(data: data) else { return nil }
        return artworkImage
    }
}
