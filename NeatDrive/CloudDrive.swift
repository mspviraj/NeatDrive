//
//  DriveProtocol.swift
//  CloudDrive
//
//  Created by Nelson on 12/17/16.
//  Copyright © 2016 Nelson. All rights reserved.
//

import Foundation
import UIKit

//MARk:Authroize state
enum CloudDriveAuthState {
    case Success
    case Cancel
    case Error(String)
}

//MARK:Error
enum CloudDriveError : Error{
    
    case CloudDriveTypeNotSet
    case CloudDriveInternalError(String)
    case CloudDriveDownloadExist(String)
    case CloudDriveDownloadError(String)
}

//MARK:Drive type
enum CloudDriveType : String {
    case DropBox
    case GoogleDrive
    case Unknow
}

//MARK:Cloud drive metadata
/**
 Represent the file and folder in could drive
 */
class CloudDriveMetadata{
    
    /**
     previous metadata
    */
    var previous : CloudDriveMetadata? = nil
    
    /**
     File ID
    */
    var fileId : String
    
    /**
     Is it a folder or file
     true:folder
     false:file
    */
    var isFolder : Bool
    
    /**
     Is parent folder a root folder
     Is under root folder or not
    */
    var isUnderRoot : Bool
    
    /**
     Name of folder or file
     include extension if it is file
    */
    var name : String
    
    
    
        
    init(m_fileId:String,m_folder:Bool, m_underRootFolder:Bool, m_name:String) {
        
        self.fileId = m_fileId
        self.isFolder = m_folder
        self.isUnderRoot = m_underRootFolder
        self.name = m_name
    }
    
    deinit {
        
        if self.previous != nil {
            
            self.previous = nil
        }
        
    }
    
    func hasTargetChain(target : CloudDriveMetadata) -> Bool{
        
        var next : CloudDriveMetadata? = self
        
        repeat{
            
            if next === target{
                
                return true
            }
            
            if let pre = next?.previous{
               
                next = pre
            }
            else {
                
                next = nil
            }
            
            
        }while(next != nil)
        
        return false
    }
    
    func breakChainUntil(target : CloudDriveMetadata){
        
        var next : CloudDriveMetadata? = self
        
        while(next != nil && next !== target){
            
            let p = next
            
            if let pre = next?.previous{
                
                next = pre
            }
            else {
                
                next = nil
            }
            
            p?.previous = nil
            
            
        }
        
        #if DEBUG
            while(next != nil){
                
                print(next?.name)
                next = next?.previous
            }
        #endif
    }
}

//MARK:CloudDriveManager class

/**
 Check if current cloud drive exist
 
 If not exit throw an assertion
 */
func CLOUD_DRIVE_CHECK(obj:CloudDriveManager){
    
    assert(obj.currentDrive != nil, "No current cloud drive")
}


enum CleanDownloadTaskOption : UInt{
    
    case CleanComplete = 0b001
    case CleanCancel   = 0b010
    case CleanError    = 0b100
}

class CloudDriveManager : NSObject{

    static let shareInstance : CloudDriveManager = CloudDriveManager()
    
    /**
     Register to listen callback when cloud drive change directory
     
     Given current metadata, is in root
    */
    var onDirectoryPathChanged : ((CloudDriveMetadata?, Bool) -> ())?
    
    /**
     Register to listen callback when a download task begin
     
     This mean a downloaded task is added to download queue but not start yet
     */
    var onDownloadBegin : ((CloudDriveDownloadTask)->())?
    
    /**
     Register to listen callback when a download task started
    */
    var onDownloadStarted : ((CloudDriveDownloadTask)->())?
    
    /**
     Register to listen callback when a download task received data
     
     This also provide download progress
     */
    var onDownloadReceivedData : ((CloudDriveDownloadTask, Float)->())?
    
    /**
     Register to listen callback when a download task complete
     
     */
    var onDownloadComplete : ((CloudDriveDownloadTask)->())?
    
    /**
     Register to listen callback when a download task encounter error
     
     */
    var onDownloadError:((CloudDriveDownloadTask, CloudDriveError)->())?
    
    /**
     Register to listen callback when a download task cancel
     
     */
    var onDownloadCancel:((CloudDriveDownloadTask)->())?
    
