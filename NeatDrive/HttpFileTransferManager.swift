//
//  HttpFileTransferManager.swift
//  HttpServer
//
//  Created by Nelson on 12/13/16.
//  Copyright © 2016 Nelson. All rights reserved.
//

import Foundation
import GCDWebServer.GCDWebUploader

class HttpFileTransferManager : NSObject, GCDWebUploaderDelegate{
    
    //MARK:Variables
    
    /**
     HttpFileTransferManager instance 
     
     Singleton
    */
    static private var _instance : HttpFileTransferManager?
    
    /**
     GCDWebUploader
    */
    private var webUploader :GCDWebUploader!
    
    /**
     Is server running
    */
    var isServerRunning : Bool{
        
        get{
            
            return self.webUploader.isRunning
        }
    }
    
    /**
     Return server URL is it is running otherwise nil
    */
    var serverURL : URL?{
        
        get{
            
            if self.isServerRunning{
                
                return self.webUploader.serverURL
            }
            
            return nil
        }
    }
    
    //MARK:Class method
    
    /**
     Return the singleton instance of HttpFileTransferManager
    */
    static func sharedManager() -> HttpFileTransferManager{
        
        guard _instance != nil else{
            
            //create HttpFileTransgerManager instance
            _instance = HttpFileTransferManager()
            
            //init GCDWebUploader instance with directory
            _instance?.webUploader = GCDWebUploader(uploadDirectory: HttpFileTransferManager.mainDirectory() as String!)
            
            //set delegate to GCDWebUploader
            _instance?.webUploader.delegate = _instance!
            
            return _instance!
        }
        
        return _instance!
    }
    
    /**
     Return main directory path that HttpFileTransferManager work with
    */
    static func mainDirectory() -> NSString{
        
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
    }
    
    //MARK:Public interface
    
    /**
     Start server
     
     Return URL
    */
    func start() -> URL?{
        
        guard webUploader.start() else {
            
            return nil
        }
        
        return webUploader.serverURL
    }
    
    /**
     Stop server
    */
    func stop(){
        
        webUploader.stop()
    }
    
    //MARK:GCDWebUploaderDelegate
    
    func webUploader(_ uploader: GCDWebUploader!, didDeleteItemAtPath path: String!) {
        
    }
    
    func webUploader(_ uploader: GCDWebUploader!, didDownloadFileAtPath path: String!) {
        
    }
    
    func webUploader(_ uploader: GCDWebUploader!, didUploadFileAtPath path: String!) {
        
        NSLog("update file complete \(path)")
    }
    
    func webUploader(_ uploader: GCDWebUploader!, didCreateDirectoryAtPath path: String!) {
        
    }
    
    func webUploader(_ uploader: GCDWebUploader!, didMoveItemFromPath fromPath: String!, toPath: String!) {
        
    }
    
}
