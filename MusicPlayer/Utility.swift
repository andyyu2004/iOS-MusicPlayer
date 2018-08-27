//
//  Utility.swift
//  MusicPlayer
//
//  Created by Andy Yu on 18/07/18.
//  Copyright © 2018 Andy Yu. All rights reserved.
//

import Foundation
import MediaPlayer

/// Useful helper functions
class Utility {
    
    static func createSongData(mediaFile: MPMediaItem) -> SongData {
        let songTitle = mediaFile.title ?? ""
        let albumTitle = mediaFile.albumTitle ?? ""
        let artist = mediaFile.artist ?? ""
        let artwork = mediaFile.artwork?.image(at: CGSize(width: 200, height: 200)) ?? UIImage(named: "NoArtwork.jpeg")!
        let comments = mediaFile.comments ?? ""
        let genre = mediaFile.genre ?? ""
        let lyrics = mediaFile.lyrics ?? "No Lyrics Detected"
        let length = mediaFile.playbackDuration
        let trackNumber = mediaFile.albumTrackNumber
        let ID = mediaFile.persistentID
        let assetUrl = mediaFile.assetURL
        
        return SongData(artwork: artwork , title: songTitle, artist: artist, album: albumTitle, length: length, genre: genre, trackNumber: trackNumber, lyrics: lyrics, comments: comments, ID: ID, mediaFile: mediaFile, AVAssetUrl: assetUrl!)
    }
    
    static func createCollectionViewData(repItem: MPMediaItem, type: String) -> collectionViewData {
        var name = ""
        if type == "album" {
            name = repItem.albumTitle ?? ""
        } else {
            name = repItem.artist ?? ""
        }
        let artwork = repItem.artwork?.image(at: CGSize(width: 200, height: 200)) ?? UIImage(named: "NoArtwork.jpeg")! //Change this item to some blank person or something
        return collectionViewData(name: name, artwork: artwork)
        
    }
}

extension Array {
    func randomItem() -> Element {
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
    
    mutating func prepend(_ item: Element) {
        self.insert(item, at: 0)
    }
}
