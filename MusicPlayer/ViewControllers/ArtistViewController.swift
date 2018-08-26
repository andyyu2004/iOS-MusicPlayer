//
//  FirstViewController.swift
//  MusicPlayer
//
//  Created by Andy Yu on 22/06/18.
//  Copyright © 2018 Andy Yu. All rights reserved.
//

import UIKit
import MediaPlayer

class ArtistViewController: BaseCollectionViewController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("View Contoller One")
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView.collectionViewLayout = layout
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ArtistToAlbumSegue" {
            let albumScene = segue.destination as! AlbumViewController
            albumScene.artist = sender as! String
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ArtistViewController: UICollectionViewDataSource  {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mp.artists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let artistCollection = mp.artists[indexPath.row]
        let artistData = Utility.createCollectionViewData(repItem: artistCollection.representativeItem!, type: "artist")
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "artistCollectionViewCell", for: indexPath) as! CollectionViewCell
        cell.setData(artistData)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let artist = mp.artists[indexPath.row].representativeItem?.artist ?? ""
        performSegue(withIdentifier: "ArtistToAlbumSegue", sender: artist)
    }
}
