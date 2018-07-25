//
//  BaseCollectionViewController.swift
//  MusicPlayer
//
//  Created by Andy Yu on 20/07/18.
//  Copyright © 2018 Andy Yu. All rights reserved.
//
import UIKit
import MediaPlayer

class BaseCollectionViewController: UIViewController, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let mp = MusicPlayer.shared
    let screenSize = UIScreen.main.bounds.size
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        //let layout = UICollectionViewFlowLayout()
        //layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        //layout.minimumInteritemSpacing = 0
        //layout.minimumLineSpacing = 0
        //collectionView.collectionViewLayout = layout
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 15, 0, 15)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: screenSize.width*0.4, height: screenSize.width*0.4)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

