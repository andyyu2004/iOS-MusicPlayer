//
//  SongQuery.swift
//  MusicPlayer
//
//  Created by Andy Yu on 25/06/18.
//  Copyright © 2018 Andy Yu. All rights reserved.
//

import Foundation
import MediaPlayer

struct SongInfo {
    var album: String
    var songTitle: String
    var songID: NSNumber
    var trackNumber: NSNumber
    var genre: String
    var comments: String
    var mediaData: MPMediaItem
}

struct AlbumInfo {
    var artist: String
    var albumTitle: String
    var songs: [SongInfo]
    //var year: NSNumber
    var image: UIImage
}

class SongQuery {
    
    func get(songCategory: String) -> [AlbumInfo] {

        var albums: [AlbumInfo] = []
        let query: MPMediaQuery
        
        if songCategory == "Artist" {
            query = MPMediaQuery.artists()
            print("artist query")
            //print(query)
        } else if songCategory == "Album" {
            print("Album Query")
            query = MPMediaQuery.albums()
            //print(query)
        } else if songCategory == "Genre"{
            query = MPMediaQuery.genres()
        } else {
            query = MPMediaQuery.songs()
            print("Song Query")
            //print(query)
        }
        
        let albumItems: [MPMediaItemCollection] = query.collections! as [MPMediaItemCollection]
        
        for album in albumItems {
            let albumItems = album.items as [MPMediaItem]
            var songs: [SongInfo] = []
            var albumTitle: String? = ""
            var artist: String? = ""
            var albumImage: UIImage?
            
            for song in albumItems {
                //Album Data
                artist = song.value(forProperty: MPMediaItemPropertyArtist) as? String
                albumTitle = song.value(forProperty: MPMediaItemPropertyAlbumTitle) as? String
                let image = song.value(forProperty: MPMediaItemPropertyArtwork) as? MPMediaItemArtwork
                albumImage = image?.image(at: CGSize(width: 60,height: 60))
                
                //Song Data
                let album = song.value(forProperty: MPMediaItemPropertyAlbumTitle) as? String
                let songTitle = song.value(forProperty: MPMediaItemPropertyTitle) as? String
                let songID = song.value(forProperty: MPMediaItemPropertyPersistentID) as! NSNumber
                let trackNumber = song.value(forProperty: MPMediaItemPropertyAlbumTrackNumber) as! NSNumber
                let genre = song.value(forProperty: MPMediaItemPropertyGenre) as? String
                let comments = song.value(forProperty: MPMediaItemPropertyComments) as? String
                
                let songInfo: SongInfo = SongInfo(album: album ?? "", songTitle: songTitle ?? "", songID: songID, trackNumber: trackNumber, genre: genre ?? "", comments: comments ?? "", mediaData: song)
                songs.append(songInfo)
            }
            let albumInfo: AlbumInfo = AlbumInfo(artist: artist ?? "", albumTitle: albumTitle ?? "", songs: songs, image: albumImage ?? UIImage(named: "NoArtwork.jpeg")!)
            albums.append(albumInfo)
        }
        return albums
    }
    
    func getItem(songID: NSNumber) -> MPMediaItem {
        let property: MPMediaPropertyPredicate = MPMediaPropertyPredicate(value: songID, forProperty: MPMediaItemPropertyPersistentID)
        let query: MPMediaQuery = MPMediaQuery()
        query.addFilterPredicate(property)
        
        var items: [MPMediaItem] = query.items! as [MPMediaItem]
        
        return items[items.count - 1]
    }
}
