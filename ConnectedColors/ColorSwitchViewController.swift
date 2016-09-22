//
//  ViewController.swift
//  ConnectedColors


import UIKit
import AVFoundation
import MediaPlayer
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class ColorSwitchViewController: UIViewController,MPMediaPickerControllerDelegate {

    @IBOutlet weak var connectionsLabel: UILabel!
    var audioPlayer:AVAudioPlayer = AVAudioPlayer()

    let colorService = ColorServiceManager()
    
    @IBOutlet weak var tableviewSongs: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        colorService.delegate = self
    }
    
    @IBAction func redTapped(_ sender: AnyObject) {
        self.changeColor(UIColor.red)
        colorService.sendColor("red")
    }
    
    @IBAction func yellowTapped(_ sender: AnyObject) {
        self.changeColor(UIColor.yellow)
        colorService.sendColor("yellow")
    }
    
    func changeColor(_ color : UIColor) {
        UIView.animate(withDuration: 0.2, animations: {
            self.view.backgroundColor = color
        }) 
    }
    
    //MARK: Action
    
    @IBAction func btnMediaPickerAction(_ sender: UIButton) {        
        let mediaPicker: MPMediaPickerController = MPMediaPickerController.self(mediaTypes:MPMediaType.music)
        mediaPicker.allowsPickingMultipleItems = false
        mediaPicker.delegate = self
        mediaPicker.allowsPickingMultipleItems = false
        self.present(mediaPicker, animated: true, completion: nil)
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        self.dismiss(animated: true, completion: nil)
//        print("you picked: \(mediaItemCollection)")
        let mediaItem :MPMediaItem = mediaItemCollection.items.first!
        colorService.sendMp3(mediaItem)
    }
    
}

extension ColorSwitchViewController : ColorServiceManagerDelegate {
    
    func connectedDevicesChanged(_ manager: ColorServiceManager, connectedDevices: [String]) {
        OperationQueue.main.addOperation { () -> Void in
            self.connectionsLabel.text = "Connections: \(connectedDevices)"
        }
    }
    
    func colorChanged(_ manager: ColorServiceManager, colorString: String) {
        OperationQueue.main.addOperation { () -> Void in
            switch colorString {
            case "red":
                self.changeColor(UIColor.red)
            case "yellow":
                self.changeColor(UIColor.yellow)
            default:
                NSLog("%@", "Unknown color value received: \(colorString)")
            }
        }
    }
    
    func playMusic() {
        let APP_DELEGAT = UIApplication.shared.delegate as! AppDelegate
        
        if(APP_DELEGAT.arrayOfUrls?.count > 0){
            OperationQueue.main.addOperation({ () -> Void in
                self.tableviewSongs.reloadData()

            })
        }
        
//        let urlOfMusic : NSURL = (APP_DELEGAT.arrayOfUrls?.firstObject)! as! NSURL
//        
//        do{
//            audioPlayer = try AVAudioPlayer(contentsOfURL: urlOfMusic)
//            audioPlayer.prepareToPlay()
//            audioPlayer.volume = 1.0
//            audioPlayer.play()
//        }catch{
//            print("error: \(error)")
//        }
    }
    
    //MARK: table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let APP_DELEGAT = UIApplication.shared.delegate as! AppDelegate
        return (APP_DELEGAT.arrayOfUrls?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        var preferenceCell : UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "Customcell")
        if preferenceCell == nil {
            
            preferenceCell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "Customcell")
        }
        
        let APP_DELEGAT = UIApplication.shared.delegate as! AppDelegate
        let dic = (APP_DELEGAT.arrayOfUrls?.object(at: (indexPath as NSIndexPath).row))! as! NSDictionary
        let urlOfSong :String = dic.allKeys.first as! String
//        let urlOfSong:NSURL = (APP_DELEGAT.arrayOfUrls?.objectAtIndex(indexPath.row))! as! NSURL
        preferenceCell?.textLabel!.text = urlOfSong
        return preferenceCell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        let APP_DELEGAT = UIApplication.shared.delegate as! AppDelegate
        
        let dic = (APP_DELEGAT.arrayOfUrls?.object(at: (indexPath as NSIndexPath).row))! as! NSDictionary
        let urlOfMusic : URL = dic.allValues.first as! URL
        
//        let urlOfMusic : NSURL = (APP_DELEGAT.arrayOfUrls?.objectAtIndex(indexPath.row))! as! NSURL
        
        do{
            audioPlayer = try AVAudioPlayer(contentsOf: urlOfMusic)
            audioPlayer.prepareToPlay()
            audioPlayer.volume = 1.0
            audioPlayer.play()
        }catch{
            print("error: \(error)")
        }
    }
}
