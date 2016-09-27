//
//  NearByOfferTableViewCell.swift
//  HungerMafia
//
//  Created by Pardeep Kumar Chaudhary on 25/02/16.
//  Copyright © 2016 neha.bansal. All rights reserved.
//

import UIKit

typealias blockDefination_buttonNearByOfferAction = () -> Void

class NearByOfferTableViewCell: UITableViewCell {

    var handler_ButtonNearByOfferAction:blockDefination_buttonNearByOfferAction?

    @IBOutlet weak var textViewNearByOffer: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCellWithData(model : AnyObject)
    {
        textViewNearByOffer.text = "YO"
        
    }

    
    @IBAction func btnBuyNearByOfferAction(sender: UIButton)
    {
//        if(self.responds(to: #selector(handler_ButtonNearByOfferAction)){
            self.handler_ButtonNearByOfferAction?()
//        }
    }
    
}
