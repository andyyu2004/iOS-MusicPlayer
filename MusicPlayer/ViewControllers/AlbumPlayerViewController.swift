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
    
    var albumTitle: String!
    var songs: [MPMediaItem] = []
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = albumTitle
 
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        DispatchQueue.main.async {
            self.songs = self.retrieveSongs(by: self.albumTitle)
            print(self.songs.map{$0.title!})
            self.tableView.reloadData()
        }
    }
    
    func retrieveSongs(by album: String!) -> [MPMediaItem] {
        let query = MPMediaQuery.songs()
        query.addFilterPredicate(MPMediaPropertyPredicate(value: album, forProperty: MPMediaItemPropertyAlbumTitle, comparisonType: .equalTo))
        let songs = query.items!
        return songs
    }
}

extension AlbumPlayerViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MusicPlayerCell") as! SongCell
        let mediaFile = songs[indexPath.row]
        let data = Utility.createSongData(mediaFile: mediaFile)
        cell.setData(data: data)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let song = songs[indexPath.row]
        setSong(song: song)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
