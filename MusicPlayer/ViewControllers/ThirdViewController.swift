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
class ThirdViewController: BaseMusicPlayerViewController {
    
    @IBOutlet weak var AlbumArtwork: UIImageView!

    @IBAction func QueueButton(_ sender: Any) {
        openQueueVC()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Third View Contoller")
    }
    
    func openQueueVC() {
        let queueVC = UIStoryboard(name: "PlayerScene", bundle: nil).instantiateViewController(withIdentifier: "QueueViewController") as! QueueViewController
        self.addChildViewController(queueVC)
        queueVC.view.frame = self.view.frame
        self.view.addSubview(queueVC.view)
        queueVC.didMove(toParentViewController: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setData(){
        if let data = mp.currentItem {
            AlbumArtwork.image = data.artwork?.image(at: CGSize(width: 1000, height: 1000)) ?? UIImage(named: "NoArtwork.jpeg")!
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
