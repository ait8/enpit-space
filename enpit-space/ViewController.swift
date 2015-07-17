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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        configureNexturn()
        
        configureNexturnNotification()
        configureMusicNotification()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func playMusic(notification: NSNotification) {
        if let mediaItemCollection = mediaItemCollection {
            let musicPlayer = MPMusicPlayerController()
            musicPlayer.setQueueWithItemCollection(mediaItemCollection)
            musicPlayer.play()
        }
    }

    func playNexturn(notification: NSNotification) {
        // FIXME: 点灯プログラムを変更する
        centralManager.ledButtonTapped(2)
    }
    
    @IBAction func didTouchSelectMusicButton(sender: UIButton) {
        configureMediaPicker()
    }
}