    /**
     Register to listen callback when a download task end
     
     This mean a downloaded task is removed from queue
     
     Given index of task is removed
    */
    var onDownloadEnd:((CloudDriveDownloadTask, Int)->())?
    
    /**
     Current path you are in
    */
    var currentMetadata : CloudDriveMetadata? = nil{
        
        didSet{
            
            //notify directory changed
            if let handler = self.onDirectoryPathChanged {
                
                handler(self.currentMetadata, self.isRoot)
            }
        }
    }
    
    /*
    /**
     Previous path 
    */
    var previousPath : String {
        
        get{
            
            return self.removeLastPath(path: self.currentPath)
        }
    }
     */
    
    /**
     Is current in root directory
    */
    var isRoot : Bool {
        
        get{
            
            if self.currentDrive != nil{
                
                return self.currentMetadata == nil
            }
            
            return true
        }
    }
    
    /**
     True indicate request sent but not respond yet
    */
    private var isQuerying : Bool = false
    
    /**
    current working cloud drive
    */
    var currentDrive : CloudDrive?
    
    /**
     Type of cloud drive.
     Change type switching to new cloud drive
    */
    var driveType:CloudDriveType {
        
        get{
        
            if self.currentDrive != nil{
                
                return (self.currentDrive as! CloudDriveProtocol).driveType()
            }
            
            return .Unknow
        }
        
        set{
        
            self.setDrive(driveType: newValue)
        }
    }
    
    /**
     Return string of current drive type
     Return empty if there is no drive type
    */
    var driveTypeString:String{
        
        get{
            
            if self.currentDrive != nil{
                
                return (self.currentDrive as! CloudDriveProtocol).driveTypeString()
            }
            
            return ""
        }
    }
    
    /**
     Hold all downloading task of cloud drive
    */
    private var downloadTasks : Array<CloudDriveDownloadTask> = Array<CloudDriveDownloadTask>()
    
    /**
     Get all download tasks
    */
    var allDownloadTasks : Array<CloudDriveDownloadTask> {
        
        get {
            
            return self.downloadTasks
        }
    }
    
    /**
     True then download task that is complete, cancel, error will be removed automatically
     
     False if you like to preserve in queue
    */
    var autoCleanDownloadTask : Bool = false{
        
        didSet{
            
            if autoCleanDownloadTask == true{
                
                var arr = Array<CloudDriveDownloadTask>()
                
                for t in self.downloadTasks{
                    
                    if t.status != .Downloading && t.status != .BeginDownload{
                        
                        arr.append(t)
                    }
                }
                
                for t in arr{
                    
                    self.removeDownloadTask(task: t)
                }
                
                arr.removeAll()
            }
        }
    }
    
