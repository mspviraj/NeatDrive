//
//  CloudDriveViewController.swift
//  NeatDrive
//
//  Created by Nelson on 1/3/17.
//  Copyright © 2017 Nelson. All rights reserved.
//

import Foundation
import UIKit

struct CloudItem {
    
    let itemTitle : String
    let itemType : CloudDriveType
}

class CloudServiceViewController : SlidableViewController, UITableViewDataSource, UITableViewDelegate{
    
    var cloudItems : [CloudItem]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Cloud Services"
        
        self.setupCloudItems()
    }
    
    private func setupCloudItems(){
        
        if self.cloudItems != nil{
            
            self.cloudItems?.removeAll()
        }
        
        if self.cloudItems == nil{
            
            self.cloudItems = Array<CloudItem>()
        }
        
        self.cloudItems?.append(CloudItem(itemTitle: "DropBox", itemType: .DropBox))
        self.cloudItems?.append(CloudItem(itemTitle: "Google Drive", itemType: .GoogleDrive))
    }
    
    
    //MARK: table srouce delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return (self.cloudItems?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellId = "CloudItem"
        
        let item = self.cloudItems?[indexPath.row]
        
        var cell : CloudItemCell? = tableView.dequeueReusableCell(withIdentifier: cellId) as? CloudItemCell
        
        if cell == nil{
            
            cell = CloudItemCell()
        }
        
        cell?.titleLabel?.text = item?.itemTitle
        
        return cell!
    }
    
    //MARK: table delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = self.cloudItems?[indexPath.row]
        
        self.performSegue(withIdentifier: "ShowCloudFile", sender: item?.itemType)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let controller = segue.destination as! CloudFileViewController
        controller.driveType = sender as! CloudDriveType?
        
    }
}
