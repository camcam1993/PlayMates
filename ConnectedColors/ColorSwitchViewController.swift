//
//  ViewController.swift
//  ConnectedColors
//
//  Created by Ralf Ebert on 28/04/15.
//  Copyright (c) 2015 Ralf Ebert. All rights reserved.
//

import UIKit
import AVFoundation

class ColorSwitchViewController: UIViewController {

    @IBOutlet weak var connectionsLabel: UILabel!
    var audioPlayer:AVAudioPlayer = AVAudioPlayer()

    let colorService = ColorServiceManager()
    
    @IBOutlet weak var tableviewSongs: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        colorService.delegate = self
    }

    @IBAction func redTapped(sender: AnyObject) {
        self.changeColor(UIColor.redColor())
        colorService.sendColor("red")
    }
    
    @IBAction func yellowTapped(sender: AnyObject) {
        self.changeColor(UIColor.yellowColor())
        colorService.sendColor("yellow")
    }
    
    func changeColor(color : UIColor) {
        UIView.animateWithDuration(0.2) {
            self.view.backgroundColor = color
        }
    }
    
}

extension ColorSwitchViewController : ColorServiceManagerDelegate {
    
    func connectedDevicesChanged(manager: ColorServiceManager, connectedDevices: [String]) {
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.connectionsLabel.text = "Connections: \(connectedDevices)"
        }
    }
    
    func colorChanged(manager: ColorServiceManager, colorString: String) {
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            switch colorString {
            case "red":
                self.changeColor(UIColor.redColor())
            case "yellow":
                self.changeColor(UIColor.yellowColor())
            default:
                NSLog("%@", "Unknown color value received: \(colorString)")
            }
        }
    }
    
    func playMusic() {
        let APP_DELEGAT = UIApplication.sharedApplication().delegate as! AppDelegate
        
        if(APP_DELEGAT.arrayOfUrls?.count > 0){
            tableviewSongs.reloadData()
        }
        
        let urlOfMusic : NSURL = (APP_DELEGAT.arrayOfUrls?.firstObject)! as! NSURL
        
        do{
            audioPlayer = try AVAudioPlayer(contentsOfURL: urlOfMusic)
            audioPlayer.prepareToPlay()
            audioPlayer.volume = 1.0
            audioPlayer.play()
        }catch{
            print("error: \(error)")
        }
    }
    
    //MARK: table view
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let APP_DELEGAT = UIApplication.sharedApplication().delegate as! AppDelegate
        return (APP_DELEGAT.arrayOfUrls?.count)!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var preferenceCell : UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("Customcell")
        if preferenceCell == nil {
            
            preferenceCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Customcell")
        }
        
        let APP_DELEGAT = UIApplication.sharedApplication().delegate as! AppDelegate
        let urlOfSong:NSURL = (APP_DELEGAT.arrayOfUrls?.objectAtIndex(indexPath.row))! as! NSURL
        preferenceCell?.textLabel!.text = urlOfSong.absoluteString
        return preferenceCell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let APP_DELEGAT = UIApplication.sharedApplication().delegate as! AppDelegate
        let urlOfMusic : NSURL = (APP_DELEGAT.arrayOfUrls?.objectAtIndex(indexPath.row))! as! NSURL
        
        do{
            audioPlayer = try AVAudioPlayer(contentsOfURL: urlOfMusic)
            audioPlayer.prepareToPlay()
            audioPlayer.volume = 1.0
            audioPlayer.play()
        }catch{
            print("error: \(error)")
        }
    }
}