    override init(){
        
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleLowMemory), name: .UIApplicationDidReceiveMemoryWarning, object: nil)
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self, name: .UIApplicationDidReceiveMemoryWarning, object: nil)
    }
    
    /**
     Start authorize process
    */
    func startAuth(inController:UIViewController, completeHandler:@escaping (CloudDriveAuthState)->()) {
        
        currentDrive?.authCompleteHandler = completeHandler
        (currentDrive as! CloudDriveProtocol).authorize(inController: inController)
    }
    
    /**
     Return list of data with metadata
     return nil if not found
     */
    func listContentWithMetadata(metadata:CloudDriveMetadata?, completeHandler:(([CloudDriveMetadata]?, CloudDriveError?) ->())?){
        
        guard currentDrive != nil else {
            
            if let handler = completeHandler {
                
                handler(nil, CloudDriveError.CloudDriveTypeNotSet)
            }
            
            return
        }
        
        if let meta = metadata{
            
            assert(meta.isFolder, "Can not get list of contents with file metadata")
        }
        
        
        if isQuerying {
            
            //no more reuqest can be made if last one is not yet respond
            return
        }
        
        self.isQuerying = true
        
        (currentDrive as! CloudDriveProtocol).contentsWithMetadata(metadata: metadata, complete: { result, error in
            
            self.isQuerying = false
            
            //no error
            if error == nil {
                
                if metadata != nil {
                    
                    if let curMetadata = self.currentMetadata{
                        
                        if (self.currentMetadata?.hasTargetChain(target: metadata!))!{
                            
                            self.currentMetadata?.breakChainUntil(target: metadata!)
                            self.currentMetadata = metadata
                            
                        } else {
                            
                            metadata?.previous = curMetadata
                            self.currentMetadata = metadata
                        }
                        
                        
                    } else {
                        
                        self.currentMetadata = metadata
                    }
                    
                } else {
                    
                    self.currentMetadata = nil
                }
                
            }
            
            if let handler = completeHandler {
                
                handler(result, error)
            }
        })
    }
    
    /**
     Go back to parent directory of current directory
     
     Return list of data for specific path in cloud drive
     return nil if not found
     */
    
    func goToParentDirectory(completeHandler:(([CloudDriveMetadata]?, CloudDriveError?)->())?){
        
        if let curMetadata = self.currentMetadata{
            
            self.listContentWithMetadata(metadata: curMetadata.previous, completeHandler: completeHandler)
        }
        
    }
    
    /**
     Call this method in AppDelegate to handle redirect url
    */
    func handleRedirect(url:URL){
        
        if let drive = currentDrive{
            
            drive.handleRedirect(url: url)
        }
    }
    
    /**
     Download file from cloud drive
     Return dwonload task if download is valid
    */
    func downloadFileWith(metadata:CloudDriveMetadata, localPath:String, resultHandler:((CloudDriveDownloadTask?, CloudDriveError?)->())?){
        
        CLOUD_DRIVE_CHECK(obj: self)
        
        if metadata.isFolder{
            
            if let handler = resultHandler{
                
                handler(nil, CloudDriveError.CloudDriveInternalError("Download item is folder not file"))
            }
            
            return
        }
        
        //check download exist
        if self.isDownloadExist(driveType: (self.currentDrive as! CloudDriveProtocol).driveType(), fileId: metadata.fileId){
            
            if let handler = resultHandler{
                
                let msg = "Download file \(metadata.name) from \((self.currentDrive as! CloudDriveProtocol).driveTypeString()) already in downloading, can not make duplicate download at same time"
                
                handler(nil, CloudDriveError.CloudDriveDownloadExist(msg))
            }
            
            return
        }
        
        //create new download task
        let task:CloudDriveDownloadTask = (self.currentDrive as! CloudDriveProtocol).createDownloadTask(metadata: metadata, localPath: localPath)
        
        //always over write local file
        task.overWriteFile = true
        
        if let handler = resultHandler{
            
            handler(task, nil)
        }
 
        
        task.onDownloadError = {task, error in
        
            print("download error \(error)")
            
            if let handler = self.onDownloadError{
                
                handler(task, error)
                
                if self.autoCleanDownloadTask{
                    
                    self.removeDownloadTask(task: task)
                }
            }
        }
        
        task.onDownloadReceiveData = {task, progress in
        
            print("download progress \(progress)")
            
            if let handler = self.onDownloadReceivedData{
                
                handler(task, progress)
            }
        }
        
        task.onDownloadCancel = {task in
            
            print("download cancel")
            
            if let handler = self.onDownloadCancel{
                
                handler(task)
                
                if self.autoCleanDownloadTask{
                    
                    self.removeDownloadTask(task: task)
                }
            }
        }
        
        task.onDownloadComplete = {task in
        
            print("download complete \(task.filePathAtLocal)")
            
            if let handler = self.onDownloadComplete{
                
                handler(task)
                
                if self.autoCleanDownloadTask{
                    
                    self.removeDownloadTask(task: task)
                }
            }
        }
        
        //add download task
        self.addDownloadTask(task: task)
    

        (task as! CloudDriveDownloadProtocol).startDownload()
        
        //notify download task started
        if let handler = onDownloadStarted{
            
            handler(task)
        }
    }
    
    /**
     Logout current cloud drive
    */
    func logout(){
        
        if self.currentDrive != nil{
            
            let currentDriveType = (self.currentDrive as! CloudDriveProtocol).driveType()
            
            var removedTask = Array<CloudDriveDownloadTask>()
            
            #if DEBUG
                print("logout will remove \(self.downloadTasks.count) downloading task")
            #endif
            
            //cancel related downloading task
            for task in self.downloadTasks{
                
                if task.driveType == currentDriveType{
                    
                    (task as! CloudDriveDownloadProtocol).cancelDownload()
                    removedTask.append(task)
                }
            }
            
            //remove download task
            for t in removedTask{
                
                self.removeDownloadTask(task: t)
            }
            removedTask.removeAll()
            
            //logout drive
            (self.currentDrive as! CloudDriveProtocol).logout()
            
            self.currentDrive = nil
            self.currentMetadata = nil
            self.isQuerying = false
        }
    }
    
    /**
     Check if there is a downloading task for specific cloud drive
    */
    func hasDownloadTaskForDriveType(driveType:CloudDriveType) -> Bool{
        
        for task in self.downloadTasks{
            
            if task.driveType == driveType && task.status == .Downloading{
                
                return true
            }
        }
        
        return false
    }
    
    /**
     Remove a specific download task
    */
    func deleteDownloadTask(task:CloudDriveDownloadTask){
        
        if task.status != .Cancel && task.status != .Complete{
            
            (task as! CloudDriveDownloadProtocol).cancelDownload()
        }
        
        self.removeDownloadTask(task: task)
    }
    
    func handleLowMemory(){
        
        #if DEBUG
            print("Encounter low memory, clean up download task")
        #endif
        cleanDownloadTask()
    }
    
    /**
     Clean download task except the one is downloading
     
     Specify option or combine to remove certain download task
     

     -CleanDownloadTaskOption.CleanCancel.rawValue

     -CleanDownloadTaskOption.CleanComplete.rawValue

     -CleanDownloadTaskOption.CleanError.rawValue
     
     default are combination of 3
    */
    func cleanDownloadTask(option:UInt = CleanDownloadTaskOption.CleanCancel.rawValue | CleanDownloadTaskOption.CleanComplete.rawValue | CleanDownloadTaskOption.CleanError.rawValue){
        
        var removedTask = Array<CloudDriveDownloadTask>()
        
        if (CleanDownloadTaskOption.CleanComplete.rawValue & option) != 0{
            
            for t in self.downloadTasks{
                
                if t.status == .Complete{
                    
                    removedTask.append(t)
                }
            }
        }
        
        if (CleanDownloadTaskOption.CleanCancel.rawValue & option) != 0{
            
            for t in self.downloadTasks{
                
                if t.status == .Cancel{
                    
                    removedTask.append(t)
                }
            }
        }
        
        if (CleanDownloadTaskOption.CleanError.rawValue & option) != 0{
            
            for t in self.downloadTasks{
                
                if t.status == .Error{
                    
                    removedTask.append(t)
                }
            }
        }

        for t in removedTask{
            
            self.removeDownloadTask(task: t)
        }
        
        #if DEBUG
            print("\(removedTask.count) tasks are removed")
        #endif
        
        removedTask.removeAll()
    }
    
    private func setDrive(driveType:CloudDriveType){
        
        self.currentMetadata = nil
        self.isQuerying = false
        
        switch driveType {
        case .DropBox:
            if (currentDrive == nil)||(currentDrive as! CloudDriveProtocol).driveType() != .DropBox{
                
                currentDrive = DropBoxDrive()
            }
        case .GoogleDrive:
            if (currentDrive == nil)||(currentDrive as! CloudDriveProtocol).driveType() != .GoogleDrive{
                
                currentDrive = GoogleDrive()
            }
        default:
            if self.currentDrive != nil{
                
                self.logout()
                return
            }
            
        }
    }
    
    private func isDownloadExist(driveType:CloudDriveType, fileId:String) -> Bool{
        
        for task in self.downloadTasks{
            
           let exist = task.driveType == driveType && task.fileId == fileId && (task.status == .BeginDownload || task.status == .Downloading)
            
            if exist {
                
                return exist
            }
        }
        
        return false
    }
    
    private func removeDownloadTask(task:CloudDriveDownloadTask){
        
        let index = self.downloadTasks.index(of: task)
        
        if let i = index {
            
            self.downloadTasks.remove(at: i)
            
            if let handler = onDownloadEnd{
                
                handler(task, index!)
            }
        }
    }
    
    private func addDownloadTask(task:CloudDriveDownloadTask){
        
        self.downloadTasks.insert(task, at: 0)
        
        //notify download task add to queue
        if let handler = onDownloadBegin{
            
            handler(task)
        }
    }
    
    
}

