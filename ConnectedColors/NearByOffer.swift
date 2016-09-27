//
//  NearByOffer.swift
//  HungerMafia
//
//  Created by Pardeep Kumar Chaudhary on 24/02/16.
//  Copyright © 2016 neha.bansal. All rights reserved.
//

import Foundation
import UIKit
import MultipeerConnectivity

typealias blockDefination_OfferActionFromView = (_ selectedOffer: MCPeerID) -> Void

class NearByOffer: UIView,UITableViewDataSource,UITableViewDelegate
{
    @IBOutlet weak var constraintHeightOfView: NSLayoutConstraint!
    var handler_OfferActionFromView:blockDefination_OfferActionFromView?

    @IBOutlet weak var tableViewNearbyOffer: UITableView!
    var view: UIView!
    var arrayOffers: [MCPeerID]?
    

    
    override init(frame: CGRect) {
        super.init(frame: frame)

        xibSetup()
        
        arrayOffers = [MCPeerID]()

        
//        self.setUI()
//        self.performSelector("setUI", withObject: nil, afterDelay: 0.00)
//        [self registerCustomTablecell];
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setUI(){
        
        UIView.animate(withDuration: Double(0.0), animations: {
            self.constraintHeightOfView.constant =  (CGFloat((self.arrayOffers?.count)!) * self.tableViewNearbyOffer.rowHeight) + 43.0
            self.view.layoutIfNeeded()
        })
    }
    

    func xibSetup() {
        view = loadViewFromNib()
        
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]        
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.75)
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "NearByOffer", bundle: bundle)
        
        // Assumes UIView is top level and only object in CustomView.xib file
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    @IBAction func tapGestureAction(sender: UITapGestureRecognizer) {
        self.removeFromSuperview()
    }
    
//    func reloadOfferTable(){
//        tableViewNearbyOffer.reloadData()
//    }
//    -(void)registerCustomTablecell{
//    [self.tableview_Address registerNib:[UINib nibWithNibName:NSStringFromClass([ShowroomTableViewCell class]) bundle:nil]
//    forCellReuseIdentifier:NSStringFromClass([ShowroomTableViewCell class])];
//    }

    
    // MARK: - Tableview datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOffers!.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "cellpkc")
        
        if cell == nil
        {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cellpkc")
        }
        
        let mcpeer = arrayOffers?[indexPath.row]
        cell?.textLabel?.text = mcpeer?.displayName
        
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mcpeer = arrayOffers?[indexPath.row]
        self.handler_OfferActionFromView?(mcpeer!)
        self.removeFromSuperview()
    }
    
    
}
