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
    private var mediaItemCollection: MPMediaItemCollection?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        configureMusicNotification()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func configureMusicNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playMusic:", name: "didReceiveMusicNotification", object: nil)        
    }
    
    private func configureMediaPicker() {
        let mediaPickerController = MPMediaPickerController()
        mediaPickerController.delegate = self
        mediaPickerController.allowsPickingMultipleItems = false
        presentViewController(mediaPickerController, animated: true, completion: nil)
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
    
    @IBAction func didTouchSelectMusicButton(sender: UIButton) {
        configureMediaPicker()
    }
}
