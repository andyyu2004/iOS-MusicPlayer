//
//  ArtistCollectionViewCell.swift
//  MusicPlayer
//
//  Created by Andy Yu on 19/07/18.
//  Copyright © 2018 Andy Yu. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var collectionCellLabel: UILabel!
    @IBOutlet weak var image: UIImageView!
    
    func setData(_ data: collectionViewData) {
        collectionCellLabel.text = data.name
        image.image = data.artwork
    }
}
