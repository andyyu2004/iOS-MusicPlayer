//
//  SecondViewController.swift
//  MusicPlayer
//
//  Created by Andy Yu on 22/06/18.
//  Copyright © 2018 Andy Yu. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation

// Add moveable queue
// Add scrubbing and proper time display.
//var musicPlayer: MusicPlayer!

class SecondViewController: UIViewController {//, UITableViewDelegate, UITableViewDataSource, AudioControlling {
    
    //Outlets
    @IBOutlet weak var playPauseButton: UIBarButtonItem!
    @IBOutlet weak var toolbarSongDisplay: UILabel!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var tableView: UITableView!
    
    /*
    //Class Variables
    var currentItem: MPMediaItem?
    var songDictionary: [Character: [MPMediaItem]] = [:]
    var sortedDictionaryKeys: [Character] = []

    var nowPlayingInfoCenter: MPNowPlayingInfoCenter!

    var allSongItems: [MPMediaItem] = []
    var noOfSongs: Int = 0
    
    var musicPlayerController: MusicPlayerController!
    
    let refreshControl = UIRefreshControl()
    
    //Actions
    @IBAction func playPause(_ sender: Any) {
        setPlayPause()
    }
    
    @IBAction func forward(_ sender: Any) {
        playNext()
    }
    
    @IBAction func reverse(_ sender: Any) {
        playPrevious()
    }
    
    @IBAction func replay(_ sender: Any) {
        replay()
    }
    
    //View Controller Functions
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        setPlayPauseIcon()
        setToolbarVisibility()
        toolbarSongDisplay.text = currentItem?.title!
        //musicPlayer.audioPlayer?.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("View Controller Two")
        
        MPMediaLibrary.requestAuthorization { (status) in
            if status == .authorized {
                let query = MPMediaQuery.songs()
                self.allSongItems = query.items!
                self.noOfSongs = self.allSongItems.count
                
                self.songDictionary = self.createDictionary()
                self.sortedDictionaryKeys = self.sortHashLast(keys: Array(self.songDictionary.keys))
                //musicPlayer = MusicPlayer(library: self.allSongItems)
                
//                DispatchQueue.main.async {
//                    self.tableView?.rowHeight = UITableViewAutomaticDimension;
//                    //self.tableView?.estimatedRowHeight = 43
//                    self.tableView?.reloadData()
//                }
            } else {
                self.displayMediaLibraryError()
            }
        }
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: tableView.estimatedRowHeight, right: 0)
        tableView.delegate = self
        tableView.dataSource = self
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressListener(_:)))
        tableView.addGestureRecognizer(longPress)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateCurrentItem), name: Notification.Name(rawValue: currentItemNotificationKey), object: nil)
        
        nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        
        tableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(shuffleAll(_:)), for: .valueChanged)
        
        //musicPlayerController = MusicPlayerController(viewController: self)
    }
    
    @objc func shuffleAll(_ refreshControl: UIRefreshControl) {
        musicPlayer.shuffleAll()
        refreshControl.endRefreshing()
        setToolbarVisibility()
        playPauseButton.image = UIImage(named: "pauseIcon")
        updateNowPlayingInfo()
    }
    
    func displayMediaLibraryError() {
        var error: String
        switch MPMediaLibrary.authorizationStatus() {
        case .restricted:
            error = "Media library access restricted"
        case .denied:
            error = "Media library access denied by user"
        default:
            error = "Unknown Error Occured"
        }
        let controller = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        controller.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { (action) in
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
            } else {
                // Fallback on earlier versions
            }
        }))
        present(controller, animated: true, completion: nil)
    }
    
    
    func setPlayPauseIcon() {
        if musicPlayer.isPlaying {
            playPauseButton.image = UIImage(named: "pauseIcon")
        } else {
            playPauseButton.image = UIImage(named: "playIcon")
        }
    }
    
//    override func remoteControlReceived(with event: UIEvent?) {
//        if let event = event, event.type == .remoteControl {
//            switch event.subtype {
//            case .remoteControlPlay:
//                setPlayPause()
//            case .remoteControlPause:
//                setPlayPause()
//            case .remoteControlNextTrack:
//                playNext()
//            case .remoteControlPreviousTrack:
//                playPrevious()
//            default:
//                print("remote is fucked")
//            }
//        }
//    }
    
    @objc func changePlaybackPositionCommand(_ event: MPChangePlaybackRateCommandEvent) {
        print("fuck")
    }
    
    @objc func updateCurrentItem(notification: NSNotification) {
        currentItem = notification.userInfo?["currentItem"] as? MPMediaItem
    }

    func updateNowPlayingInfo() {
        let nowPlaying = musicPlayer.createMusicData(mediaFile: currentItem!)
        toolbarSongDisplay.text = nowPlaying.title
        
        let image = nowPlaying.artwork
        let artwork = MPMediaItemArtwork(boundsSize: image.size) { size in return image }
        
        nowPlayingInfoCenter.nowPlayingInfo = [
            MPMediaItemPropertyTitle: nowPlaying.title,
            MPMediaItemPropertyArtist: nowPlaying.artist,
            MPMediaItemPropertyPlaybackDuration: nowPlaying.length,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: musicPlayer.audioPlayer?.currentTime as Any,
            MPMediaItemPropertyArtwork: artwork,
            MPMediaItemPropertyAlbumTitle: nowPlaying.album,
            MPNowPlayingInfoPropertyPlaybackRate: 1
        ]
    }
    
    @objc func longPressListener(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            let touchPoint = gestureRecognizer.location(in: self.tableView)
            if let indexPath = self.tableView.indexPathForRow(at: touchPoint) {
                openPopUpVC(indexPath: indexPath)
            }
        }
    }
    
    func openPopUpVC(indexPath: IndexPath){
        let popUpVC = UIStoryboard(name: "MusicScene", bundle: nil).instantiateViewController(withIdentifier: "PopUpVC") as! PopUpViewController
        self.addChildViewController(popUpVC)
        popUpVC.view.frame = self.view.frame
        self.view.addSubview(popUpVC.view)
        popUpVC.didMove(toParentViewController: self)
        
        let key = sortedDictionaryKeys[indexPath.section]
        let mediaFile = songDictionary[key]![indexPath.row]
        
        let songData = musicPlayer.createMusicData(mediaFile: mediaFile)
        popUpVC.setData(data: songData)
    }
    
    func createDictionary() -> [Character: [MPMediaItem]] {
        for mediaItem in allSongItems {
            var length: Int
            if let count = mediaItem.title?.count {
                if count < 4 { length = count } else { length = 4 }
                let regex = try! NSRegularExpression(pattern: "(A|The)\\s", options: NSRegularExpression.Options.caseInsensitive )
                let modTitle = regex.stringByReplacingMatches(in: mediaItem.title!, options: [], range: NSMakeRange(0, length), withTemplate: "")
                	
                if let firstChar = modTitle.uppercased().first {
                    if songDictionary[firstChar] == nil && CharacterSet.uppercaseLetters.contains(firstChar.unicodeScalars.first!) {
                        songDictionary[firstChar] = [mediaItem]
                    } else if songDictionary[firstChar] != nil{
                        songDictionary[firstChar]?.append(mediaItem)
                    } else {
                        if songDictionary["#"] == nil {
                            songDictionary["#"] = [mediaItem]
                        } else {
                            songDictionary["#"]?.append(mediaItem)
                        }
                    }
                }
            }
        }
        return songDictionary
    }
    
    func sortHashLast(keys: [Character]) -> [Character] {
        var sorted = keys.sorted()
        if sorted.first == "#" {
            let symbol = sorted.removeFirst()
            sorted.append(symbol)
        }
        return sorted
    }
    
    func setToolbarVisibility() {
        toolbar.isHidden = currentItem == nil
    }
    
    //Table View Protocols
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return songDictionary.keys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = sortedDictionaryKeys[section]
        return (songDictionary[key]?.count)!
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return String(sortedDictionaryKeys[section])
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let key = sortedDictionaryKeys[indexPath.section]
        let mediaFile = songDictionary[key]![indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "MusicPlayerCell", for: indexPath) as! SongCell
        
        let musicData = musicPlayer.createMusicData(mediaFile: mediaFile)
        cell.setData(data: musicData)
        cell.selectionStyle = .gray
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let key = sortedDictionaryKeys[indexPath.section]
        let song = songDictionary[key]![indexPath.row]
        setSong(song: song)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sortedDictionaryKeys.map{String($0)}
    }

    //Player Functions
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("Song Did Finish Playing")
        playNext()
    }
    
    func setPlayPause() {
        if !musicPlayer.isPlaying {
            play()
        } else {
            pause()
        }
    }
    
    func setSong(song: MPMediaItem) {
        musicPlayer.setSong(song: song)
        toolbarSongDisplay.text = song.title!
        play()
        updateNowPlayingInfo()
        setToolbarVisibility()
    }
    
    func play(){
        guard currentItem != nil && musicPlayer.manualQueue.isEmpty else { return }
        musicPlayer.audioPlayer?.delegate = self
        musicPlayer.play()
        playPauseButton.image = UIImage(named: "pauseIcon")
        updateNowPlayingInfo()
    }
    
    func pause(){
        musicPlayer.pause()
        playPauseButton.image = UIImage(named: "playIcon")
        updateNowPlayingInfo()
    }
    
    func stop(){
        musicPlayer.stop()
        playPauseButton.image = UIImage(named: "playIcon")
        updateNowPlayingInfo()
    }
    
    func replay() {
        musicPlayer.replay()
        updateNowPlayingInfo()
    }
    
    func playNext() {
        if musicPlayer.tryPlayNext() {
            play()
            updateNowPlayingInfo()
        } else {
            stop()
        }
    }
    
    func playPrevious() {
        if let currentTime = musicPlayer.audioPlayer?.currentTime, currentTime > 1 {
            replay()
            return
        } else if musicPlayer.tryPlayPrevious() {
            play()
            updateNowPlayingInfo()
        } else {
            stop()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 */
}







