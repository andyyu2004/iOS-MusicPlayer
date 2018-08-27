//
//  AlbumsViewController.swift
//  MusicPlayer
//
//  Created by Andy Yu on 20/07/18.
//  Copyright © 2018 Andy Yu. All rights reserved.
//

import UIKit
import MediaPlayer

class AlbumsViewController: BaseCollectionViewController {
    
    var artist: String!
    var albums: [MPMediaItemCollection] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate = self
        
        navigationItem.title = "Albums"
        
        albums = retrieveAlbumInfo(artist: artist)
    }
    
    func retrieveAlbumInfo(artist: String) -> [MPMediaItemCollection] {
        let query = MPMediaQuery.albums()
        query.addFilterPredicate(MPMediaPropertyPredicate(value: artist, forProperty: MPMediaItemPropertyAlbumArtist, comparisonType: .equalTo))
        let album = query.collections!
        return album
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToAlbumPlayerSegue" {
            let albumPlayerScene = segue.destination as! AlbumPlayerViewController
            albumPlayerScene.albumTitle = sender as! String
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension AlbumsViewController: UICollectionViewDataSource {
    
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let album = albums[indexPath.row].representativeItem?.albumTitle ?? ""
        
        performSegue(withIdentifier: "ToAlbumPlayerSegue", sender: album)
    }
    
}
