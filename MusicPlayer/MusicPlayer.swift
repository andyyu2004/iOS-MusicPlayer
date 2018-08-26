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

/// Singleton class to control an AVAudioPlayer
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
    
    /// Requests for access to the media library and creates the necessary data structures to contain the media items.
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
    
    /// Creates audio session to prepare the audio player for playback
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
    
    /// Appends the automatically generated queue.
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
    
    // Called when an item of the queue is tapped and skips to the item and clears the queue before that item.
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
    
    // Called when item in the history is tapped.
    func historyTapped(index: Int) {
        let currentStatus = isPlaying
        songHistory.append(currentItem!)
        playSong(song: songHistory[index])
        if currentStatus { play() }
    }
    
    func postStateDidChangeNotification() {
        NotificationCenter.default.post(name: .MusicPlayerStateDidChange, object: nil, userInfo: [:])
    }

    // Player Functions
    
    /// Play the MPMediaItem described by the parameter
    func playSong(song: MPMediaItem) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: song.assetURL!)
            currentItem = song
            audioPlayer?.prepareToPlay()
        } catch let songPlayError {
            print(songPlayError)
        }
    }
    
    /// Removes all generated queue items and generates a new queue and instantly plays the required MPMediaItem.
    func setSong(song: MPMediaItem) {
        playSong(song: song)
        createAutoQueue()
    }
    
    /// Plays random item from library and generates a shuffled queue
    func shuffleAll() {
        shuffleMode = .songs
        setSong(song: songLibrary.randomItem())
        play()
    }
    
    func play(){
        audioPlayer?.play()
        postStateDidChangeNotification()
    }
    
    func pause(){
        audioPlayer?.pause()
        postStateDidChangeNotification()
    }
    
    func stop(){
        audioPlayer?.stop()
        postStateDidChangeNotification()
    }
    
    func replay() {
        let currentState = audioPlayer?.isPlaying
        audioPlayer?.pause()
        audioPlayer?.currentTime = 0
        if currentState! {
            play()
        }
    }
    
    func setPlaybackPosition(time: TimeInterval) {
        audioPlayer?.currentTime = time
        play()
    }
    
    // Tries to play next MPMediaItem next in the queue and returns a boolean indicating whether it is successful or not.
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
    
    /// Attempts to play MPMediaItem at the end of the end of the song history stack and returns a boolean indicating whether it was successful or not.
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
    
    /// Accepts an array of MPMediaItem and generates a dictionary with the key representing the MPMediaItems sorted by alphabet.
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
    
    /// Custom sorting algorithm to match with apples automated sorting of MPMediaQuery.
    private func sortHashLast(keys: [Character]) -> [Character] {
        var sorted = keys.sorted()
        if sorted.first == "#" {
            let symbol = sorted.removeFirst()
            sorted.append(symbol)
        }
        return sorted
    }
    
}

extension Notification.Name {
    static let MusicPlayerStateDidChange = Notification.Name("MusicPlayerStateDidChange")
}



