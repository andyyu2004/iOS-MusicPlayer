//
//  MusicPlayer.swift
//  MusicPlayer
//
//  Created by Andy Yu on 3/07/18.
//  Copyright © 2018 Andy Yu. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer


//let currentItemNotificationKey = "com.andyyu2004.currentItem"

class MusicPlayer {
    
    static let shared =  MusicPlayer()
    
    var songDictionary: [Character: [MPMediaItem]] = [:]
    var sortedDictionaryKeys: [Character] = []
    var songLibrary: [MPMediaItem] = []
    
    var artists: [MPMediaItemCollection] = []
    
    var audioPlayer: AVAudioPlayer?
    
    var currentItem: MPMediaItem?
    var autoQueue: [MPMediaItem] = []
    var manualQueue: [MPMediaItem] = []
    var songHistory: [MPMediaItem] = []
    
    var shuffleMode = ShuffleMode.songs
    var repeatMode = RepeatMode.off //Save these in userdefaults later
    
    enum ShuffleMode {
        case off, songs, album
    }
    
    enum RepeatMode {
        case off, one, all
    }
    
    var isPlaying: Bool {
        return audioPlayer?.isPlaying ?? false
    }
    
    private init() {
        MPMediaLibrary.requestAuthorization{ (status ) in
            switch status {
            case .authorized:
                self.songLibrary = MPMediaQuery.songs().items!
                self.artists = MPMediaQuery.artists().collections!
                self.songDictionary = self.createDictionary(songList: self.songLibrary)
                self.sortedDictionaryKeys = self.sortHashLast(keys: Array(self.songDictionary.keys))
                self.createAudioSession()
            default:
                print("Media Access Denied")
            }
        }
    }
    
    private func createAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let sessionError {
            print(sessionError)
        }
    }
    
    // Queue Functions
    
    func appendQueue(item: MPMediaItem) {
        manualQueue.append(item)
    }
    
    func prependQueue(item: MPMediaItem) {
        manualQueue.prepend(item)
    }
    
    func createAutoQueue() {
        autoQueue.removeAll()
        appendAutoQueue(repetitions: 50)
    }
    
    func appendAutoQueue(repetitions: Int) {
        switch shuffleMode {
        case .songs:
            for _ in 0..<repetitions {
                autoQueue.append(songLibrary.randomItem())
            }
        case .off:
            for _ in 0..<repetitions {
                let index = songLibrary.index(of: currentItem!)! + autoQueue.count + 1
                if index < songLibrary.count {
                    autoQueue.append(songLibrary[index])
                }
            }
        case .album:
            break
        }
    }
    
    func queueTapped(indexPath: IndexPath) {
        let currentStatus = isPlaying
        if !manualQueue.isEmpty {
            //create some form alert warning do u want to clear up next queue
            manualQueue.removeAll()
        }
        songHistory.append(currentItem!)
        appendAutoQueue(repetitions: indexPath.row+1)
        playSong(song: autoQueue[indexPath.row])
        for _ in 0...indexPath.row {
            autoQueue.removeFirst()
        }
        if currentStatus { play() }
    }
    
    func historyTapped(index: Int) {
        let currentStatus = isPlaying
        songHistory.append(currentItem!)
        playSong(song: songHistory[index])
        //songHistory.remove(at: index)
        if currentStatus { play() }
    }

    // Player Functions
    func playSong(song: MPMediaItem) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: song.assetURL!)
            currentItem = song
            audioPlayer?.prepareToPlay()
        } catch let songPlayError {
            print(songPlayError)
        }
    }
    
    func setSong(song: MPMediaItem) {
        playSong(song: song)
        createAutoQueue()
    }
    
    func shuffleAll() {
        shuffleMode = .songs
        setSong(song: songLibrary.randomItem())
        play()
    }
    
    func play(){
        audioPlayer?.play()
    }
    
    func pause(){
        audioPlayer?.pause()
    }
    
    func stop(){
        audioPlayer?.stop()
    }
    
    func replay() {
        let currentState = audioPlayer?.isPlaying
        audioPlayer?.pause()
        audioPlayer?.currentTime = 0
        if currentState! {
            audioPlayer?.play()
        }
    }
    
    func tryPlayNext() -> Bool {
        if repeatMode == .one {
            replay()
            return true
        }
        if !manualQueue.isEmpty || !autoQueue.isEmpty {
            songHistory.append(currentItem!)
            appendAutoQueue(repetitions: 1)
            if !manualQueue.isEmpty {
                currentItem = manualQueue.first
                manualQueue.remove(at: 0)
            } else {
                currentItem = autoQueue.first
                autoQueue.remove(at: 0)
            }
            playSong(song: currentItem!)
            return true
        }
        return false
    }
    
    func tryPlayPrevious() -> Bool {
        if repeatMode == .one {
            replay()
            return true
        }
        if !songHistory.isEmpty {
            if !manualQueue.isEmpty {
                manualQueue.prepend(currentItem!)
            } else {
                autoQueue.prepend(currentItem!)
            }
            currentItem = songHistory.last!
            playSong(song: songHistory.removeLast())
            return true
        }
        return false
    }
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    private func createDictionary(songList: [MPMediaItem]) -> [Character: [MPMediaItem]] {
        var dict: [Character: [MPMediaItem]] = [:]
        for mediaItem in songList {
            var length: Int
            if let count = mediaItem.title?.count {
                if count < 4 { length = count } else { length = 4 }
                let regex = try! NSRegularExpression(pattern: "(A|The)\\s", options: NSRegularExpression.Options.caseInsensitive )
                let modTitle = regex.stringByReplacingMatches(in: mediaItem.title!, options: [], range: NSMakeRange(0, length), withTemplate: "")
                
                if let firstChar = modTitle.uppercased().first {
                    if dict[firstChar] == nil && CharacterSet.uppercaseLetters.contains(firstChar.unicodeScalars.first!) {
                        dict[firstChar] = [mediaItem]
                    } else if dict[firstChar] != nil {
                        dict[firstChar]?.append(mediaItem)
                    } else {
                        if dict["#"] == nil {
                            dict["#"] = [mediaItem]
                        } else {
                            dict["#"]?.append(mediaItem)
                        }
                    }
                }
            }
        }
        return dict
    }
    
    private func sortHashLast(keys: [Character]) -> [Character] {
        var sorted = keys.sorted()
        if sorted.first == "#" {
            let symbol = sorted.removeFirst()
            sorted.append(symbol)
        }
        return sorted
    }
    
    
    
    
}


