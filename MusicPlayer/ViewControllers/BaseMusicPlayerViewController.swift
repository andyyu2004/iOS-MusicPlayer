//
//  MusicController.swift
//  MusicPlayer
//
//  Created by Andy Yu on 18/07/18.
//  Copyright © 2018 Andy Yu. All rights reserved.
//

import Foundation
import MediaPlayer
import UIKit

/// The Base Class for all view controllers that want to control the audio player
class BaseMusicPlayerViewController: UIViewController, AVAudioPlayerDelegate {

    @IBOutlet weak var playPauseButton: UIBarButtonItem?
    @IBOutlet weak var controlToolbar: UIToolbar?
    @IBOutlet weak var shuffleIcon: UIBarButtonItem?
    
    //Actions
    
    @IBAction func playPauseAction(_ sender: Any) {
        setPlayPause()
    }
    
    @IBAction func forwardAction(_ sender: Any) {
        playNext()
    }

    @IBAction func reverseAction(_ sender: Any) {
        playPrevious()
    }
    
    @IBAction func shuffleAction(_ sender: Any) {
        setShuffleMode()
    }
    
    //Properties
    
    let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
    let cc = MPRemoteCommandCenter.shared()
    let mp = MusicPlayer.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateNowPlayingInfo), name: .MusicPlayerStateDidChange, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateNowPlayingInfo()
        setShuffleIconColour()
    }
    
    // Functions
    
    // Updating statuses
    
    func setToolbarVisibility() {
        controlToolbar?.isHidden = mp.currentItem == nil
    }
    
    func setPlayPauseIcon() {
        if mp.isPlaying {
            playPauseButton?.image = UIImage(named: "pauseIcon")
        } else {
            playPauseButton?.image = UIImage(named: "playIcon")
        }
    }
    
    /// Sets the colour of shuffle icon to indicate state
    func setShuffleIconColour() {
        switch mp.shuffleMode {
        case .songs:
            self.shuffleIcon?.tintColor = UIColor(displayP3Red: 0, green: 0.5, blue: 1, alpha: 1)
        default:
            self.shuffleIcon?.tintColor = nil
        }
    }
    
    /// Updates all the necessary data when the audio player changes state
    @objc func updateNowPlayingInfo() {
        setPlayPauseIcon()
        setToolbarVisibility()
        mp.audioPlayer?.delegate = self
        
        guard let currentItem = mp.currentItem else { return }
        let nowPlaying = Utility.createSongData(mediaFile: currentItem)
        let image = nowPlaying.artwork
        let artwork = MPMediaItemArtwork(boundsSize: image.size) { size in return image }
        
        let playbackRate = mp.isPlaying ? 1 : 0
        
        nowPlayingInfoCenter.nowPlayingInfo = [
            MPMediaItemPropertyTitle: nowPlaying.title,
            MPMediaItemPropertyAlbumTitle: nowPlaying.album,
            MPMediaItemPropertyArtist: nowPlaying.artist,
            MPMediaItemPropertyPlaybackDuration: nowPlaying.length,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: mp.audioPlayer?.currentTime as Any,
            MPMediaItemPropertyArtwork: artwork,
            MPNowPlayingInfoPropertyPlaybackRate: playbackRate
        ]
    }	

    
    // Player Controlling Functions
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playNext()
    }
    
    @objc func setPlayPause() {
        if mp.currentItem == nil {
            mp.shuffleAll()
        } else if mp.isPlaying {
            mp.pause()
        } else {
            mp.play()
        }
    }
    
    func setSong(song: MPMediaItem) {
        mp.setSong(song: song)
        mp.play()
    }
    
    @objc func playNext() {
        if mp.tryPlayNext() {
            mp.play()
        } else {
            mp.stop()
            mp.currentItem = nil
        }
    }
    
    @objc func playPrevious() {
        if let currentTime = mp.audioPlayer?.currentTime, currentTime > 1.5 {
            mp.replay()
        } else if mp.tryPlayPrevious() {
            mp.play()
        } else {
            mp.stop()
        }
    }

    @objc func setShuffleMode() {
        switch mp.shuffleMode {
        case .off:
            mp.shuffleMode = .songs
        case .songs:
            mp.shuffleMode = .off
        default:
            break
        }
        setShuffleIconColour()
        mp.createAutoQueue()
    }
    
    @objc func changePlaybackPositionCommand(_ event: MPChangePlaybackPositionCommandEvent) {
        mp.setPlaybackPosition(time: event.positionTime)
    }
    
    @objc func repeatTest() {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
















