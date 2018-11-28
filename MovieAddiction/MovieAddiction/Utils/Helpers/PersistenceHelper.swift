//
//  PersistenceHelper.swift
//  MovieAddiction
//
//  Created by Edgar Hirama on 27/11/18.
//  Copyright © 2018 Edgar. All rights reserved.
//

import Foundation

class PersistenceHelper {
    
    // Helper method to get a URL to the user's documents directory
    // see https://developer.apple.com/icloud/documentation/data-storage/index.html
    static func getDocumentsURL() -> URL {
        if let url = FileManager.default.urls(for: .applicationDirectory, in: .userDomainMask).first {
            return url
        } else {
            fatalError("Could not retrieve documents directory")
        }
    }
    
    static func saveGenresToDisk(genres: [Genre]) {
        let url = getDocumentsURL().appendingPathComponent("genres.json")
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(genres)
            try data.write(to: url, options: [])
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    static func getGenresFromDisk() -> [Genre] {
        let url = getDocumentsURL().appendingPathComponent("genres.json")
        let decoder = JSONDecoder()
        do {
            let data = try Data(contentsOf: url, options: [])
            let genres = try decoder.decode([Genre].self, from: data)
            return genres
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
}
