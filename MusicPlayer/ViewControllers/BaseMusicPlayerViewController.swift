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
    
    func setShuffleIconColour() {
        switch mp.shuffleMode {
        case .songs:
            self.shuffleIcon?.tintColor = UIColor(displayP3Red: 0, green: 0.5, blue: 1, alpha: 1)
        default:
            self.shuffleIcon?.tintColor = nil
        }
    }
    
    func updateNowPlayingInfo() {
        setPlayPauseIcon()
        setToolbarVisibility()
        mp.audioPlayer?.delegate = self
        
        guard let currentItem = mp.currentItem else { return }
        let nowPlaying = Utility.createSongData(mediaFile: currentItem)
        let image = nowPlaying.artwork
        let artwork = MPMediaItemArtwork(boundsSize: image.size) { size in return image }
        
        var playbackRate: NSNumber {
            if mp.isPlaying {
                return 1
            } else {
                return 0
            }
        }
        
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
    
    // Player Functions
    
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
        updateNowPlayingInfo()
    }
    
    func setSong(song: MPMediaItem) {
        mp.setSong(song: song)
        mp.play()
        updateNowPlayingInfo()
    }
    
    @objc func playNext() {
        if mp.tryPlayNext() {
            mp.play()
        } else {
            mp.stop()
            mp.currentItem = nil
        }
        updateNowPlayingInfo()
    }
    
    @objc func playPrevious() {
        if let currentTime = mp.audioPlayer?.currentTime, currentTime > 1.5 {
            mp.replay()
        } else if mp.tryPlayPrevious() {
            mp.play()
        } else {
            mp.stop()
        }
        updateNowPlayingInfo()
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
        mp.audioPlayer?.currentTime = event.positionTime
        updateNowPlayingInfo()
    }
    
    @objc func repeatTest() {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
















