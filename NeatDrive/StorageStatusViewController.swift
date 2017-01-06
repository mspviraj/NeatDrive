//
//  StorageStatusViewController.swift
//  NeatDrive
//
//  Created by Nelson on 1/3/17.
//  Copyright © 2017 Nelson. All rights reserved.
//

import Foundation
import UIKit
import UICircularProgressRing


class StorageStatusViewController : SlidableViewController{
    
    @IBOutlet weak var freeNumberLabel : UILabel?
    @IBOutlet weak var freeUnitLabel : UILabel?
    @IBOutlet weak var totalNumberLabel : UILabel?
    @IBOutlet weak var totalUnitLabel : UILabel?
    @IBOutlet weak var progressView : UICircularProgressRingView?
    
    var freeSpace : Int64?
    var totalSpace : Int64?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Storage Status"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let value = deviceRemainingFreeSpaceInBytes(){
            
            self.freeSpace = value
        }
        else {
            
            self.freeSpace = 0
        }
        
        if let value = deviceTotalSpaceInBytes(){
            
            self.totalSpace = value
        }
        else {
            
            self.totalSpace = 0
        }
        
        self.drawView()
    }
    
    private func drawView(){
    
        self.freeNumberLabel?.text = stringFromByte(byte: self.freeSpace, displayOptions: .Number)
        self.freeUnitLabel?.text = stringFromByte(byte: self.freeSpace, displayOptions: .Unit)
        
        self.totalNumberLabel?.text = stringFromByte(byte: self.totalSpace, displayOptions: .Number)
        self.totalUnitLabel?.text = stringFromByte(byte: self.totalSpace, displayOptions: .Unit)
        
        var value : Int64 = Int64((Float(self.freeSpace!)/Float(self.totalSpace!)).multiplied(by: 100.0))
        
        if value >= Int64((self.progressView?.maxValue)!){
            
            value = Int64((self.progressView?.maxValue)!)
        }
        
        self.progressView?.value = CGFloat(value)
    }
}
