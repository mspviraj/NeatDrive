//
//  SystemFolderManager.swift
//  NeatDrive
//
//  Created by Nelson on 1/17/17.
//  Copyright © 2017 Nelson. All rights reserved.
//

import Foundation

public let sysDownloadFolder = "System Download Folder"

class SystemFolderManager : NSObject{
    
    static let shareInstance : SystemFolderManager = SystemFolderManager()
    
    //key as folder name, value as folder path
    private var folders : Dictionary = Dictionary<String, String>()
    
    private let documentPath : String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    
    override init() {
        
        super.init()
        
        self.initializeSystemFolder()
    }
    
    private func initializeSystemFolder(){
        
        let filePath = Bundle.main.path(forResource: "SystemFolderList", ofType: "plist")
        
        assert(filePath != nil, "SystemFolderList.plist does not exist in bundle")
        
        let systemFolderNames = NSArray(contentsOfFile: filePath!)
        
        //create system folder is needed
        for name in systemFolderNames!{
            
            let folderPath = (documentPath as NSString).appendingPathComponent(name as! String)
            
            //create one if not exist
            if !FileManager.default.fileExists(atPath: folderPath){
                
                do{
                    
                    try FileManager.default.createDirectory(atPath: folderPath, withIntermediateDirectories: true, attributes: nil)
                    
                    
                }
                catch{
                    
                    assertionFailure("Can not create system folder \(name) path \(folderPath)")
                }
            }
            
            self.folders.updateValue(folderPath, forKey: name as! String)
        }
    }
    
    func isSystemFolder(path:String) -> Bool{
        
        var isDirectory : ObjCBool = false
        let validPath = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        
        assert(validPath == true, "Given path \(path) is valid")
        
        if !isDirectory.boolValue{
            
            return false
        }
        
        let folderPath = self.folders[(path as NSString).lastPathComponent]
        
        if folderPath != nil{
            
            return folderPath == path
        }
        
        return false
        
    }
    
    func systemFolderPath(folderName : String) -> String{
        
        let path = self.folders[folderName]
        
        assert(path != nil, "System Download Folder not exist")
        
        return path!
    }
}
