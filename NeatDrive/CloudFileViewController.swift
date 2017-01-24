//
//  CloudFileViewController.swift
//  NeatDrive
//
//  Created by Nelson on 1/3/17.
//  Copyright © 2017 Nelson. All rights reserved.
//

import Foundation
import UIKit
import BCGenieEffect

class CloudFileViewController : SlidableViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var tableView : UITableView?
    
    var backbutton : UIBarButtonItem?
    var downloadButton : UIBarButtonItem?
    
    var driveType : CloudDriveType?
    
    var atRoot : Bool = true {
        
        didSet{
            
            if atRoot{
                
                self.removeLastLeftButton()
            }
            else {
                
                if self.backbutton == nil{
                    
                    self.backbutton = UIBarButtonItem(title: "<-", style: .plain, target: self, action: #selector(CloudFileViewController.onBackToParent))
                }
                
                self.addLeftButton(button: self.backbutton!)
            }
        }
    }
    
    private var startAuth : Bool? = false
    
    var data : [[CloudDriveMetadata]]? {
        
        didSet{
            
            self.tableView?.reloadData()
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.downloadButton == nil{
            self.downloadButton = UIBarButtonItem(title: "Download", style: .plain, target: self, action: #selector(CloudFileViewController.showDwonload))
        }
        
        self.addRightButton(button: self.downloadButton!)
        
        CloudDriveManager.shareInstance.onDirectoryPathChanged = {currentPath, isRoot in
            
            self.atRoot = isRoot
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        assert(self.driveType != nil, "Drive type must be set")
        
        //we refresh back button
        if atRoot{
            
            self.atRoot = true
        }
        else {
            
            self.atRoot = false
        }
        
        if self.startAuth!{
            
            return
        }
        
        self.startAuth = true
        CloudDriveManager.shareInstance.driveType = self.driveType!
        CloudDriveManager.shareInstance.startAuth(inController: self) { state in
            
            switch state{
                
            case .Success:
                
                self.title = CloudDriveManager.shareInstance.driveTypeString
                
                self.showContentWithMetadata(metadata: nil)
                break
            case .Cancel:
                
                _ = self.navigationController?.popViewController(animated: true)
                
                break
            case .Error(let msg):
                
                let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { action in
                    
                    _ = self.navigationController?.popViewController(animated: true)
                })
                
                alert.addAction(okAction)
                
                self.present(alert, animated: true, completion: nil)
                
                break
            }
            
        }
    }
    
    func onBackToParent(){
        
        CloudDriveManager.shareInstance.goToParentDirectory { result, error in
            
            guard error == nil else {
                
                return
            }
            
            self.processData(result: result)
        }
    }
    
    func showDwonload(){
        
        self.performSegue(withIdentifier: "ShowDownloadQueue", sender: nil)
    }
    
    func showContentWithMetadata(metadata:CloudDriveMetadata?){
        
        CloudDriveManager.shareInstance.listContentWithMetadata(metadata: metadata, completeHandler: { result, error in
            
            guard error == nil else {
                
                return
            }
            
            self.processData(result: result)
        })
    }
    
    func processData(result : [CloudDriveMetadata]?){
        
        if let data = result{
            
            var dataSet : [[CloudDriveMetadata]] = Array()
            var folderGroup : [CloudDriveMetadata] = Array<CloudDriveMetadata>()
            var fileGroup : [CloudDriveMetadata] = Array<CloudDriveMetadata>()
            
            for aData in data{
                
                if aData.isFolder{
                    
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
    
    //MARK:table data srouce delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.data != nil ? (self.data?.count)! : 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data != nil ? self.data![section].count : 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let item = self.data?[section][0]
        
        return (item?.isFolder)! ? "Folders" : "Files"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellId = "MetadataCell"
        
        let item : CloudDriveMetadata = (self.data?[indexPath.section][indexPath.row])!
        
        var cell : CloudMetadataCell? = tableView.dequeueReusableCell(withIdentifier: cellId) as? CloudMetadataCell
        
        if cell == nil{
            
            cell = CloudMetadataCell()
        }
        
        cell?.titleLabel?.text = item.name
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item : CloudDriveMetadata = self.data![indexPath.section][indexPath.row]
        
        if item.isFolder{
            
            self.showContentWithMetadata(metadata: item)
        }
        else{
            
            //let localFilePath = (documentPath() as NSString).appendingPathComponent(item.name)
            
            let systemDownloadPath = SystemFolderManager.shareInstance.systemFolderPath(folderName: sysDownloadFolder)
            
            let localFilePath = (systemDownloadPath as NSString).appendingPathComponent(item.name)
            
            CloudDriveManager.shareInstance.downloadFileWith(metadata: item, localPath: localFilePath, resultHandler: { task, error in
                
                if let err = error{
                    
                    var errorMsg = ""
                    
                    switch err{
                        
                    case .CloudDriveDownloadExist:
                        errorMsg = "This file is already in download queue"
                        break
                    default:
                        break
                    }
                    
                    let controller = UIAlertController(title: "Error", message: errorMsg, preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    
                    controller.addAction(cancelAction)
                    
                    self.present(controller, animated: true, completion: nil)
                    
                }
                else{
                    
                    /**
                     Animate cell to download button
                    */
                    let cell = tableView.cellForRow(at: indexPath)
                    
                    let snapshot = snapshotOfView(inView: cell!, afterScreenUpdate: false)
                    
                    let navBarBounds = self.navigationController?.navigationBar.bounds
                    let destRect = CGRect(x: (navBarBounds?.width)!-44, y: 0, width: 44, height: 5)
                    
                    let fixOrigin = CGPoint(x: (cell?.frame.origin.x)!, y: (cell?.frame.origin.y)! - tableView.contentOffset.y)
                    let position = self.view.convert(fixOrigin, to: self.view)
                    
                    snapshot.frame.origin = position
                    self.view.addSubview(snapshot)
                    
                    snapshot.genieInTransition(withDuration: 0.7, destinationRect: destRect, destinationEdge: .bottom, completion: {
                        
                        snapshot.removeFromSuperview()
                    })
                    
                }
            })
        }
    }
    
}
