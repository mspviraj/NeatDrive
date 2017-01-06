//
//  PasscodeViewController.swift
//  NeatDrive
//
//  Created by Nelson on 1/4/17.
//  Copyright © 2017 Nelson. All rights reserved.
//

import Foundation
import UIKit
import LTHPasscodeViewController

class PasscodeViewController : SlidableViewController, LTHPasscodeViewControllerDelegate{
    
    @IBOutlet weak var onOffButton : UIButton?
    @IBOutlet weak var changeButton : UIButton?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LTHPasscodeViewController.sharedUser().delegate = self
        
        self.updateUI()
    }
    
    private func updateUI(){
    
        self.onOffButton?.removeTarget(self, action: #selector(PasscodeViewController.turnOnPasscode), for: .touchUpInside)
        self.onOffButton?.removeTarget(self, action: #selector(PasscodeViewController.turnOffPasscode), for: .touchUpInside)
        self.changeButton?.removeTarget(self, action: #selector(PasscodeViewController.changePasscode), for: .touchUpInside)
    
        if LTHPasscodeViewController.doesPasscodeExist(){
    
            self.onOffButton?.setTitle("Turn off", for: .normal)
            self.changeButton?.isEnabled = true
    
            self.onOffButton?.addTarget(self, action: #selector(PasscodeViewController.turnOffPasscode), for: .touchUpInside)
            self.changeButton?.addTarget(self, action: #selector(PasscodeViewController.changePasscode), for: .touchUpInside)
        }
        else {
    
            self.onOffButton?.setTitle("Turn on ", for: .normal)
            self.changeButton?.isEnabled = false
    
            self.onOffButton?.addTarget(self, action: #selector(PasscodeViewController.turnOnPasscode), for: .touchUpInside)
        }
    }
    
    @objc private func turnOffPasscode(){
        
        LTHPasscodeViewController.sharedUser().hidesCancelButton = false
        LTHPasscodeViewController.sharedUser().showForDisablingPasscode(in: self, asModal: true)
    }
    
    @objc private func turnOnPasscode(){
        
        LTHPasscodeViewController.sharedUser().hidesCancelButton = false
        LTHPasscodeViewController.sharedUser().showForEnablingPasscode(in: self, asModal: true)
    }
    
    @objc private func changePasscode(){
        
        LTHPasscodeViewController.sharedUser().hidesCancelButton = false
        LTHPasscodeViewController.sharedUser().showForChangingPasscode(in: self, asModal: true)
    }
    
    //MARK: LTHPasscodeViewController delegate
    func passcodeViewControllerWillClose() {
        
        self.updateUI()
    }
}
