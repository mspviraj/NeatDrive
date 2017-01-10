//
//  LocalFilesViewController.swift
//  NeatDrive
//
//  Created by Nelson on 12/30/16.
//  Copyright © 2016 Nelson. All rights reserved.
//

import Foundation
import UIKit

class LocalFilesViewController : SlidableViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var tableView : UITableView?
    
    var data : [[LocalFileMetadata]]? {
        
        didSet{
            
            self.tableView?.reloadData()
        }
    }
    
    var backbutton : UIBarButtonItem?
    
    var atRoot : Bool = true {
        
        didSet{
            
            if atRoot{
                
                self.removeLastLeftButton()
            }
            else {
                
                if self.backbutton == nil{
                    
                    self.backbutton = UIBarButtonItem(title: "<-", style: .plain, target: self, action: #selector(LocalFilesViewController.onBackToParent))
                }
                
                self.addLeftButton(button: self.backbutton!)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "All Files"
        
        LocalFileManager.shareInstance.onCurrentPathChanged = { isRoot in
        
            self.atRoot = isRoot
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        LocalFileManager.shareInstance.contentsInPath(path: LocalFileManager.shareInstance.currentPathString, complete: { result in
            
            self.processData(result: result)
        })
        
        //we refresh back button
        if atRoot{
            
            self.atRoot = true
        }
        else {
            
            self.atRoot = false
        }
    }
    
    func processData(result:[LocalFileMetadata]){
        
        if result.count > 0{
            
            var dataSet : [[LocalFileMetadata]] = Array()
            var folderGroup : [LocalFileMetadata] = Array<LocalFileMetadata>()
            var fileGroup : [LocalFileMetadata] = Array<LocalFileMetadata>()
            
            for aData in result{
                
                if aData.IsFolder{
                    
                    folderGroup.append(aData)
                }
                else {
                    
                    fileGroup.append(aData)
                }
            }
            
            if folderGroup.count > 0{
                
                dataSet.append(folderGroup)
            }
            
            if fileGroup.count > 0{
                
                dataSet.append(fileGroup)
            }
            
            self.data = dataSet
        }
        else{
            
            self.data = nil
        }
    }
    
    func onBackToParent(){
        
        LocalFileManager.shareInstance.backToParent { result in
            
            self.processData(result: result)
        }
    }
    
    //MARK:table data source
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.data != nil ? (self.data?.count)! : 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.data != nil ? self.data![section].count : 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let item = self.data?[section][0]
        
        return (item?.IsFolder)! ? "Folders" : "Files"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellId = "FileCell"
        
        let item : LocalFileMetadata = (self.data?[indexPath.section][indexPath.row])!
        
        var cell : FileCell? = tableView.dequeueReusableCell(withIdentifier: cellId) as? FileCell
        
        if cell == nil{
            
            cell = FileCell()
        }
        
        cell?.titleLabel?.text = item.FileName
        
        if item.IsFolder{
            cell?.subtitleLabel?.text = ""
        }
        else{
            
            cell?.subtitleLabel?.text = "File size : \(item.FileSizeString)"
        }
        
        
        return cell!
    }
    
    //MARK:table delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item : LocalFileMetadata = self.data![indexPath.section][indexPath.row]
        
        if item.IsFolder{
            
            LocalFileManager.shareInstance.contentsInPath(path: item.FilePath, complete: { result in
                
                self.processData(result: result)
            })
        }
    }
}
