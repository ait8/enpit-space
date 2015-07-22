//
//  ViewController.swift
//  enpit-space
//
//  Created by Kengo Yokoyama on 2015/07/17.
//  Copyright (c) 2015年 Kengo Yokoyama. All rights reserved.
//

import UIKit
import MediaPlayer

class ViewController: UIViewController, MPMediaPickerControllerDelegate {

    @IBOutlet private weak var musicTitleLabel: UILabel!
    @IBOutlet private weak var teamLabel: UILabel!
    @IBOutlet private weak var keywordLabel: UILabel!
    
    private var mediaItemCollection: MPMediaItemCollection?
    private var centralManager = CentralManager.alloc()
    private var nexturnTimers: [NSTimer]?
    private let musicPlayer = MPMusicPlayerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        configureMusic()
        configureNexturn()
        
        configurePayloadNotification()
        configureNexturnNotification()
        configureMusicNotification()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func configurePayloadNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "parsePayload:", name: "didReceivePayloadNotification", object: nil)
    }
    
    private func configureMusicNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playMusic:", name: "didReceiveMusicNotification", object: nil)        
    }

    private func configureNexturnNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playNexturn:", name: "didReceiveNexturnNotification", object: nil)
    }
    
    private func configureMediaPicker() {
        let mediaPickerController = MPMediaPickerController()
        mediaPickerController.delegate = self
        mediaPickerController.allowsPickingMultipleItems = false
        presentViewController(mediaPickerController, animated: true, completion: nil)
    }
    
    private func configureMusic() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let mediaItemCollectionArchivedData = userDefaults.objectForKey("mediaItemCollectionArchivedData") as? NSData {
            let mediaItemCollection = NSKeyedUnarchiver.unarchiveObjectWithData(mediaItemCollectionArchivedData) as! MPMediaItemCollection
            let item = mediaItemCollection.representativeItem
            let title = item.valueForProperty(MPMediaItemPropertyTitle) as! String
            let artistName = item.valueForProperty(MPMediaItemPropertyArtist) as! String
            let albumName = item.valueForProperty(MPMediaItemPropertyAlbumTitle) as! String
            
            self.mediaItemCollection = mediaItemCollection
            musicTitleLabel.text = title
        }
    }
    
    private func configureNexturn() {
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        centralManager = CentralManager(delegate: self.centralManager, queue: queue, options: nil)
    }
    
    func mediaPickerDidCancel(mediaPicker: MPMediaPickerController!) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func mediaPicker(mediaPicker: MPMediaPickerController!, didPickMediaItems mediaItemCollection: MPMediaItemCollection!) {
        let item = mediaItemCollection.representativeItem
        
        let title = item.valueForProperty(MPMediaItemPropertyTitle) as! String
        let artistName = item.valueForProperty(MPMediaItemPropertyArtist) as! String
        let albumName = item.valueForProperty(MPMediaItemPropertyAlbumTitle) as! String
        
        musicTitleLabel.text = title
        self.mediaItemCollection = mediaItemCollection

        let userDefaults = NSUserDefaults.standardUserDefaults()
        let mediaItemCollectionArchivedData = NSKeyedArchiver.archivedDataWithRootObject(mediaItemCollection)
        userDefaults.setObject(mediaItemCollectionArchivedData, forKey: "mediaItemCollectionArchivedData")
        userDefaults.synchronize()
        
        dismissViewControllerAnimated(true, completion: nil)
    }

    func parsePayload(notification: NSNotification) {
        if let teamText = notification.userInfo!["team"] as? String {
            teamLabel.text = teamText
        }
        if let keywordText = notification.userInfo!["keyword"] as? String {
            keywordLabel.text = keywordText
        }
    }
    
    func playMusic(notification: NSNotification) {
        if let mediaItemCollection = mediaItemCollection {
            musicPlayer.setQueueWithItemCollection(mediaItemCollection)
            musicPlayer.stop()
            musicPlayer.play()
        }
    }

    func playNexturn(notification: NSNotification) {
        resumeNexturnTimer()
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        musicPlayer.stop()
        pauseNexturnTimer()
        centralManager.stop()
    }
    
    private func resumeNexturnTimer() {
        if nexturnTimers == nil {
            nexturnTimers = []
        }
        nexturnTimers?.append(NSTimer.scheduledTimerWithTimeInterval(2.0, target: centralManager, selector: Selector("play"), userInfo: nil, repeats: true))
    }
    
    private func pauseNexturnTimer() {
        if let nexturnTimers = nexturnTimers {
            for nexturnTimer in nexturnTimers {
                nexturnTimer.invalidate()
            }
        }
        nexturnTimers?.removeAll(keepCapacity: false)
        nexturnTimers = nil
    }
    
    @IBAction func didTouchSelectMusicButton(sender: UIButton) {
        configureMediaPicker()
    }
}
