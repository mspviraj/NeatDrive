//
//  WifiFirstSlide.swift
//  NeatDrive
//
//  Created by Nelson on 1/6/17.
//  Copyright © 2017 Nelson. All rights reserved.
//

import Foundation
import UIKit

class WifiFirstSlide : NavSlideViewController{
    
    @IBOutlet weak var addressTextField : UITextField?
    @IBOutlet weak var switcher : UISwitch?
    @IBOutlet weak var wifiStatusLabel : UILabel?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        
        self.updateUI()
        
        self.switcher?.removeTarget(self, action: #selector(WifiFirstSlide.wifiOnOff(switcher:)), for: .valueChanged)
        self.switcher?.addTarget(self, action: #selector(WifiFirstSlide.wifiOnOff(switcher:)), for: .valueChanged)
        
        
    }
    
    func updateUI(){
        
        self.switcher?.isOn = HttpFileTransferManager.sharedManager().isServerRunning
        
        if HttpFileTransferManager.sharedManager().isServerRunning{
            
            let url = HttpFileTransferManager.sharedManager().serverURL
            self.addressTextField?.text = url?.absoluteString
            
            self.wifiStatusLabel?.text = "Wifi is on"
        }
        else{
            
            self.addressTextField?.text = ""
            self.wifiStatusLabel?.text = "Wifi is off"
        }
    }
    
    @IBAction func wifiOnOff(switcher : UISwitch){
        
        if switcher.isOn{
            
            _ = HttpFileTransferManager.sharedManager().start()
        }
        else {
            
            HttpFileTransferManager.sharedManager().stop()
        }
        
        self.updateUI()
    }
}
