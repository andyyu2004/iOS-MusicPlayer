//
//  AlbumPlayerViewController.swift
//  MusicPlayer
//
//  Created by Andy Yu on 3/08/18.
//  Copyright © 2018 Andy Yu. All rights reserved.
//

import UIKit
import MediaPlayer

class AlbumPlayerViewController: BaseMusicPlayerViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var songs: [MPMediaItem] = []
        
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}

extension AlbumPlayerViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MusicPlayerCell") as! SongCell
        return cell
    }
    
    
}
