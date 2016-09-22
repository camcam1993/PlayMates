//
//  Utility.swift
//
//  Created by Pardeep Chaudhary.
//  Copyright © 2016 Pardeep Chaudhary. All rights reserved.
//

import UIKit

class Utility: NSObject {
    
    static var activityBaseView:UIView=UIView()
    
    static func showLoader(_ text : String) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        activityBaseView.frame=(appDelegate.window?.frame)!
        activityBaseView.backgroundColor=UIColor.white
        activityBaseView.alpha=0.6;        
        
        let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
        activityIndicator.center = activityBaseView.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        activityBaseView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        let rect = CGRect(x: 0, y: activityIndicator.frame.origin.y+25, width: (appDelegate.window?.frame.size.width)!, height: 21)
        let labelLoading = UILabel(frame: rect)
        labelLoading.textAlignment = .center
        labelLoading.text = text
        activityBaseView.addSubview(labelLoading)

        appDelegate.window?.addSubview(activityBaseView)
    }
    
    static func hideLoader()
    {
        activityBaseView.removeFromSuperview()
    }
    
    
    //MARK: - Alert View
//    static func showAlertWithTitle(title: String?, message: String!)
//    {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
//        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action) -> Void in
//        }))
//        
//        APP_DELEGATE.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
//    }
    
    //MARK: - NSUserdefault utility
    static func saveValueInUserDefault(_ value : AnyObject?,forkey:String!)
    {
        UserDefaults.standard.set(value, forKey: forkey)
        UserDefaults.standard.synchronize()
    }
    
    static func getValueFromUserDefaultForKey(_ key:String!) -> AnyObject?
    {
        let value : AnyObject? =  UserDefaults.standard.object(forKey: key) as AnyObject?
        return value
    }
    
}
