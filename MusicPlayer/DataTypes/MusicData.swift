//
//  MusicData.swift
//  MusicPlayer
//
//  Created by Andy Yu on 26/06/18.
//  Copyright © 2018 Andy Yu. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer


struct SongData {
    var artwork: UIImage
    var title: String
    var artist: String
    var album: String
    var length: TimeInterval
    var genre: String
    var trackNumber: Int
    var lyrics: String
    var comments: String
    var ID: MPMediaEntityPersistentID
    var mediaFile: MPMediaItem
    var AVAssetUrl: URL
}

struct collectionViewData {
    var name: String
    var artwork: UIImage
}
