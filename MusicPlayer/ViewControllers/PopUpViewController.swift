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
    @IBOutlet weak var AddToQueue: UIButton!
    
    var popUpMediaFile: MPMediaItem!
    
    @IBAction func PlayNext(_ sender: Any) {
        MusicPlayer.shared.prependQueue(item: popUpMediaFile)
        closeAnimate()
    }

    @IBAction func AddToQueue(_ sender: Any) {
        MusicPlayer.shared.appendQueue(item: popUpMediaFile)
        closeAnimate()
    }
    
    @IBAction func cancelPopup(_ sender: Any) {
        closeAnimate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showAnimate()
        self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
    }
    
    func setData(data: SongData){
        artworkView.image = data.artwork
        songNameLabel.text = data.title
        albumNameLabel.text = data.album
        artistNameLabel.text = data.artist
        popUpMediaFile = data.mediaFile
    }
    
    
    func showAnimate(){
        self.view.transform = CGAffineTransform(scaleX: 1.3,y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: {self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    func closeAnimate(){
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
