//
//  PopUpViewController.swift
//  MusicPlayer
//
//  Created by Andy Yu on 27/06/18.
//  Copyright © 2018 Andy Yu. All rights reserved.
//


import UIKit
import MediaPlayer

class PopUpViewController: UIViewController {

    @IBOutlet weak var artworkView: UIImageView!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var albumNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var propertiesTextView: UITextView!
    
    var popUpMediaFile: MPMediaItem!
    let mp = MusicPlayer.shared
    
    @IBAction func PlayNext(_ sender: Any) {
        mp.prependQueue(item: popUpMediaFile)
        closeAnimate()
    }

    @IBAction func AddToQueue(_ sender: Any) {
        mp.appendQueue(item: popUpMediaFile)
        closeAnimate()
    }
    
    @IBAction func cancelPopup(_ sender: Any) {
        closeAnimate()
    }
    
    @IBAction func GotoAlbum(_ sender: Any) {
        print("Goto Album")
        closeAnimate()

    }
    
    @IBAction func GotoArtist(_ sender: Any) {
        print("Goto Artist")
        view.removeFromSuperview()
        openAlbumsVC()
    }
    @IBAction func ViewProperties(_ sender: Any) {
        print("View Properties")
        displayProps()
    }
    
    @IBAction func ViewLyrics(_ sender: Any) {
        print("View Lyrics")
        let lyrics = MusicPlayer.shared.currentItem?.lyrics
        print(lyrics!)
        closeAnimate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showAnimate()
        
        let tgr = UITapGestureRecognizer(target: self, action: #selector(displayProps))
        view.addGestureRecognizer(tgr)
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        
        propertiesTextView.isHidden = true
        propertiesTextView.isSelectable = false
        propertiesTextView.isEditable = false
    }
    
    @objc func displayProps() {
        if propertiesTextView.isHidden {
            var text = ""
            let songData = Utility.createSongData(mediaFile: popUpMediaFile)
            text += "Title: \(songData.title)\n"
            text += "Album: \(songData.album)\n"
            text += "Artist: \(songData.artist)\n"
            text += "Genre: \(songData.genre)\n"
            text += "Length: \(String(Int(songData.length)))s\n"
            text += "Track Number: \(String(songData.trackNumber))\n"
            text += "Comments: \(songData.comments)\n"
            propertiesTextView.text = text
        }
        propertiesTextView.isHidden = !propertiesTextView.isHidden
    }
    
    func setData(data: SongData) {
        artworkView.image = data.artwork
        songNameLabel.text = data.title
        albumNameLabel.text = data.album
        artistNameLabel.text = data.artist
        popUpMediaFile = data.mediaFile
    }
    
    func openAlbumsVC() {
        tabBarController?.selectedIndex = 0
        let navigationVC = tabBarController?.selectedViewController as! UINavigationController
        navigationVC.popToRootViewController(animated: false)
        let artistsVC = navigationVC.topViewController as! ArtistsViewController
        artistsVC.segueToAlbums(by: popUpMediaFile.artist!)
    }
    
    func showAnimate() {
        self.view.transform = CGAffineTransform(scaleX: 1.3,y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: {self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    func closeAnimate() {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        }, completion: {(finished: Bool) in
            if (finished) {
                self.view.removeFromSuperview()
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 


}
