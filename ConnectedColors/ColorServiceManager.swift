//
//  ColorServiceManager.swift
//  ConnectedColors


import Foundation
import MultipeerConnectivity
import MediaPlayer


protocol ColorServiceManagerDelegate {
    
    func connectedDevicesChanged(manager : ColorServiceManager, connectedDevices: [String])
    func colorChanged(manager : ColorServiceManager, colorString: String)
    func playMusic()
}

class ColorServiceManager : NSObject {
    
    private let ColorServiceType = "example-color"
    private let myPeerId = MCPeerID(displayName: UIDevice.currentDevice().name)
    private let serviceAdvertiser : MCNearbyServiceAdvertiser
    private let serviceBrowser : MCNearbyServiceBrowser
    var delegate : ColorServiceManagerDelegate?
    
    override init() {
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: ColorServiceType)

        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: ColorServiceType)

        super.init()
        
        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()
        
        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
    }
    
    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }
    
    lazy var session: MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.Required)
        session.delegate = self
        return session
    }()

    func myDocumentsDirectory() -> NSString{
        return NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
    }

    func sendMp3(mediaItem : MPMediaItem)  {
        if session.connectedPeers.count > 0 {
            let APP_DELEGAT = UIApplication.sharedApplication().delegate as! AppDelegate
            APP_DELEGAT.showHud()
            do {
                //export the native song with proper url
                let assetURL = mediaItem.valueForProperty(MPMediaItemPropertyAssetURL) as! NSURL
                let songAsset : AVURLAsset = AVURLAsset(URL: assetURL, options: nil)
                let exporter : AVAssetExportSession = AVAssetExportSession(asset: songAsset, presetName: AVAssetExportPresetAppleM4A)!
                exporter.outputFileType = "com.apple.m4a-audio";
                let ss = myDocumentsDirectory()
                let dd = NSURL(fileURLWithPath: ss as String)
                let exportFileUrl = dd.URLByAppendingPathComponent("\(mediaItem.title).m4a")
                

//                ss.stringb
                
//                let exportFile = [myDocumentsDirectory() stringByAppendingPathComponent: @"exported.m4a"];

//                let exportFile : NSString = self.getDocumentDirectoryUrlDUMMY(mediaItem.title!)
//                let exportURL : NSURL = NSURL(fileURLWithPath: exportFile as String)
                exporter.outputURL = exportFileUrl;
                //    myDeleteFile(exportFile);
///***
                exporter.exportAsynchronouslyWithCompletionHandler({ 
                    let exportStatus = exporter.status
                    switch(exportStatus){
                    case .Completed:
                        let audioUrl = exportFileUrl;
                        self.session.sendResourceAtURL(audioUrl, withName: mediaItem.title!, toPeer: self.session.connectedPeers.first!, withCompletionHandler: { (error) in
                                print("error at sending: \(error)")
                            })
                        break
                    default:
                        break
                    }
                })
            }
        }
        
    }
    
    func sendColor(colorName : String) {//pkc1
        NSLog("%@", "sendColor: \(colorName)")
        
        if session.connectedPeers.count > 0 {
            var error : NSError?
            do {
                //**Z
                let fileURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("TheNights", ofType: "m4r")!)
                self.session.sendResourceAtURL(fileURL, withName: "TheNights", toPeer: session.connectedPeers.first!, withCompletionHandler: { (error) in
                    print("yo error:- \(error)")
                    let APP_DELEGAT = UIApplication.sharedApplication().delegate as! AppDelegate
                    APP_DELEGAT.HideHud()
                })
                
                //***
                try self.session.sendData(colorName.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, toPeers: session.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
            } catch let error as NSError {
                NSLog("test:-%@", "\(error)")
            }
        }

    }
    
    
}

extension ColorServiceManager : MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError) {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: ((Bool, MCSession) -> Void)) {
        
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        invitationHandler(true, self.session)
    }

}

extension ColorServiceManager : MCNearbyServiceBrowserDelegate {
    
    func browser(browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: NSError) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }
    
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        NSLog("%@", "foundPeer: \(peerID)")
        NSLog("%@", "invitePeer: \(peerID)")
        browser.invitePeer(peerID, toSession: self.session, withContext: nil, timeout: 10)
    }
    
    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "lostPeer: \(peerID)")
    }
    
}

extension MCSessionState {
    
    func stringValue() -> String {
        switch(self) {
        case .NotConnected: return "NotConnected"
        case .Connecting: return "Connecting"
        case .Connected: return "Connected"
        default: return "Unknown"
        }
    }
    
}

extension ColorServiceManager : MCSessionDelegate {
    
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        NSLog("%@", "peer \(peerID) didChangeState: \(state.stringValue())")
        self.delegate?.connectedDevicesChanged(self, connectedDevices: session.connectedPeers.map({$0.displayName}))
    }
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        //pkc2
        NSLog("%@", "didReceiveData: \(data.length) bytes")
        let str = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
        self.delegate?.colorChanged(self, colorString: str)
    }
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveStream")
    }
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        let APP_DELEGAT = UIApplication.sharedApplication().delegate as! AppDelegate
        APP_DELEGAT.HideHud()
        
        do{
            let urlOfMusicFile = self.getDocumentDirectoryUrl(resourceName)
            try NSFileManager.defaultManager().copyItemAtURL(localURL, toURL: urlOfMusicFile)
            let APP_DELEGAT = UIApplication.sharedApplication().delegate as! AppDelegate
            APP_DELEGAT.arrayOfUrls?.addObject(urlOfMusicFile)
            self.delegate?.playMusic()
        }catch{
            print("error yeah: \(error)")
        }

        
        NSLog("%@", "didFinishReceivingResourceWithName")
        print("localURL:- \(localURL)")
    }
    
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        let APP_DELEGAT = UIApplication.sharedApplication().delegate as! AppDelegate
        APP_DELEGAT.showHud()
        NSLog("%@", "didStartReceivingResourceWithName")
    }
  
    //MARK:-
    func getDocumentDirectoryUrl(musicFileName: String) -> NSURL{
        let fileManager = NSFileManager.defaultManager()
        let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let documentDirectory:NSURL = urls.first!
        
        let finalDatabaseURL = documentDirectory.URLByAppendingPathComponent("\(musicFileName).m4a")
        return finalDatabaseURL
    }
    
    func getDocumentDirectoryUrlDUMMY(musicFileName: String) -> String{
        let fileManager = NSFileManager.defaultManager()
        let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let documentDirectory:NSURL = urls.first!
        
        let finalDatabaseURL = documentDirectory.URLByAppendingPathComponent("\(musicFileName).m4a")
        return finalDatabaseURL.absoluteString
    }
}
