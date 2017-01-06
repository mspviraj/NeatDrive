//
//  DownloadQueueViewController.swift
//  NeatDrive
//
//  Created by Nelson on 1/3/17.
//  Copyright © 2017 Nelson. All rights reserved.
//

import Foundation
import UIKit

class DownloadQueueViewController : UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var tableView : UITableView?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "Download"
        
        CloudDriveManager.shareInstance.autoCleanDownloadTask = false
        
        CloudDriveManager.shareInstance.onDownloadBegin = {task in
            
            
            if let index = CloudDriveManager.shareInstance.allDownloadTasks.index(of: task){
                
                self.tableView?.beginUpdates()
                
                self.tableView?.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                
                self.tableView?.endUpdates()
            }
            
            
        }
        
        CloudDriveManager.shareInstance.onDownloadStarted = {task in
            
            
        }
        
        CloudDriveManager.shareInstance.onDownloadReceivedData = {task, progress in
            
            self.tableView?.reloadData()
        }
        
        CloudDriveManager.shareInstance.onDownloadComplete = {task in
            
            
            self.tableView?.reloadData()
            
        }
        
        CloudDriveManager.shareInstance.onDownloadEnd = {task, index in
            
            self.tableView?.beginUpdates()
            
            self.tableView?.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            
            self.tableView?.endUpdates()
        }
        
        CloudDriveManager.shareInstance.onDownloadCancel = {task in
            
            
            self.tableView?.reloadData()
        }
        
        CloudDriveManager.shareInstance.onDownloadError = {task, error in
            
            
            self.tableView?.reloadData()
            
        }
    }
    
    //MARK:table data source delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CloudDriveManager.shareInstance.allDownloadTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellId = "DownloadCell"
        
        let task = CloudDriveManager.shareInstance.allDownloadTasks[indexPath.row]
        
        var cell : DownloadCell? = tableView.dequeueReusableCell(withIdentifier: cellId) as? DownloadCell
        
        if cell == nil{
            
            cell = DownloadCell()
        }
        
        return configureCell(cell: cell!, task: task)
    }
    
    private func configureCell(cell : DownloadCell, task:CloudDriveDownloadTask) -> DownloadCell{
        
        cell.filenameLable?.text = task.fileName
        cell.progressView?.progress = task.downloadProgress
        
        switch task.status {
        case .Downloading:
            cell.statusLabel?.text = task.downloadProgress < 0 ? "Unknow progress" : "\(UInt(task.downloadProgress * 100.0))%"
        case .Complete:
            cell.statusLabel?.text = "Download complete"
            
        case .Cancel:
            cell.statusLabel?.text = "Download cancel"
            
        case .Error:
            cell.statusLabel?.text = "Download error"
            
        default:
            cell.statusLabel?.text = "0%"
        }
        
        cell.cloudDriveLabel?.text = task.driveTypeString()
        
        
        return cell
    }
    
}