/*class MusicPlayer: NSObject {
    
    var songLibrary: [MPMediaItem]
    
    var songQueue = [MPMediaItem]()
    var manualQueue = [MPMediaItem]()
    var autoQueue = [MPMediaItem]()
    
    var currentItem: MPMediaItem?
    var audioPlayer: AVAudioPlayer?
    //var songHistory = Stack<MPMediaItem>()
    var songHistory = [MPMediaItem]()
    
    var shuffleMode = ShuffleMode.songs
    var repeatMode = RepeatMode.off //Save these in userdefaults later
    
    enum ShuffleMode {
        case off, songs, album
    }
    
    enum RepeatMode {
        case off, one, all
    }
    
    var isPlaying: Bool {
        return audioPlayer?.isPlaying ?? false
    }
    
    init(library: [MPMediaItem]) {
        self.songLibrary = library
        super.init()
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let sessionError {
            print(sessionError)
        }
    }
    
    func createMusicData(mediaFile: MPMediaItem) -> SongData {
        let songTitle = mediaFile.title ?? ""
        let albumTitle = mediaFile.albumTitle ?? ""
        let artist = mediaFile.artist ?? ""
        let artwork = mediaFile.artwork?.image(at: CGSize(width: 200, height: 200)) ?? UIImage(named: "NoArtwork.jpeg")!
        let comments = mediaFile.comments ?? ""
        let genre = mediaFile.genre ?? ""
        let lyrics = mediaFile.lyrics ?? ""
        let length = mediaFile.playbackDuration
        let trackNumber = mediaFile.albumTrackNumber
        let ID = mediaFile.persistentID
        let assetUrl = mediaFile.assetURL
        
        return SongData(artwork: artwork , title: songTitle, artist: artist, album: albumTitle, length: length, genre: genre, trackNumber: trackNumber, lyrics: lyrics, comments: comments, ID: ID, mediaFile: mediaFile, AVAssetUrl: assetUrl!)
    }
    
    func getCurrentItemData() -> SongData {
        return createMusicData(mediaFile: currentItem!)
    }
    
    func sendCurrentItemNotification() {
        let name = Notification.Name(rawValue: currentItemNotificationKey)
        NotificationCenter.default.post(name: name, object: nil, userInfo: ["currentItem": currentItem!])
    }
    
    func mergeQueue() {
        songQueue = manualQueue + autoQueue
    }
 
    func append(item: MPMediaItem) {
        manualQueue.append(item)
        mergeQueue()
    }
    
    func prepend(item: MPMediaItem) {
        manualQueue.insert(item, at: 0)
        mergeQueue()
    }
    
    func createAutoQueue() {
        autoQueue.removeAll()
        appendAutoQueue(repetitions: 25)
        mergeQueue()
    }
    
    func appendAutoQueue(repetitions: Int) {
        switch shuffleMode {
        case .songs:
            for _ in 0..<repetitions {
                autoQueue.append(songLibrary.randomItem())
            }
        case .off:
            for _ in 0..<repetitions {
                let index = songLibrary.index(of: currentItem!)! + autoQueue.count + 1
                if index < songLibrary.count {
                    autoQueue.append(songLibrary[index])
                }
            }
        case .album:
            break
        }
        mergeQueue()
    }
    
    func queueTapped(indexPath: IndexPath) {
        let currentStatus = isPlaying
        if !manualQueue.isEmpty {
            //create some form alert warning do u want to clear up next queue
            manualQueue.removeAll()
        }
        songHistory.append(currentItem!)
        appendAutoQueue(repetitions: indexPath.row+1)
        playSong(song: autoQueue[indexPath.row])
        for _ in 0...indexPath.row {
            autoQueue.removeFirst()
        }
        if currentStatus { play() }
    }
    
    func historyTapped(index: Int) {
        let currentStatus = isPlaying
        songHistory.append(currentItem!)
        playSong(song: songHistory[index])
        //songHistory.remove(at: index)
        if currentStatus { play() }
    }
    
    // Player Functions
    func playSong(song: MPMediaItem) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: song.assetURL!)
            currentItem = song
            audioPlayer?.prepareToPlay()
            sendCurrentItemNotification()
        } catch let songPlayError {
            print(songPlayError)
        }
    }
    
    func setSong(song: MPMediaItem) {
        playSong(song: song)
        createAutoQueue()
    }
    
    func shuffleAll() {
        shuffleMode = .songs
        setSong(song: songLibrary.randomItem())
        play()
    }
    
    func play(){
        audioPlayer?.play()
    }
    
    func pause(){
        audioPlayer?.pause()
    }
    
    func stop(){
        audioPlayer?.stop()
    }
    
    func replay() {
        let currentState = audioPlayer?.isPlaying
        audioPlayer?.pause()
        audioPlayer?.currentTime = 0
        if currentState! {
            audioPlayer?.play()
        }
    }
    
    func tryPlayNext() -> Bool {
        if repeatMode == .one {
            replay()
            return true
        }
        if !songQueue.isEmpty {
            songHistory.append(currentItem!)
            appendAutoQueue(repetitions: 1)
            currentItem = songQueue.first
            playSong(song: currentItem!)
            songQueue.remove(at: 0)
            if !manualQueue.isEmpty{
                manualQueue.remove(at: 0)
            } else if !autoQueue.isEmpty {
                autoQueue.remove(at: 0)
            }
            return true
        }
        return false
    }
    
    func tryPlayPrevious() -> Bool {
        if repeatMode == .one {
            replay()
            return true
        }
        if !songHistory.isEmpty {
            if !manualQueue.isEmpty {
                manualQueue.insert(currentItem!, at: 0)
            } else {
                autoQueue.insert(currentItem!, at: 0)
            }
            songQueue = manualQueue + autoQueue
            currentItem = songHistory.last!
            playSong(song: songHistory.removeLast())
            return true
        }
        return false
    }
}
*/



