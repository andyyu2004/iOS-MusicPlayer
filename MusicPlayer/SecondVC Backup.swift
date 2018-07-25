//
//  SecondViewController.swift
//  MusicPlayer
//
//  Created by Andy Yu on 22/06/18.
//  Copyright © 2018 Andy Yu. All rights reserved.
//


/*
 
 
 
import UIKit
import MediaPlayer


var musicPlayer: MPMusicPlayerController?

var songQueue = [MPMediaItem]()

var songHistory = Stack<MPMediaItem>()
var currentItem: MPMediaItem!

func printTitles(array: [MPMediaItem]){
    var acc = [String]()
    for item in array {
        acc.append(item.title!)
    }
    print(acc)
}

class SecondViewController: UIViewController, MPMediaPickerControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var playPauseButton: UIBarButtonItem!
    @IBOutlet weak var toolbarSongDisplay: UILabel!
    
    //let myTableView = UITableView(frame: CGRect.zero, style: .grouped)
    
    //var albums: [AlbumInfo] = []
    //var songs: [AlbumInfo] = []
    //var artists: [AlbumInfo] = []
    
    var allSongs: [MPMediaItemCollection] = []
    
    
    var noOfSongs: Int = 0
    var noOfArtists: Int = 0
    var noOfAlbums: Int = 0
    
    
    @IBAction func playPause(_ sender: Any) {
        if (musicPlayer?.playbackState == .paused || musicPlayer?.playbackState == .stopped) {
            play()
        } else {
            pauseSongs()
        }
    }
    
    @IBAction func forward(_ sender: Any) {
        skipSong()
    }
    
    @IBAction func reverse(_ sender: Any) {
        playPrevious()
    }
    
    @IBAction func replay(_ sender: Any) {
        replay()
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
    
    func setPlayPauseStatus(){
        if (musicPlayer?.playbackState == .paused || musicPlayer?.playbackState == .stopped) {
            playPauseButton.image = UIImage(named: "playIcon.png")
        } else if musicPlayer?.playbackState == .playing {
            playPauseButton.image = UIImage(named: "pauseIcon.png")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        setPlayPauseStatus()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("View Controller Two")
        //songs = songQuery.get(songCategory: "Song")
        
        //printSongs()
        //noOfAlbums = self.numberOfAlbums()
        //noOfArtists = self.numberOfArtists()
        MPMediaLibrary.requestAuthorization { (status) in
            if status == .authorized {
                //self.albums = self.songQuery.get(songCategory: "Album")
                //self.artists = self.songQuery.get(songCategory: "Artist")
                
                //self.songs = self.songQuery.get(songCategory: "Song")
                let query = MPMediaQuery.songs()
                self.allSongs = query.collections! as [MPMediaItemCollection]
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
        
        tableView.delegate = self
        tableView.dataSource = self
        
        musicPlayer = MPMusicPlayerController.systemMusicPlayer
        musicPlayer?.beginGeneratingPlaybackNotifications()
        
        NotificationCenter.default.addObserver(self, selector: #selector(songChangedHandler), name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: musicPlayer)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressListener(_:)))
        tableView.addGestureRecognizer(longPress)
        
    }
    
    @objc func longPressListener(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizerState.began{
            let touchPoint = gestureRecognizer.location(in: self.tableView)
            if let indexPath = self.tableView.indexPathForRow(at: touchPoint) {
                openPopUpVC(row: indexPath.row)
            }
        }
    }
    
    func openPopUpVC(row: Int){
        let popUpVC = UIStoryboard(name: "MusicScene", bundle: nil).instantiateViewController(withIdentifier: "PopUpVC") as! PopUpViewController
        self.addChildViewController(popUpVC)
        popUpVC.view.frame = self.view.frame
        self.view.addSubview(popUpVC.view)
        popUpVC.didMove(toParentViewController: self)
        
        let albumItems = allSongs[row].items
        let mediaFile = albumItems[0]
        let songData = createMusicData(mediaFile: mediaFile)
        popUpVC.setData(data: songData)
    }
    
    func getNowPlayingData() -> SongData{
        let mediaFile = musicPlayer?.nowPlayingItem
        let musicData = createMusicData(mediaFile: mediaFile!)
        return musicData
    }
    
    func createMusicData(mediaFile: MPMediaItem) -> SongData {
        let songTitle = mediaFile.title ?? ""
        let albumTitle = mediaFile.albumTitle ?? ""
        let artist = mediaFile.artist ?? ""
        let artwork = mediaFile.artwork?.image(at: CGSize(width: 43, height: 43)) ?? UIImage(named: "NoArtwork.jpeg")!
        let comments = mediaFile.comments ?? ""
        let genre = mediaFile.genre ?? ""
        let lyrics = mediaFile.lyrics ?? ""
        let length = mediaFile.playbackDuration
        let trackNumber = mediaFile.albumTrackNumber
        let ID = mediaFile.persistentID
        
        return SongData(image: artwork , songName: songTitle, artist: artist, album: albumTitle, length: length, genre: genre, trackNumber: trackNumber, lyrics: lyrics, comments: comments, ID: ID, mediaFile: mediaFile)
    }
    
    //func numberOfSections(in tableView: UITableView) -> Int {
    //    return numberOfAlbums()
    //}
    
    /*func printSongs(){
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
     }*/
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noOfSongs
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(indexPath.row * 43)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //print("indexpath.row", indexPath.row)
        let albumItems = allSongs[indexPath.row].items
        let cell = tableView.dequeueReusableCell(withIdentifier: "MusicPlayerCell", for: indexPath) as! SongCell
        
        let mediaFile = albumItems[0]
        
        let musicData = createMusicData(mediaFile: mediaFile)
        cell.setData(data: musicData)
        cell.selectionStyle = .gray
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let songItems = allSongs[indexPath.row].items
        setSong(song: songItems[0])
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //Player Functions
    func play(){
        //if musicPlayer?.playbackState == .stopped {
        //    return
        //}
        musicPlayer?.prepareToPlay()
        playPauseButton.image = UIImage(named: "pauseIcon.png")
        musicPlayer?.play()
        toolbarSongDisplay.text = musicPlayer?.nowPlayingItem?.title
    }
    
    func pauseSongs(){
        musicPlayer?.pause()
        playPauseButton.image = UIImage(named: "playIcon.png")
    }
    
    func stopPlaying(){
        musicPlayer?.stop()
        playPauseButton.image = UIImage(named: "playIcon.png")
    }
    
    
    func setQueue(queue: [MPMediaItem]){
        currentItem = queue[0]
        let collection = MPMediaItemCollection(items: queue)
        musicPlayer?.setQueue(with: collection)
    }
    
    func skipSong(){
        let currentState = musicPlayer?.playbackState
        if songQueue.isEmpty {
            stopPlaying()
        }
        musicPlayer?.skipToNextItem()
        if currentState == .playing {
            play()
        }
    }
    
    func replay() {
        // Function to specifically replay song from start
        musicPlayer?.skipToBeginning()
        play()
    }
    
    func playPrevious(){
        if songHistory.count > 0 {
            let lastPlayed = songHistory.pop()
            songQueue.insert(lastPlayed, at: 0)
            
            setQueue(queue: songQueue)
            play()
            //songChangedHandler()
        }
    }
    
    func setSong(song: MPMediaItem) {
        if let currentItem = currentItem {
            if songHistory.count == 0 || songHistory.peek() != currentItem {
                songHistory.push(currentItem)
            }
        }
        currentItem = song
        songQueue = [song]
        let collection = MPMediaItemCollection(items: songQueue)
        musicPlayer?.setQueue(with: collection)
        play()
        songQueue.remove(at: 0)
    }
    
    func hasSongChanged() -> Bool {
        if let nowPlayingSong = musicPlayer?.nowPlayingItem {
            if currentItem != nil {
                //print("current:  \(currentItem.title!) --> now: \(nowPlayingSong.title!)")
                if nowPlayingSong != currentItem {
                    songHistory.push(currentItem)
                    currentItem = nowPlayingSong
                    songQueue.remove(at: 0)
                    return true
                }
            }
        }
        return false
    }
    
    @objc func songChangedHandler(){
        print("Song Changed")
        if hasSongChanged() {
            if songQueue.isEmpty {
                stopPlaying()
            } else {
                play()
            }
        }
        printTitles(array: songQueue)
        printTitles(array: songHistory.returnData())
        
        /* Working code assuming songChangeHandler is only called a single time at the appropriate time
         if let currentSong = musicPlayer?.nowPlayingItem{
         songHistory.append(currentSong)
         }
         if songQueue.count < 1 {
         stopPlaying()
         } else {
         songQueue.remove(at: 0)
         }
         */
    }
    
    /*func numberOfArtists() -> Int {
     let allArtists = songQuery.get(songCategory: "Artist")
     return allArtists.count
     }
     
     func numberOfAlbums() -> Int {
     let allAlbums = songQuery.get(songCategory: "Album")
     return allAlbums.count
     }
     */
    
    func numberOfSongs() -> Int {
        return allSongs.count
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
}

*/

