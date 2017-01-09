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
            
            DispatchQueue.main.async {
                
                if let handler = self.onCurrentPathChanged{
                    
                    var isRoot = true
                    
                    if self.currentPath != self.rootDirectory{
                        
                        isRoot = false
                    }
                    
                    handler(isRoot)
                }
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
     Get list of contents under path or give nil for contents under root
    */
    func contentsInPath(path:String?, complete:@escaping ([LocalFileMetadata])->()){
        
        var newPath = self.currentPath
        
        if path != nil{
            
            var isDirectory : ObjCBool = false
            let fileExist = FileManager.default.fileExists(atPath: path!, isDirectory: &isDirectory)
            
            
            assert(fileExist == true, "folder path \(path) does not exist")
            assert(isDirectory.boolValue == true, "given path is file not folder")
            
            newPath = path!
        }
        else {
            
            newPath = self.rootDirectory
        }
        
        let newPathURL = URL(fileURLWithPath: newPath)
        
        //run in background
        DispatchQueue.global(qos: .background).async {
            
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
                
                //back to main thread
                DispatchQueue.main.async {
                    
                    complete(content)
                }
            }
            catch {
                
                assertionFailure("fail to get contents")
            }
        }
    }
    
    func backToParent(complete:@escaping ([LocalFileMetadata])->()){
        
        if self.currentPath == self.rootDirectory{
            
            self.contentsInPath(path: nil, complete: complete)
        }
        else {
            
            self.contentsInPath(path: (self.currentPath as NSString).deletingLastPathComponent, complete: complete)
        }
    }
}
