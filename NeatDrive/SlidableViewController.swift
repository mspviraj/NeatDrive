//
//  SlidableViewController.swift
//  NeatDrive
//
//  Created by Nelson on 12/30/16.
//  Copyright © 2016 Nelson. All rights reserved.
//

import Foundation
import UIKit
import ECSlidingViewController

class SlidableViewController : UIViewController{
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.setupLeftMenuButton()
        
        //handle pan tap gesture
        self.slidingViewController().topViewAnchoredGesture = [.panning, .tapping]
        
        self.enablePanGesture()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        self.disablePanGesture()
    }
    
    func enablePanGesture(){
        
        self.navigationController?.view.removeGestureRecognizer(self.slidingViewController().panGesture)
        self.navigationController?.view.addGestureRecognizer(self.slidingViewController().panGesture)
    }
    
    func disablePanGesture(){
        
        self.navigationController?.view.removeGestureRecognizer(self.slidingViewController().panGesture)
    }
    
    func onLeftMenuButtonTapped(button:UIBarButtonItem){
        
        self.slidingViewController().anchorTopViewToRight(animated: true)
    }
    
    private func setupLeftMenuButton(){
        
        //let leftMenuBtn = UIBarButtonItem(title: "Menu", style: .plain, target: self, action: #selector(SlidableViewController.onLeftMenuButtonTapped(button:)))
        
        let leftMenuBtn = UIBarButtonItem(image: UIImage(named: "Icon-Menu"), style: .plain, target: self, action: #selector(SlidableViewController.onLeftMenuButtonTapped(button:)))
        
        self.navigationItem.leftBarButtonItems = [leftMenuBtn]
    }
    
    func addLeftButton(button:UIBarButtonItem){
        
        if self.navigationItem.leftBarButtonItems == nil{
        
            self.navigationItem.leftBarButtonItems = Array<UIBarButtonItem>()
        }
        
        if (self.navigationItem.leftBarButtonItems?.contains(button))!{
            return
        }
        
        self.navigationItem.leftBarButtonItems?.append(button)
    }
    
    func removeLastLeftButton(){
        
        if self.navigationItem.leftBarButtonItems == nil{
            
            return
        }
        
        if (self.navigationItem.leftBarButtonItems?.count)! <= 1{
            return
        }
        
        self.navigationItem.leftBarButtonItems?.removeLast()
    }
    
    func addRightButton(button:UIBarButtonItem){
        
        if self.navigationItem.rightBarButtonItems == nil{
            
            self.navigationItem.rightBarButtonItems = Array<UIBarButtonItem>()
        }
        
        if (self.navigationItem.rightBarButtonItems?.contains(button))!{
            
            return
        }
        
        self.navigationItem.rightBarButtonItems?.append(button)
    }
    
    func removeLastRightButton(){
        
        if self.navigationItem.rightBarButtonItems == nil{
            
            return
        }
        
        if self.navigationItem.rightBarButtonItems != nil && (self.navigationItem.rightBarButtonItems?.count)! > 0{
            
            self.navigationItem.rightBarButtonItems?.removeLast()
        }
    }
}
