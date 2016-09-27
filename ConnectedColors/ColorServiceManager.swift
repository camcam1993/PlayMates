//
//  ColorServiceManager.swift
//  ConnectedColors


import Foundation
import MultipeerConnectivity
import MediaPlayer


protocol ColorServiceManagerDelegate {
    
    func connectedDevicesChanged(_ manager : ColorServiceManager, connectedDevices: [String])
    func colorChanged(_ manager : ColorServiceManager, colorString: String)
    func playMusic()
}

class ColorServiceManager : NSObject {
    
    fileprivate let ColorServiceType = "example-color"
    fileprivate let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    fileprivate let serviceAdvertiser : MCNearbyServiceAdvertiser
    fileprivate let serviceBrowser : MCNearbyServiceBrowser
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
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.required)
        session.delegate = self
        return session
    }()

    func myDocumentsDirectory() -> NSString{
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
    }

    func myDeleteFile (_ path : String){
        if FileManager.default.fileExists(atPath: path) {
            do{
                try FileManager.default.removeItem(atPath: path)
            }catch{
                print("Error while deleting file \(error)")
            }
            
        }
    }

    func sendMp3(_ mediaItem : MPMediaItem)  {
        if session.connectedPeers.count > 0 {
            let APP_DELEGAT = UIApplication.shared.delegate as! AppDelegate
            APP_DELEGAT.showHud()
            do {
                //export the native song with proper url
                let assetURL = mediaItem.value(forProperty: MPMediaItemPropertyAssetURL) as! URL
                let songAsset : AVURLAsset = AVURLAsset(url: assetURL, options: nil)
                let exporter : AVAssetExportSession = AVAssetExportSession(asset: songAsset, presetName: AVAssetExportPresetAppleM4A)!
                exporter.outputFileType = "com.apple.m4a-audio";
                let ss = myDocumentsDirectory()
                let dd = URL(fileURLWithPath: ss as String)
                let exportFileUrl = dd.appendingPathComponent("\(mediaItem.title).m4a")
                print("exporting")

                exporter.outputURL = exportFileUrl;
                myDeleteFile(exportFileUrl.absoluteString);

                exporter.exportAsynchronously(completionHandler: { 
                    let exportStatus = exporter.status
                    switch(exportStatus){
                    case .completed:
                        print("exporting complete")
                        let audioUrl : URL = exportFileUrl as URL
                        print("sending resource named:-\(mediaItem.title)")
                        
                        DispatchQueue.main.async {
                            if(self.session.connectedPeers.count > 0){
                                self.showNearByOfferPopup(arrayOfConnectedDevice: self.session.connectedPeers, urlOfAudio: audioUrl, nameOfSong: mediaItem.title!)
                            }else{
                                APP_DELEGAT.HideHud()
                            }
                        }
                                                
                        //pkc
                        break
                    default:
                        print("exporting failed")
                        APP_DELEGAT.HideHud()
                        break
                    }
                })
            }
        }
    }
    
    func showNearByOfferPopup(arrayOfConnectedDevice : [MCPeerID], urlOfAudio : URL, nameOfSong : String)
    {
        let APP_DELEGAT = UIApplication.shared.delegate as! AppDelegate
        let window = APP_DELEGAT.window
        let nearByOfferViewObject = NearByOffer(frame: (window!.frame))
        nearByOfferViewObject.arrayOffers = arrayOfConnectedDevice
        
        nearByOfferViewObject.handler_OfferActionFromView = { (selectedOffer: MCPeerID) -> Void in
            self.sendResource(urlOfAudio: urlOfAudio, nameOfSong: nameOfSong, peerID: selectedOffer)
        }
        window!.addSubview(nearByOfferViewObject)
    }
    
    
    func sendResource(urlOfAudio : URL, nameOfSong : String, peerID : MCPeerID){
        self.session.sendResource(at: urlOfAudio, withName: nameOfSong, toPeer: peerID, withCompletionHandler: { (error) in
            print("error at sending: \(error)")
        })
    }
    
    func sendColor(_ colorName : String) {//pkc1
        NSLog("%@", "sendColor: \(colorName)")
        
        if session.connectedPeers.count > 0 {
            do {
                //**Z
                let fileURL = URL(fileURLWithPath: Bundle.main.path(forResource: "TheNights", ofType: "m4r")!)
                self.session.sendResource(at: fileURL, withName: "TheNights", toPeer: session.connectedPeers.first!, withCompletionHandler: { (error) in
                    print("yo error:- \(error)")
                    let APP_DELEGAT = UIApplication.shared.delegate as! AppDelegate
                    APP_DELEGAT.HideHud()
                })
                
                //***
                try self.session.send(colorName.data(using: String.Encoding.utf8, allowLossyConversion: false)!, toPeers: session.connectedPeers, with: MCSessionSendDataMode.reliable)
            } catch let error as NSError {
                NSLog("test:-%@", "\(error)")
            }
        }

    }
    
}

