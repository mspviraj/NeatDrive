//
//  LocalFileManager.swift
//  NeatDrive
//
//  Created by Nelson on 1/9/17.
//  Copyright © 2017 Nelson. All rights reserved.
//

import Foundation

public enum LocalFileManagerError : Error {
    case InternalError(String)
    case folderExistError(String)
    case createFolderError(String)
    case renameFileError(String)
    case renameDuplicateError(String)
    case deleteSingleFileError(String)
    case deleteFileError([String:String])//key as path, value as reason
    case moveSingleFileError(String)
    case moveFileError([String:String])//key as path, value as reason
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
     
     deep: true will get all file and folder under this path include subfolder, default is false
     
     alterCurrentPath: true current path will be changed after procedure has done, default is true. Recommend not alter this value unless you are using method for seaching file or folder
    */
    func contentsInPath(path:String?, deep:Bool = false, alterCurrentPath:Bool = true, complete:@escaping ([LocalFileMetadata])->()){
        
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
                var contentURLs : [URL] = Array<URL>()
                
                if deep{
                    
                    let enumerator : FileManager.DirectoryEnumerator = FileManager.default.enumerator(at: newPathURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles, errorHandler:nil)!
                    
                    for case let fileURL as URL in enumerator{
                        
                        contentURLs.append(fileURL)
                    }
                }
                else{
                    
                    contentURLs = try FileManager.default.contentsOfDirectory(at: newPathURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
                }
                
                
                
                var content : [LocalFileMetadata] = Array<LocalFileMetadata>()
                
                for theUrl in contentURLs{
                    
                    //using standardized file URL to remove symlink eg. private/
                    let url = theUrl.standardizedFileURL
                    
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
                
                if alterCurrentPath{
                    
                    self.currentPath = newPath
                }
                
                
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
    
    /**
     Back to parent folder
    */
    func backToParent(complete:@escaping ([LocalFileMetadata])->()){
        
        if self.currentPath == self.rootDirectory{
            
            self.contentsInPath(path: nil, complete: complete)
        }
        else {
            
            self.contentsInPath(path: (self.currentPath as NSString).deletingLastPathComponent, complete: complete)
        }
    }
    
    /**
     Create folder at path
     
     Error:
     folderExistError(reason[string])
     createFolderError(reason[string])
    */
    func createfolderAtPath(path:String, folderName:String, complete:@escaping (String?, LocalFileManagerError?)->()){
        
        let newPath = (path as NSString).appendingPathComponent(folderName)
        var isDirectory : ObjCBool = false
        let validPath = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        let pathExist = FileManager.default.fileExists(atPath: newPath)
        
        assert(validPath == true, "path \(path) does not exist")
        assert(isDirectory.boolValue == true, "given path \(path) is not a directory")
        
        if pathExist {
            
            complete(nil, LocalFileManagerError.folderExistError("folder \(folderName) already exist at path \(path)"))
            
            return
        }
        
        DispatchQueue.global(qos: .background).async {
            
            do{
                
                try FileManager.default.createDirectory(atPath: newPath, withIntermediateDirectories: true, attributes: nil)
                
                DispatchQueue.main.async {
                    
                    complete(newPath, nil)
                }
            }
            catch{
                
                DispatchQueue.main.async {
                    
                    complete(nil, LocalFileManagerError.createFolderError(""))
                }
            }
        }
    }
    
    /**
     Rename file or folder
     newName is not recommended to include file extension
     
     Error:
     renameFileError(reason[String])
     renameDuplicateError(reason[String])
    */
    func renameFile(filePath:String, newName:String, complete:@escaping (String?, LocalFileManagerError?)->()){
        
        if filePath == self.rootDirectory{
        
            complete(nil, LocalFileManagerError.renameFileError("path \(filePath) is root path"))
            
            return
        }
        
        var isDirectory : ObjCBool = false
        let validPath = FileManager.default.fileExists(atPath: filePath, isDirectory: &isDirectory)
        
        assert(validPath == true, "path \(filePath) does not exist")
        
        DispatchQueue.global(qos: .background).async {
            
            let fileExtension = (filePath as NSString).pathExtension
            let newFileName = (newName as NSString).appendingPathExtension(fileExtension)
            let parentPath = (filePath as NSString).deletingLastPathComponent
            let newPath = (parentPath as NSString).appendingPathComponent(newFileName!)
            
            let fileExist = FileManager.default.fileExists(atPath: newPath)
            
            if fileExist{
                
                DispatchQueue.main.async {
                    
                    complete(nil, LocalFileManagerError.renameDuplicateError("duplicate name \(newName)"))
                }
                
                return
                
            }
            
            do{
                
                try FileManager.default.moveItem(atPath: filePath, toPath: newPath)
                
                DispatchQueue.main.async {
                    
                    complete(newPath, nil)
                }
            }
            catch{
                
                DispatchQueue.main.async {
                    
                    complete(nil, LocalFileManagerError.renameFileError(""))
                }
            }
        }
    }
    
    /**
     Delete file or folder
     
     Error:
     case deleteSingleFileError(reason[String])
     case deleteFileError([path:reason][String:String])
    */
    func deleteFiles(filePaths:[String], fileDeleted:@escaping (String)->(), complete:@escaping (LocalFileManagerError?)->()){
        
        DispatchQueue.global(qos: .background).async {
            
            var failToDelete : [String:String] = Dictionary<String, String>()
            
            for path in filePaths{
                
                if path == self.rootDirectory{
                    
                    failToDelete.updateValue("root path", forKey: path)
                    
                    continue
                }
                
                var isDirectory : ObjCBool = false
                let validPath = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
                
                assert(validPath == true, "path \(path) does not exist")
                
                do{
                    
                    try FileManager.default.removeItem(atPath: path)
                    
                    DispatchQueue.main.async {
                        
                        fileDeleted(path)
                    }
                }
                catch{
                    
                    DispatchQueue.main.async {
                        
                        complete(LocalFileManagerError.deleteSingleFileError("delete file at path \(path) fail"))
                    }
                }
            }
            
            if failToDelete.count > 0{
                
                DispatchQueue.main.async {
                    
                    complete(LocalFileManagerError.deleteFileError(failToDelete))
                }
            }
            else{
                
                DispatchQueue.main.async {
                    
                    complete(nil)
                }
            }
        }
    }
    
    /**
     Move file or folder to destination path
     
     Error:
     moveSingleFileError(reason[String])
     moveFileError([path:reason][String:String])
    */
    func moveFiles(filePaths:[String], destinationPath:String, fileMoved:@escaping (String, String)->(), complete:@escaping (LocalFileManagerError?)->()){
        
        var isDirectory : ObjCBool = false
        let validPath = FileManager.default.fileExists(atPath: destinationPath, isDirectory: &isDirectory)
        
        assert(validPath == true, "destination \(destinationPath) does not exist")
        assert(isDirectory.boolValue == true, "destination \(destinationPath) is not a directory")
        
        DispatchQueue.global(qos: .background).async {
            
            var failToMoved : [String:String] = Dictionary<String, String>()
            
            for path in filePaths{
                
                let pathExist = FileManager.default.fileExists(atPath: path)
                
                assert(pathExist == true, "path \(path) does not exist")
                
                if path == self.rootDirectory{
                    
                    failToMoved.updateValue("root path", forKey: path)
                    
                    continue
                }
                
                let fileName = (path as NSString).lastPathComponent
                let fileDestPath = (destinationPath as NSString).appendingPathComponent(fileName)
                
                let fileExist = FileManager.default.fileExists(atPath: fileDestPath)
                
                if fileExist{
                    
                    failToMoved.updateValue("file exist at destination \(destinationPath)", forKey: path)
                    
                    continue
                }
                
                do{
                    
                    try FileManager.default.moveItem(atPath: path, toPath: fileDestPath)
                
                    DispatchQueue.main.async {
                        
                        fileMoved(path, fileDestPath)
                    }
                }
                catch{
                    
                    DispatchQueue.main.async {
                        
                        complete(LocalFileManagerError.moveSingleFileError("\(path) can not be moved to \(destinationPath)"))
                    }
                }
            }
            
            if failToMoved.count > 0{
                
                DispatchQueue.main.async {
                    
                    complete(LocalFileManagerError.moveFileError(failToMoved))
                }
            }
            else{
                
                DispatchQueue.main.async {
                    
                    complete(nil)
                }
            }
        }
    }
    
    /**
     Search file or folder by keyword
     
     deepSearch: true will recursive search file and folder under given path, otherwise false it will perform shallow seach
    */
    func searchFile(path:String, keyword:String, deepSearch:Bool, complete:@escaping ([LocalFileMetadata])->()){
        
        var isDirectory : ObjCBool = false
        let validPath = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        
        assert(validPath == true, "path \(path) does not exist")
        assert(isDirectory.boolValue == true, "given path \(path) is not a directory")
        
        DispatchQueue.global(qos: .background).async {
            
            self.contentsInPath(path: path, deep:deepSearch, alterCurrentPath: false, complete: { result in
            
                var filtedFile : [LocalFileMetadata] = Array<LocalFileMetadata>()
                
                for data in result{
                    
                    if data.FileName.localizedCaseInsensitiveContains(keyword){
                        
                        filtedFile.append(data)
                    }
                }
                
                DispatchQueue.main.async {
                    
                    complete(filtedFile)
                }
                
            })
        }
    }
}
