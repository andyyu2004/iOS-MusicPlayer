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
    
}
