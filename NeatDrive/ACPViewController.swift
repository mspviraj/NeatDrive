//
//  ACPViewController.swift
//  NeatDrive
//
//  Created by Nelson on 1/10/17.
//  Copyright © 2017 Nelson. All rights reserved.
//

import Foundation
import UIKit

protocol ACPViewControllerDelegate {
    
    func menuItems() -> Array<ACPItem>
    func selectItemAtIndex(selectedIndex: Int)
}

class ACPViewController : UIViewController, ACPScrollDelegate{
    
    static private var instance : ACPViewController?
    
    private let scrollMenu : ACPScrollMenu = ACPScrollMenu()
    private var delegate : ACPViewControllerDelegate?
    
    class func showMenu(_delegate:ACPViewControllerDelegate){
     
        if instance == nil{
            
            instance = ACPViewController()
            instance?.delegate = _delegate
            
            instance?.view.frame = (UIApplication.shared.windows[0].rootViewController?.view.bounds)!
        }
        
        
        UIApplication.shared.windows[0].rootViewController?.addChildViewController(ACPViewController.instance!)
        UIApplication.shared.windows[0].rootViewController?.view.addSubview((ACPViewController.instance?.view)!)
        ACPViewController.instance?.didMove(toParentViewController: UIApplication.shared.windows[0].rootViewController)
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.view.isUserInteractionEnabled = true
        self.view.backgroundColor = UIColor(displayP3Red: 0.0, green: 0.0, blue: 0.0, alpha: 0.2)
        
        let button = UIButton(frame: self.view.bounds)
        button.backgroundColor = UIColor.clear
        button.addTarget(self, action: #selector(ACPViewController.onGreyoutTap), for: .touchUpInside)
        self.view.addSubview(button)
        
        
        self.scrollMenu.backgroundColor = UIColor.white
        self.scrollMenu.delegate = self
        self.view.addSubview(self.scrollMenu)
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        let item : ACPItem = Bundle.main.loadNibNamed("ACPItem", owner: self, options: nil)?.last as! ACPItem
        
        let height = item.frame.height
        
        self.scrollMenu.frame = CGRect(x: 0, y: self.view.frame.height - (height+8), width: self.view.frame.width, height: height+8)
        
        self.scrollMenu.isUserInteractionEnabled = true
        self.scrollMenu.fixSizeEnable = true
        
        if self.delegate != nil{
            
            self.scrollMenu.setUp(self.delegate?.menuItems())
        }
    }
    
    private func dismiss(){
        
        if ACPViewController.instance != nil && ACPViewController.instance?.parent != nil{
            
            ACPViewController.instance?.willMove(toParentViewController: nil)
            ACPViewController.instance?.view.removeFromSuperview()
            ACPViewController.instance?.removeFromParentViewController()
            
            ACPViewController.instance = nil
        }
    }
    
    @objc private func onGreyoutTap(){
        
        dismiss()
    }
    
    //MARK:ACPScrollDelegate
    func scrollMenu(_ menu: ACPScrollMenu!, didSelect selectedIndex: Int) {
        
        if delegate != nil{
            
            delegate?.selectItemAtIndex(selectedIndex: selectedIndex)
        }
        
        self.dismiss()
    }
}