//MARK:CloudDriveProtocol protocol

protocol CloudDriveProtocol {
    
    /**
     Start authorize process
     */
    func authorize(inController:UIViewController)
    
    /**
     Get list of data with metadata
     */
    func contentsWithMetadata(metadata:CloudDriveMetadata?, complete:(([CloudDriveMetadata]?, CloudDriveError?)->())?)
    
    /**
     Return type of cloud drive
     */
    func driveType() -> CloudDriveType
    
    /**
     Return type of cloud drive in string
    */
    func driveTypeString() -> String
    
    /**
     Return a new download task
     */
    func createDownloadTask(metadata:CloudDriveMetadata, localPath:String) -> CloudDriveDownloadTask
    
    /**
     Logout
    */
    func logout()
    
}

//MARK:CloudDrive class

class CloudDrive: NSObject {
    
    /**
     Call when authoriz process complete
    */
    var authCompleteHandler : ((CloudDriveAuthState)->())?
    
    /**
     Call this method to handle redirect url
    */
    func handleRedirect(url:URL){
        
    }
    
    func cloudName() -> String{
        
        return ""
    }
    
    deinit {
        
        #if DEBUG
            print("\(self.cloudName()) Cloud drive remove")
        #endif
    }
}

//MARK:CloudDriveDownloadProtocol

