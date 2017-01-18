//
//  FileCell.swift
//  NeatDrive
//
//  Created by Nelson on 1/9/17.
//  Copyright © 2017 Nelson. All rights reserved.
//

import Foundation
import UIKit

class FileCell : UITableViewCell{
    
    @IBOutlet weak var iconImage : UIImageView?
    @IBOutlet weak var titleLabel : UILabel?
    @IBOutlet weak var subtitleLabel : UILabel?
    @IBOutlet weak var selectMark : CircleView?
    @IBOutlet weak var leftConstraint : NSLayoutConstraint?
    
    var isEdit = false{
        
        didSet{
            
            self.setNeedsLayout()
        }
    }
    
    var isSelect : Bool = false{
        
        didSet{
            
            self.setNeedsLayout()
            
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.contentView.layoutIfNeeded()
        
        if isEdit{
            
            self.leftConstraint?.constant = 0
            
            self.selectMark?.isSelect = self.isSelect
            
        }
        else{
            
            self.leftConstraint?.constant =  -(self.selectMark?.bounds.width)! - 8
            self.layoutIfNeeded()
        }
    }
    
    override func prepareForReuse() {
        
        self.selectMark?.isSelect = false
        self.isEdit = false
    }
}
