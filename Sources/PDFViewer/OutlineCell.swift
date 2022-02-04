//
//  File.swift
//  
//
//  Created by Johan Nyman on 2022-02-04.
//

import UIKit

class OutlineCell: UITableViewCell {

    @IBOutlet weak var leftOffset: NSLayoutConstraint!
    @IBOutlet open weak var openButton: UIButton!
    @IBOutlet open weak var titleLabel: UILabel!
    @IBOutlet weak var pageLabel: UILabel!
    
    var openButtonClick:((_ sender: UIButton) -> Void)?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if indentationLevel == 0 {
            titleLabel.font = UIFont.systemFont(ofSize: 17)
        } else {
            titleLabel.font = UIFont.systemFont(ofSize: 15)
        }
        leftOffset.constant = CGFloat(indentationWidth * CGFloat(indentationLevel))
    }
    
    
    @IBAction func openButtonClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        openButtonClick?(sender)
    }
    
}
