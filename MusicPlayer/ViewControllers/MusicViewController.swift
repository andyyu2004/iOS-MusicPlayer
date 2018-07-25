//
//  MusicViewController.swift
//  MusicPlayer
//
//  Created by Andy Yu on 18/07/18.
//  Copyright © 2018 Andy Yu. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation

class MusicViewController: BaseMusicPlayerViewController {

    //Outlets
    @IBOutlet weak var toolbarSongDisplay: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let refreshControl = UIRefreshControl()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        configureVisualSettings()
        
        enableCommandCenter()
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressListener(_:)))
        tableView.addGestureRecognizer(longPress)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(audioRouteChangedListener(_:)),
            name: NSNotification.Name.AVAudioSessionRouteChange,
            object: nil)
        tableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(shuffleAll(_:)), for: .valueChanged)
        refreshControl.tintColor = UIColor.white
        
    }
    
    // Functions
    
    func configureVisualSettings() {
        tableView.separatorStyle = .none
        tableView.sectionIndexColor = UIColor.white
        tableView.sectionIndexBackgroundColor = UIColor.darkGray
        
        //tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: tableView.rowHeight*2, right: 0)
    }
    
    @objc dynamic private func audioRouteChangedListener(_ notification: NSNotification) {
        let audioRouteChangeReason = notification.userInfo![AVAudioSessionRouteChangeReasonKey] as! UInt
        
        switch audioRouteChangeReason {
        case AVAudioSessionRouteChangeReason.newDeviceAvailable.rawValue:
            print("headphone plugged in")
        case AVAudioSessionRouteChangeReason.oldDeviceUnavailable.rawValue:
            print("headphones pulled out")
            mp.pause()
            DispatchQueue.main.async {
                self.updateNowPlayingInfo()
            }
        default:
            break
        }
    }
    
    // Enable Lock Screen Controls
    
    func enableCommandCenter() {
        cc.playCommand.addTarget(self, action: #selector(setPlayPause))
        cc.pauseCommand.addTarget(self, action: #selector(setPlayPause))
        cc.previousTrackCommand.addTarget(self, action: #selector(playPrevious))
        cc.nextTrackCommand.addTarget(self, action: #selector(playNext))
        cc.changeShuffleModeCommand.addTarget(self, action: #selector(shuffleAction))
        cc.changeRepeatModeCommand.addTarget(self, action: #selector(repeatTest))
        cc.changePlaybackPositionCommand.addTarget(self, action: #selector(changePlaybackPositionCommand(_:)))
        
        cc.togglePlayPauseCommand.isEnabled = true
        cc.previousTrackCommand.isEnabled = true
        cc.nextTrackCommand.isEnabled = true
        cc.changeShuffleModeCommand.isEnabled = true
        cc.changeRepeatModeCommand.isEnabled = true
        cc.changePlaybackPositionCommand.isEnabled = true
    }
    
    @objc func shuffleAll(_ refreshControl: UIRefreshControl) {
        refreshControl.endRefreshing()
        mp.shuffleAll()
        updateNowPlayingInfo()
    }
    
    @objc func longPressListener(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            let touchPoint = gestureRecognizer.location(in: self.tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
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
        
        let key = mp.sortedDictionaryKeys[indexPath.section]
        let mediaFile = mp.songDictionary[key]![indexPath.row]
        
        let songData = Utility.createSongData(mediaFile: mediaFile)
        popUpVC.setData(data: songData)
    }
    
    // Updating Statuses
    
    override func updateNowPlayingInfo() {
        super.updateNowPlayingInfo()
        toolbarSongDisplay.text = mp.currentItem?.title ?? ""
    }
    
    
    
    deinit {
        cc.playCommand.removeTarget(self, action: #selector(setPlayPause))
        cc.pauseCommand.removeTarget(self, action: #selector(setPlayPause))
        cc.previousTrackCommand.removeTarget(self, action: #selector(playPrevious))
        cc.nextTrackCommand.removeTarget(self, action: #selector(playNext))
        cc.changeShuffleModeCommand.removeTarget(self, action: #selector(shuffleAction))
        cc.changeRepeatModeCommand.removeTarget(self, action: #selector(repeatTest))
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


extension MusicViewController:  UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return mp.songDictionary.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = mp.sortedDictionaryKeys[section]
        return (mp.songDictionary[key]?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let key = mp.sortedDictionaryKeys[indexPath.section]
        let mediaFile = mp.songDictionary[key]![indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "MusicPlayerCell", for: indexPath) as! SongCell
        
        let musicData = Utility.createSongData(mediaFile: mediaFile)
        cell.setData(data: musicData)
        cell.selectionStyle = .gray
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let key = mp.sortedDictionaryKeys[indexPath.section]
        let song = mp.songDictionary[key]![indexPath.row]
        setSong(song: song)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return mp.sortedDictionaryKeys.map{String($0)}
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return String(mp.sortedDictionaryKeys[section])
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.darkGray
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
    }
}

















