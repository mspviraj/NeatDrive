//
//  MenuViewController.swift
//  NeatDrive
//
//  Created by Nelson on 12/30/16.
//  Copyright © 2016 Nelson. All rights reserved.
//

import Foundation
import UIKit

struct MenuItem {
    
    let iconImageName : String
    let itemTitle : String
    let storyboardID : String
    
    func viewControllerFromStoryboard() -> UIViewController{
        
        assert(self.storyboardID != "", "No storyboard id")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: self.storyboardID)
        
        return controller
    }
}

class MenuViewController : UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    private var menuItems : [MenuItem]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupMenuItems()
    }
    
    private func setupMenuItems(){
        
        if self.menuItems != nil{
            
            self.menuItems?.removeAll()
        }
        
        if self.menuItems == nil{
            
            self.menuItems = Array<MenuItem>()
        }
        
        self.menuItems?.append(MenuItem(iconImageName: "SideMenu-AllFiles", itemTitle: "All Files", storyboardID: "LocalFilesNavVC"))
        self.menuItems?.append(MenuItem(iconImageName: "SideMenu-CloudService", itemTitle: "Cloud Services", storyboardID: "CloudServiceNavVC"))
        self.menuItems?.append(MenuItem(iconImageName: "SideMenu-FileShare", itemTitle: "File share", storyboardID: "FileShareNavVC"))
        self.menuItems?.append(MenuItem(iconImageName: "SideMenu-Passcode", itemTitle: "Passcode", storyboardID: "PasscodeNavVC"))
        self.menuItems?.append(MenuItem(iconImageName: "SideMenu-StorageStatus", itemTitle: "Storage Status", storyboardID: "StorageStatusNavVC"))
    }
    
    //MARK:talbe data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return (self.menuItems?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellId = "MenuItem"
        
        let item : MenuItem = (self.menuItems?[indexPath.row])!
        
        var cell : MenuItemCell? = tableView.dequeueReusableCell(withIdentifier: cellId) as? MenuItemCell
        
        if cell == nil{
            
            cell = MenuItemCell()
        }
        
        cell?.titleLabel?.text = item.itemTitle
        cell?.imageIconView?.image = UIImage(named: item.iconImageName)
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 68
    }
    
    //MARK:table delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item : MenuItem = (self.menuItems?[indexPath.row])!
        
        let controller  = item.viewControllerFromStoryboard()
        
        self.slidingViewController().topViewController = controller
        
        self.slidingViewController().resetTopView(animated: true)
    }
}
