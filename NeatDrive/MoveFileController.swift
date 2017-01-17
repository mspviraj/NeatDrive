//
//  MoveFileController.swift
//  NeatDrive
//
//  Created by Nelson on 1/17/17.
//  Copyright © 2017 Nelson. All rights reserved.
//

import Foundation
import UIKit

protocol MoveFileDelegate {
    
    func onDestinationPathPicked(path : String)
    func onCancel()
}

struct FolderMetadata {
    
    let fileURL : URL
    let folderName : String
}

class MoveFileController : UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var tableView : UITableView?
    
    var delegate : MoveFileDelegate?
    private var documentPath : String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    var filesToBeMoved : [String]?
    private var folders : [FolderMetadata]?{
        
        didSet{
            
            self.tableView?.reloadData()
        }
    }
    
    private var pickedPath : String?
    
    class func presentInViewController(inController : UIViewController, _delegate:MoveFileDelegate, movedfiles:[String]?){
        
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MoveFileNav")
        
        ((controller as! UINavigationController).topViewController as! MoveFileController).delegate = _delegate
        ((controller as! UINavigationController).topViewController as! MoveFileController).filesToBeMoved = movedfiles
        
        inController.present(controller, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "Move To"
        
        self.setup()
        
        self.navigationItem.leftBarButtonItems = nil
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(title: "<-", style: .plain, target: self, action: #selector(MoveFileController.cancel))]
        
    }
    
    @objc private func cancel(){
        
        self.parent?.dismiss(animated: true, completion: {
        
            if self.delegate != nil{
                
                self.delegate?.onCancel()
            }
        })
    }
    
    private func setup(){
    
        var metadatas : [FolderMetadata] = Array<FolderMetadata>()
        
        if self.canShowFolder(path: self.documentPath){
            
            metadatas.append(FolderMetadata(fileURL: URL(fileURLWithPath: self.documentPath), folderName: "System Root Folder"))
        }
        
        let enumerator : FileManager.DirectoryEnumerator = FileManager.default.enumerator(at: URL(fileURLWithPath: self.documentPath), includingPropertiesForKeys: nil, options: .skipsHiddenFiles, errorHandler:nil)!
        
        for case let fileURL as URL in enumerator{
            
            //is file or folder
            var isDirectory : ObjCBool = false
            FileManager.default.fileExists(atPath: fileURL.path, isDirectory: &isDirectory)
            
            //it is folder
            if isDirectory.boolValue{
                
                if canShowFolder(path: fileURL.path){
                    
                    metadatas.append(FolderMetadata(fileURL: fileURL, folderName: (fileURL.path as NSString).lastPathComponent))
                }
            }
        }
        
        self.folders = metadatas
    }
    
    private func canShowFolder(path:String) -> Bool{
    
        if self.filesToBeMoved == nil{
            
            return true
        }
        
        /*
        if path == self.documentPath{
            
            return true
        }
        */
 
        for f in self.filesToBeMoved!{
            
            var isDirectory : ObjCBool = false
            FileManager.default.fileExists(atPath: f, isDirectory: &isDirectory)
            
            //if this is file and dest path is document path
            if !isDirectory.boolValue && path == self.documentPath{
                
                //file already exist under root
                if FileManager.default.fileExists(atPath: (path as NSString).appendingPathComponent((f as NSString).lastPathComponent)){
                    
                    return false
                }
                else{
                    
                    continue
                }
            }
            
            //dont show folder if source folder is exist
            if FileManager.default.fileExists(atPath: (path as NSString).appendingPathComponent((f as NSString).lastPathComponent)){
                
                return false
            }
            
            //source path without document path
            var sPath = f.replacingOccurrences(of: self.documentPath, with: "")
            if sPath.hasPrefix("/"){
                sPath.remove(at: sPath.startIndex)
            }
            
            //source is under root so do not show root folder
            if (sPath as NSString).components(separatedBy: "/").count == 1 && path == self.documentPath{
                
                return false
            }
            
            //destination path without document path
            var dPath = path.replacingOccurrences(of: self.documentPath, with: "")
            if dPath.hasPrefix("/"){
                dPath.remove(at: dPath.startIndex)
            }
            
            //if path is same
            if sPath == dPath{
                
                return false
            }
            
            //if destination path contain source path
            //they are in the same path and source folder can not
            //be move to destination folder
            if dPath.range(of: sPath) != nil{
                
                return false
            }
            
        }
        
        return true
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.folders == nil ? 0 : (self.folders?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellId = "cell"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: cellId)
        
        if cell == nil{
            
            cell = UITableViewCell(style: .default, reuseIdentifier: cellId)
        }
        
        let folder = self.folders?[indexPath.row]
        
        cell?.textLabel?.text = folder?.folderName
        cell?.imageView?.image = UIImage(named: "test")
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let folder = self.folders?[indexPath.row]
        
        self.parent?.dismiss(animated: true, completion: { 
            
            if self.delegate != nil{
                
                self.delegate?.onDestinationPathPicked(path: (folder?.fileURL.path)!)
            }
        })
    }
}
