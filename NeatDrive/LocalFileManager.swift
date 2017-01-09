//
//  LocalFileManager.swift
//  NeatDrive
//
//  Created by Nelson on 1/9/17.
//  Copyright © 2017 Nelson. All rights reserved.
//

import Foundation

enum LocalFileManagerError : Error {
    case InternalError(String)
}

class LocalFileManager : NSObject{
    
    
    static let shareInstance : LocalFileManager = LocalFileManager()
    
    var onCurrentPathChanged : ((Bool)->())?
    
    private var currentPath : String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]{
        
        didSet{
            
            
            
            if let handler = self.onCurrentPathChanged{
                
                var isRoot = true
                
                if currentPath != self.rootDirectory{
                    
                    isRoot = false
                }
                
                handler(isRoot)
            }
            
        }
    }
    
    var currentPathString : String{
        
        get{
            
            return self.currentPathURL.path
        }
    }
    
    var currentPathURL : URL{
        
        get{
            
            return URL(fileURLWithPath: self.currentPath)
        }
    }
    
    var rootDirectory : String{
        
        get{
            
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            
            return path
        }
    }
    
    var rootDirectoryURL : URL{
        
        get{
            
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            
            return URL(fileURLWithPath: path)
        }
    }
    
    /**
     Get list of contents under metadata(folder) or give nil for contents under root
    */
    func getContentsWithMetadata(metadata:LocalFileMetadata?, complete:([LocalFileMetadata]?)->()){
        
        var newPath = self.currentPath
        
        if metadata != nil{
            
            assert(metadata?.IsFolder != true, "Given file not folder")
            
            newPath = (self.currentPath as NSString).appendingPathComponent((metadata?.FileName)!)
        }
        else {
            
            newPath = self.rootDirectory
        }
        
        let newPathURL = URL(fileURLWithPath: newPath)
        
        do{
            
            let contentURLs = try FileManager.default.contentsOfDirectory(at: newPathURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            
            var content : [LocalFileMetadata] = Array<LocalFileMetadata>()
            
            for url in contentURLs{
                
                //is file or folder
                var isDirectory : ObjCBool = false
                FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
                
                //file attribute
                let fileAttr : NSDictionary = try FileManager.default.attributesOfItem(atPath: url.path) as NSDictionary
                
                
                var fileSize : UInt64 = 0
                let createDate : Date? = fileAttr.fileCreationDate()
                let modifyDate : Date? = fileAttr.fileModificationDate()
                let fileName : String = (url.path as NSString).lastPathComponent
                
                if !isDirectory.boolValue{
                    
                    fileSize = fileAttr.fileSize()
                }
                
                content.append(LocalFileMetadata(_fileURL: url, _fileSize: fileSize, _createDate: createDate, _modifyDate: modifyDate, _filename: fileName, _isFolder: isDirectory.boolValue))
            }
            
            self.currentPath = newPath
            
            complete(content)
        }
        catch {
            
            assertionFailure("fail to get contents")
        }
    }
}