extension ColorServiceManager : MCNearbyServiceAdvertiserDelegate {
    @available(iOS 7.0, *)
    public func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        //pkc swift3
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        invitationHandler(true, self.session)
    }

    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }
    
    /*
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: (@escaping (Bool, MCSession) -> Void)) {
        
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        invitationHandler(true, self.session)
    }
    */

}

extension ColorServiceManager : MCNearbyServiceBrowserDelegate {
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        NSLog("%@", "foundPeer: \(peerID)")
        NSLog("%@", "invitePeer: \(peerID)")
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "lostPeer: \(peerID)")
    }
    
}

extension MCSessionState {
    
    func stringValue() -> String {
        switch(self) {
        case .notConnected: return "NotConnected"
        case .connecting: return "Connecting"
        case .connected: return "Connected"
        default: return "Unknown"
        }
    }
    
}

extension ColorServiceManager : MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        NSLog("%@", "peer \(peerID) didChangeState: \(state.stringValue())")
        self.delegate?.connectedDevicesChanged(self, connectedDevices: session.connectedPeers.map({$0.displayName}))
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        //pkc2
        NSLog("%@", "didReceiveData: \(data.count) bytes")
        let str = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as! String
        self.delegate?.colorChanged(self, colorString: str)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveStream")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
        let APP_DELEGAT = UIApplication.shared.delegate as! AppDelegate
        APP_DELEGAT.HideHud()
        
        do{
            let urlOfMusicFile = self.getDocumentDirectoryUrl(resourceName)
            try FileManager.default.copyItem(at: localURL, to: urlOfMusicFile)
            let APP_DELEGAT = UIApplication.shared.delegate as! AppDelegate
            //key = name of song
            //value = url of song
            APP_DELEGAT.arrayOfUrls?.add([resourceName:urlOfMusicFile])
            
            self.delegate?.playMusic()
        }catch{
            print("error yeah: \(error)")
        }

        
        NSLog("%@", "didFinishReceivingResourceWithName")
        print("localURL:- \(localURL)")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        let APP_DELEGAT = UIApplication.shared.delegate as! AppDelegate
        APP_DELEGAT.showHud()
        NSLog("%@", "didStartReceivingResourceWithName")
    }
  
    //MARK:-
    func getDocumentDirectoryUrl(_ musicFileName: String) -> URL{
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory:URL = urls.first!
        
        let finalDatabaseURL = documentDirectory.appendingPathComponent("\(musicFileName).m4a")
        return finalDatabaseURL
    }
    
    func getDocumentDirectoryUrlDUMMY(_ musicFileName: String) -> String{
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory:URL = urls.first!
        
        let finalDatabaseURL = documentDirectory.appendingPathComponent("\(musicFileName).m4a")
        return finalDatabaseURL.absoluteString
    }
    
}
