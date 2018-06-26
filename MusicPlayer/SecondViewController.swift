//
//  SecondViewController.swift
//  MusicPlayer
//
//  Created by Andy Yu on 22/06/18.
//  Copyright © 2018 Andy Yu. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation

class SecondViewController: UIViewController, MPMediaPickerControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    let myTableView = UITableView(frame: CGRect.zero, style: .grouped)
    var myMediaPicker: MPMediaPickerController?
    var musicPlayer: MPMusicPlayerController?

    var songQuery: SongQuery = SongQuery()
    var albums: [AlbumInfo] = []
    var songs: [AlbumInfo] = []
    var artists: [AlbumInfo] = []
    
    var noOfSongs: Int = 0
    var noOfArtists: Int = 0
    var noOfAlbums: Int = 0

    
    
    @IBAction func Play(_ sender: Any) {
        musicPlayer?.play()
    }
    
    @IBAction func Pause(_ sender: Any) {
        musicPlayer?.pause()
    }
    
    @IBAction func openLib(_ sender: UIButton) {
        print("Button pressed")
        //displayMediaPickerAndPlayItem()
        //printSongs()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("View Controller Two")
        //songs = songQuery.get(songCategory: "Song")
        MPMediaLibrary.requestAuthorization { (status) in
            if status == .authorized {
                //self.albums = self.songQuery.get(songCategory: "Album")
                //self.artists = self.songQuery.get(songCategory: "Artist")
                self.songs = self.songQuery.get(songCategory: "Song")
                self.noOfSongs = self.numberOfSongs()
                DispatchQueue.main.async {
                    self.tableView?.rowHeight = UITableViewAutomaticDimension;
                    self.tableView?.estimatedRowHeight = 50;
                    self.tableView?.reloadData()
                }
            } else {
                print("self.displayerorr")
                self.displayMediaLibraryError()
            }
        }
        
        //printSongs()
        
        
        //noOfAlbums = self.numberOfAlbums()
        //noOfArtists = self.numberOfArtists()
        musicPlayer = MPMusicPlayerController.systemMusicPlayer
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func displayMediaLibraryError() {
        var error: String
        switch MPMediaLibrary.authorizationStatus() {
        case .restricted:
            error = "Media library access restricted"
        case .denied:
            error = "Media library access denied by user"
        default:
            error = "Unknown Error Occured"
        }
        let controller = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        controller.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { (action) in
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
            } else {
                // Fallback on earlier versions
            }
        }))
        present(controller, animated: true, completion: nil)
    }
    
    //func numberOfSections(in tableView: UITableView) -> Int {
    //    return numberOfAlbums()
    //}
    
    func printSongs(){
        print("Called Print Songs")
        let albums = songQuery.get(songCategory: "Song")
        //print(albums)
        print("No.ofalbums", albums.count)
        for album in albums {
            //let songTitle = song.songs[0].songTitle
            //print(album.artist, album.albumTitle)
            //print(album)
            for song in album.songs {print(song.songTitle)}
        }
        //for i in 0..<albums.count {print(i); print(albums[i])}
        print(noOfSongs)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noOfSongs
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //print("indexpath.row", indexPath.row)
        let data = songs[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "MusicPlayerCell", for: indexPath) as! SongCell
        let musicData = MusicData(image: data.image, songName: data.songs[0].songTitle, artist: data.artist, album: data.albumTitle)
        //let artwork = data.songs[0].mediaData.value(forProperty: MPMediaItemPropertyArtwork) as? MPMediaItemArtwork
        //cell.imageView?.image = artwork?.image(at: CGSize(width: 60, height: 60))
        cell.setData(data: musicData)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = songs[indexPath.row]
        setSong(song: data.songs[0].mediaData)
        print(data)
        musicPlayer?.play()
    }
    
    func numberOfArtists() -> Int {
        let allArtists = songQuery.get(songCategory: "Artist")
        return allArtists.count
    }

    func numberOfAlbums() -> Int {
        let allAlbums = songQuery.get(songCategory: "Album")
        return allAlbums.count
    }
    
    func numberOfSongs() -> Int {
        //let allSongs = songQuery.get(songCategory: "Song")
        //return allSongs.count
        return self.songs.count
    }
    
    func setSong(song: MPMediaItem) {
        musicPlayer?.setQueue(with: MPMediaItemCollection(items: [song]))
    }
    
    /*func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        
        print("Func media picker")
        
        myMusicPlayer = MPMusicPlayerApplicationController.applicationMusicPlayer
        
        for item in mediaItemCollection.items {
            //print("Iterate Through Items")
            //print(item)
        }
        
        if let player = myMusicPlayer{
            player.beginGeneratingPlaybackNotifications()
            player.setQueue(with: mediaItemCollection)
            player.play()
            print("Playing")
            
            // self.updateNowPlayingItem()
            myMediaPicker?.dismiss(animated: true, completion: nil)
        }
    }
    
    func displayMediaPickerAndPlayItem(){
        myMediaPicker = MPMediaPickerController(mediaTypes: .anyAudio)
        if let picker = myMediaPicker{
            print("instantiated media picker")
            picker.delegate = self
            view.addSubview(picker.view)
            present(picker, animated: true, completion: nil)
        } else {
            print("Could not instantiate a media picker")
        }
    }
    
    func nowPlayingItemIsChanged(notifications: NSNotification){
        print("Playing item is changed")
        let key = "MPMusicPlayerControllerNowPlayingItemPersistentIDKey"
        
        let persistentID = notifications.userInfo![key] as? NSString
        
        if let id = persistentID{
            print("Persistent ID = \(id)")
        }
    }
    
    func volumeIsChaged(notification: NSNotification){
        print("Volume Is Changed")
    }
    
    func updateNowPlayingItem(){
        /*if let nowPlayingItem = self.myMusicPlayer!.nowPlayingItem{
            let nowPlayingTitle = nowPlayingItem.title
            self.nowPlayingLabel.text = nowPlayingTitle
        } else {
            self.nowPlayingLabel.text = "Nothing Playing"
        } */
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        print("User Selected Cancel")
        myMediaPicker?.dismiss(animated: true, completion: nil)
    }
    */
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    



}

