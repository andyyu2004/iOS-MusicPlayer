//
//  SongCell.swift
//  MusicPlayer
//
//  Created by Andy Yu on 26/06/18.
//  Copyright © 2018 Andy Yu. All rights reserved.
//

import UIKit

class SongCell: UITableViewCell {
    
    @IBOutlet weak var MusicImageView: UIImageView!
    @IBOutlet weak var MusicTitleLabel: UILabel!
    @IBOutlet weak var MusicArtistLabel: UILabel!
    
    func setData(data: SongData) {
        MusicImageView.image = data.artwork
        MusicTitleLabel.text = data.title
        MusicArtistLabel.text = data.artist
    }
    
    override var showsReorderControl: Bool {
        get {
            return true // short-circuit to on
        }
        set { }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        if editing == false {
            return // ignore any attempts to turn it off
        }
        
        super.setEditing(editing, animated: animated)
    }

    
}
