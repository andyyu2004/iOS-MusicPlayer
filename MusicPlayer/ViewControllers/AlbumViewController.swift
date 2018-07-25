//
//  AlbumViewController.swift
//  MusicPlayer
//
//  Created by Andy Yu on 20/07/18.
//  Copyright © 2018 Andy Yu. All rights reserved.
//

import UIKit
import MediaPlayer

class AlbumViewController: BaseCollectionViewController {
    
    var albums: [MPMediaItemCollection] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate = self
        
        navigationItem.title = "Albums"
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension AlbumViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let repItem = albums[indexPath.row].representativeItem!
        let data = Utility.createCollectionViewData(repItem: repItem, type: "album")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "albumCell", for: indexPath) as! CollectionViewCell
        cell.setData(data)
        return cell
        
    }
    
    
}
