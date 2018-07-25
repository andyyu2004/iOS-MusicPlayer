//
//  QueueViewController.swift
//  mp
//
//  Created by Andy Yu on 3/07/18.
//  Copyright © 2018 Andy Yu. All rights reserved.
//

import UIKit
import MediaPlayer

//Play next in background works with second but not queue. locked works on both?
class QueueViewController: BaseMusicPlayerViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func closeVC(_ sender: Any) {
        closeAnimate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        configureSettings()
        
        showAnimate()
    }
    
    func configureSettings() {
        tableView.backgroundColor = UIColor.darkGray
        tableView.isEditing = true
        tableView.allowsSelectionDuringEditing = true
        tableView.separatorStyle = .none
        tableView.sectionIndexColor = UIColor.white
        tableView.sectionIndexBackgroundColor = UIColor.darkGray
        
        //tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: tableView.rowHeight*2, right: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func updateNowPlayingInfo() {
        super.updateNowPlayingInfo()
        tableView.reloadData()
    }

    // Player Functions
    
    @objc override func playNext() {
        super.playNext()
    }
    
    @objc override func setShuffleMode() {
        super.setShuffleMode()
        tableView.reloadData()
    }
    
    //Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4 //History, Current, Up Next, and Queue
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return mp.songHistory.count
        case 1:
            if mp.currentItem == nil {
                return 0
            } else {
                return 1
            }
        case 2:
            return mp.manualQueue.count
        default:
            return mp.autoQueue.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var mediaFile: MPMediaItem!
        switch indexPath.section {
        case 0:
            mediaFile = mp.songHistory[indexPath.row]
        case 1:
            mediaFile = mp.currentItem!
        case 2:
            mediaFile = mp.manualQueue[indexPath.row]
        default:
            mediaFile = mp.autoQueue[indexPath.row]
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "QueueCell", for: indexPath) as! SongCell
    
        let musicData = Utility.createSongData(mediaFile: mediaFile)
        cell.setData(data: musicData)
        cell.selectionStyle = .gray
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if indexPath.section == 3 {
            let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
                self.mp.autoQueue.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            return [delete]
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 0:
            mp.historyTapped(index: indexPath.row) // For song history tapped
        case 3: //Tapping on upnext not enabled, maybe enable?
            mp.queueTapped(indexPath: indexPath)
        default:
            break
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.none
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        switch indexPath.section {
        case 3: //2 as well if u want to switch manual queue
            return true
        default:
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedCell = mp.autoQueue.remove(at: sourceIndexPath.row)
        mp.autoQueue.insert(movedCell, at: destinationIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return mp.songHistory.count == 0 ? nil : "History"
        case 1:
            return mp.currentItem == nil ? nil : "Current"
        case 2:
            return mp.manualQueue.count == 0 ? nil : "Up Next"
        default:
            return mp.autoQueue.count == 0 ? nil : "Queue"
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.darkGray
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
    }
    
    func showAnimate(){
        self.view.transform = CGAffineTransform(scaleX: 1.3,y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: {self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    func closeAnimate(){
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        }, completion: {(finished: Bool) in
            if (finished) {
                self.view.removeFromSuperview()
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
