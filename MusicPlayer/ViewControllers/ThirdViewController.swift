//
//  ThirdViewController.swift
//  MusicPlayer
//
//  Created by Andy Yu on 22/06/18.
//  Copyright © 2018 Andy Yu. All rights reserved.
//

import UIKit
import MediaPlayer

// switch third view controller and queue around probably/
class ThirdViewController: BaseMusicPlayerViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var lyricsView: UITextView!
    @IBOutlet weak var albumArtwork: UIImageView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var playPauseBigButton: UIButton!
    
    @IBAction func QueueButton(_ sender: Any) {
        openQueueVC()
    }
    @IBAction func sliderMoved(_ sender: Any) {

    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Third View Contoller")
        // Open on load as this view controller is incomplete
        // openQueueVC()
        NotificationCenter.default.addObserver(self, selector: #selector(updateLyrics), name: .MusicPlayerStateDidChange, object: nil)
    
        let tgrLyrics = UITapGestureRecognizer(target: self, action: #selector(showLyrics(_:)))
        tgrLyrics.delegate = self // allows multiple gesture recognisers simultaneously
        let tgrArtwork = UITapGestureRecognizer(target: self, action: #selector(showLyrics(_:)))
        
        lyricsView.isEditable = false
        lyricsView.isSelectable = false
        lyricsView.isHidden = true
        lyricsView.alpha = 0.82
        
        
        albumArtwork.isUserInteractionEnabled = true
        lyricsView.addGestureRecognizer(tgrLyrics)
        albumArtwork.addGestureRecognizer(tgrArtwork)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setData()
        updateLyrics()
    }
    
    override func setPlayPauseIcon() {
        if mp.isPlaying {
            playPauseBigButton?.setImage(UIImage(named: "pauseIcon"), for: .normal)
        } else {
            playPauseBigButton?.setImage(UIImage(named: "playIcon"), for: .normal)
        }
    }
    
    override func updateNowPlayingInfo() {
        super.updateNowPlayingInfo()
        setData()
        
    }
    
    @objc func showLyrics(_ gr: UITapGestureRecognizer) {
        lyricsView.isHidden = !lyricsView.isHidden
    }
    
    @objc func updateLyrics() {
        var lyrics = mp.currentItem?.lyrics ?? "No Song Playing"
        if lyrics == "" { lyrics = "No Lyrics Detected" }
        lyricsView.text = lyrics
    }
    
    func openQueueVC() {
        let queueVC = UIStoryboard(name: "PlayerScene", bundle: nil).instantiateViewController(withIdentifier: "QueueViewController") as! QueueViewController
        addChildViewController(queueVC)
        queueVC.view.frame = self.view.frame
        view.addSubview(queueVC.view)
        queueVC.didMove(toParentViewController: self)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func setData() {
        if let data = mp.currentItem {
            albumArtwork.image = data.artwork?.image(at: CGSize(width: 1000, height: 1000)) ?? UIImage(named: "NoArtwork.jpeg")!
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