protocol CloudDriveDownloadProtocol {
    
    /**
     Start download
     */
    func startDownload()
    
    /**
     Cancel download
     */
    func cancelDownload()
    
    
}

//MARK:CloudDriveDownloadTask class
enum downloadStatus {

    case BeginDownload
    case Downloading
    case Complete
    case Cancel
    case Error
}

class CloudDriveDownloadTask: NSObject{
    
    /**
     File Id
    */
    private let fileID : String
    
    var fileId : String{
        
        get{
            
            return self.fileID
        }
    }
    
    /**
     UUID
     
     Unique indentifier of download task
    */
    private let id : NSUUID = NSUUID()
    
    var taskId : NSUUID{
        
        get{
            
            return self.id
        }
    }
    
    var taskIdString : String{
        
        get{
            
            return self.id.uuidString
        }
    }
    
    /**
     Type of cloud
    */
    private let cloudType : CloudDriveType
    
    var driveType : CloudDriveType{
        
        get{
            
            return self.cloudType
        }
    }
    
    /**
     File path in cloud drive where need to be downloaded
    */
    private let cloudFilePath : String
    
    var filePathAtCloud : String {
        
        get{
            
            return self.cloudFilePath
        }
    }
    
    /**
     Download file's name
    */
    private let filename : String
    
    /**
     Return file name of file
     */
    var fileName : String {
        
        get{
            
            return self.filename
        }
    }
    
    /**
     File path in local where downloaded file will be stored
     */
    private let localFilePath : String
    
    var filePathAtLocal : String{
        
        get{
            
            return self.localFilePath
        }
    }
    
    /**
     Download progress
     
     Negative value mean unknow
    */
    var downloadProgress : Float = 0.0
    
    /**
     Over write file at local path
    */
    var overWriteFile : Bool = true
    
    /**
     Status of download task
    */
    var status : downloadStatus = .BeginDownload

    
    var onDownloadError : ((CloudDriveDownloadTask, CloudDriveError)->())?
    var onDownloadReceiveData : ((CloudDriveDownloadTask, Float)->())?
    var onDownloadCancel : ((CloudDriveDownloadTask)->())?
    var onDownloadComplete : ((CloudDriveDownloadTask)->())?
    
    init(file_ID:String, file_name:String, type:CloudDriveType, path:String, localPath:String){
        
        self.fileID = file_ID
        self.filename = file_name
        self.cloudType = type
        self.cloudFilePath = path
        self.localFilePath = localPath
        self.status = .BeginDownload
        
        super.init()
    }
    
    deinit {
        
        #if DEBUG
            print("download task remove")
        #endif
    }
    
    func driveTypeString() -> String{
        
        return self.cloudType.rawValue
    }
}
