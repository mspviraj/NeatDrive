//
//  GoogleDrive.swift
//  CloudDrive
//
//  Created by Nelson on 12/23/16.
//  Copyright © 2016 Nelson. All rights reserved.
//

import Foundation
import UIKit
import GTMOAuth2
import AppAuth
import GTMAppAuth
import GTMSessionFetcher
import GTMSessionFetcher.GTMSessionFetcherService
import GoogleAPIClient

let GoogleClientId = "GoogleClientID"
class GoogleDrive : CloudDrive, CloudDriveProtocol, OIDAuthStateChangeDelegate, OIDAuthStateErrorDelegate{

    
    private let issuer = "https://accounts.google.com"
    private let driveScope = "https://www.googleapis.com/auth/drive"
    private let keychainItemName = "GoogleDriveAPI"
    private var clientId = "CLIENT_ID.googleusercontent.com"
    private var redirectURI = "com.googleusercontent.apps.CLIENT_ID:/oauthredirect"
    //private let googleAuthURL = "https://accounts.google.com/o/oauth2/auth"
    //private let googleTokenURL = "https://accounts.google.com/o/oauth2/token"
    
    private var authorization : GTMAppAuthFetcherAuthorization?
    private var driveService : GTLServiceDrive = GTLServiceDrive()
    private var authFlow : Any?
    
    var retMetadata : Array<CloudDriveMetadata>?
    
    
    //MARK:Internal
    /**
     Start google drive service
     
     Return true successful otherwise false
    */
    private func startGoogleDriveService() -> Bool{
        
        
        if let credential = self.authorization{
            
            driveService.authorizer = credential
            
            return true
        }
        
        return false
    }
    
    /**
     Load authorized state
     
     Return true if auth state loaded otherwise false
    */
    private func loadAuthState() ->Bool{
        
        if let savedAuth = GTMAppAuthFetcherAuthorization.init(fromKeychainForName: self.keychainItemName){
            
            self.authorization = savedAuth
            self.saveAuthState()
            return true
        }
        
        return false
        
        
    }
    
    private func saveAuthState(){
        
        if self.authorization == nil{
            
            GTMAppAuthFetcherAuthorization.removeFromKeychain(forName: self.keychainItemName)
            
            return
        }
        
        if (self.authorization?.canAuthorize())!{
            
            GTMAppAuthFetcherAuthorization.save(self.authorization!, toKeychainForName: self.keychainItemName)
            
        } else {
            
            GTMAppAuthFetcherAuthorization.removeFromKeychain(forName: self.keychainItemName)
        }
    }
    
    private func setAuthorization(auth:GTMAppAuthFetcherAuthorization?){
        
        self.authorization = auth
        self.saveAuthState()
    }
    
    private func setupClientID(){
        
        let path = Bundle.main.path(forResource: "Info", ofType: "plist")
        let dic = NSDictionary(contentsOfFile: path!)
        let clientId = dic?[GoogleClientId]
        
        assert(clientId != nil, "No app key for DropBox. In Info.plist add \(GoogleClientId) as key and [YourGoogleClientID] as string value")
        
        self.clientId = "\(clientId as! NSString).apps.googleusercontent.com"
    }
    
    private func setupRedirectURL(){
        
        let path = Bundle.main.path(forResource: "Info", ofType: "plist")
        let dic = NSDictionary(contentsOfFile: path!)
        let clientId = dic?[GoogleClientId]
        
        assert(clientId != nil, "No app key for DropBox. In Info.plist add \(GoogleClientId) as key and [YourGoogleClientID] as string value")
        
        self.redirectURI = "com.googleusercontent.apps.\(clientId as! NSString):/oauthredirect"
    }
    
    private func verifiesURLSchemes(){
        
        // verifies that the custom URI scheme has been updated in the Info.plist
        let urlTypes : [AnyObject] = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") as! [AnyObject]
        assert(urlTypes.count > 0, "No custom URI scheme has been configured for Google for the project.")
        let urlSchemes : [AnyObject] = urlTypes.first?["CFBundleURLSchemes"] as! [AnyObject]
        assert(urlSchemes.count > 0, "No custom URI scheme has been configured for Google for the project.")
        
        
        var urlScheme : String? = nil
        
        for item in urlSchemes{
            
            if (item as! String).hasPrefix("com.googleusercontent.apps"){
                
                urlScheme = item as? String
                
                break
            }
        }
        
        assert(urlScheme != nil, "Configure the URI scheme in Info.plist (URL Types -> Item 0 -> URL Schemes -> Item 0) and give your client ID e.g: com.googleusercontent.apps.YOUR_CLIENT")

    }
    
    //MARK:Implement protocol
    /**
     Start authorize process
     */
    func authorize(inController:UIViewController){
        
        self.verifiesURLSchemes()
        self.setupClientID()
        self.setupRedirectURL()
        
        if self.loadAuthState(){
            
            if self.startGoogleDriveService(){
                
                if let handler = self.authCompleteHandler{
                    
                    handler(CloudDriveAuthState.Success)
                }
            } else {
                
                if let handler = self.authCompleteHandler{
                    
                    handler(CloudDriveAuthState.Error("Unable to start google dirve service"))
                }
            }
            
            return
        }
        
        let issuerURL = URL(string: self.issuer)
        let redirectURL = URL(string: self.redirectURI)
        
        OIDAuthorizationService.discoverConfiguration(forIssuer: issuerURL!) { configuation, error in
            
            if (configuation == nil) {
                
                self.setAuthorization(auth: nil)
                
                if let handler = self.authCompleteHandler{
                    
                    handler(CloudDriveAuthState.Error("Google service configuration not found"))
                }
                
                return
            }
            
            let authRequest : OIDAuthorizationRequest = OIDAuthorizationRequest.init(configuration: configuation!, clientId: self.clientId, scopes: [OIDScopeOpenID, self.driveScope], redirectURL: redirectURL!, responseType: OIDResponseTypeCode, additionalParameters: nil)
            
            self.authFlow = OIDAuthState.authState(byPresenting: authRequest, presenting: inController, callback: { authState, error in
                
                if authState != nil{
                    
                    #if DEBUG
                        print("google drive access token: \(authState?.lastTokenResponse?.accessToken)")
                    #endif
                    
                    let auth = GTMAppAuthFetcherAuthorization.init(authState: authState!)
                    self.setAuthorization(auth: auth)
                    
                    if self.startGoogleDriveService(){
                        
                        if let handler = self.authCompleteHandler{
                            
                            handler(CloudDriveAuthState.Success)
                        }
                    } else {
                        
                        if let handler = self.authCompleteHandler{
                            
                            handler(CloudDriveAuthState.Error("Unable to start google dirve service"))
                        }
                    }
                    
                } else {
                    
                    self.setAuthorization(auth: nil)
                    
                    if let handler = self.authCompleteHandler{
                        
                        handler(CloudDriveAuthState.Error(error as! String))
                    }
                }
            })
        }
    }
    
    /**
     Get list of data at path
     */
    var underRoot : Bool?
    func contentsWithMetadata(metadata:CloudDriveMetadata?, complete:(([CloudDriveMetadata]?, CloudDriveError?)->())?){
        
        //default is root
        var queryString = "'root' in parents"
        self.underRoot = true
        
        if let meta = metadata{
            
            queryString = (queryString as NSString).replacingOccurrences(of: "root", with: meta.fileId)
            
            self.underRoot = false
        }
        
        let query = GTLQueryDrive.queryForFilesList()
        query?.restrictToMyDrive = true
        query?.includeRemoved = false
        query?.includeDeleted = false
        query?.q = String(format: "%@ and trashed=false", queryString)
        
        self.driveService.executeQuery(query!) { ticket, result, error in
            
            if error != nil{
                
                if let handler = complete{
                    
                    handler(nil, CloudDriveError.CloudDriveInternalError(error as! String))
                }
                
            }
            else {
                
                self.retMetadata = Array<CloudDriveMetadata>()
                
                let fileLists : GTLDriveFileList = result as! GTLDriveFileList
                
                self.processContents(fileLists: fileLists)
                
                if let token = fileLists.nextPageToken {
                    
                    self.getNextContents(query: query, nextPageToken: token, complete: { successful in
                        
                        if successful{
                            
                            if let handler = complete {
                                
                                handler(self.retMetadata, nil)
                            }
                        }
                        else {
                            
                            if let handler = complete{
                                
                                handler(nil, CloudDriveError.CloudDriveInternalError("Can not load conetnts"))
                            }
                        }
                    })
                }
                else {
                    
                    if let handler = complete {
                        
                        handler(self.retMetadata, nil)
                    }
                }
                
                
            }
        }
    }
    
    private func getNextContents(query:GTLQueryDrive?, nextPageToken:String, complete:@escaping (Bool)->()){
        
        query?.pageToken = nextPageToken
        
        self.driveService.executeQuery(query!) { ticket, result, error in
            
            if error != nil{
                
                complete(false)
            }
            else {
                
                let fileLists : GTLDriveFileList = result as! GTLDriveFileList
                
                self.processContents(fileLists: fileLists)
                
                if let token = fileLists.nextPageToken{
                    
                    self.getNextContents(query: query, nextPageToken: token, complete: complete)
                }
                else {
                    
                    complete(true)
                }
            }

        }
    }
    
    private func processContents(fileLists : GTLDriveFileList){
        
        if let list = fileLists.files{
            
            for f in list{
                
                let file : GTLDriveFile = f as! GTLDriveFile
                
                let isFolder = file.mimeType == "application/vnd.google-apps.folder"
                
                let newMetadata = GoogleDriveMetadata(m_fileId: file.identifier, m_folder: isFolder, m_underRootFolder: self.underRoot!, m_name: file.name, m_mimeType: file.mimeType)
                
                self.retMetadata?.append(newMetadata)
                
                #if DEBUG
                    print("file \(file)")
                    print("\n")
                #endif
            }
        }

    }
    
    /**
     Return type of cloud drive
     */
    func driveType() -> CloudDriveType{
        
        return .GoogleDrive
    }
    
    /**
     Return type of cloud drive in string
     */
    func driveTypeString() -> String{
        
        return "GoogleDrive"
    }
    
    /**
     Return root path
     */
    func rootPath() -> String{
        
        return "'root' in parents"
    }
    
    /**
     Return a new download task
     */
    func createDownloadTask(metadata:CloudDriveMetadata, localPath:String) -> CloudDriveDownloadTask{
        
        
        let download = GoogleDriveDownload(file_ID:metadata.fileId, file_name:metadata.name, type: .GoogleDrive, path: "", localPath: localPath)
        
        download.driveService = self.driveService
        download.mimetype = (metadata as! GoogleDriveMetadata).mimeType
        
        return download
    }
    
    /**
     Logout
     */
    func logout(){
        
        self.setAuthorization(auth: nil)
    }
    
    //MARK:Override from CloudDrive
    override func handleRedirect(url:URL){
        
        // Sends the URL to the current authorization flow (if any) which will process it if it relates to
        // an authorization response.
        if let flow = self.authFlow{
            
            (flow as! OIDAuthorizationFlowSession).resumeAuthorizationFlow(with: url)
            self.authFlow = nil
        }
    }
    
    override func cloudName() -> String{
        
        return "Google"
    }
    
    //MARK: Google authorization delegate
    func didChange(_ state: OIDAuthState) {
        
        self.saveAuthState()
    }
    
    func authState(_ state: OIDAuthState, didEncounterAuthorizationError error: Error) {
        
        if let handler = authCompleteHandler{
            
            handler(CloudDriveAuthState.Error(error as! String))
        }
    }
}

//MARK:GoogleDriveMetadata class
class GoogleDriveMetadata : CloudDriveMetadata{
    
    var mimeType : String
    
    init(m_fileId: String, m_folder: Bool, m_underRootFolder: Bool, m_name: String, m_mimeType: String) {
        
        self.mimeType = m_mimeType
        
        super.init(m_fileId: m_fileId, m_folder: m_folder, m_underRootFolder: m_underRootFolder, m_name: m_name)
    }
}

//MARK:GoogleDriveDownload class
class GoogleDriveDownload : CloudDriveDownloadTask, CloudDriveDownloadProtocol{
    
    weak var driveService : GTLServiceDrive?
    var mimetype : String?
    private var fetcher : GTMSessionFetcher?
    
    /**
     These mimetype of file need to convert to pdf when download
    */
    private var googleConvertableMimetypes = ["application/vnd.google-apps.document",
                                              "application/vnd.google-apps.presentation",
                                              "application/vnd.google-apps.spreadsheet"]
    
    deinit {
        
        self.fetcher?.stopFetching()
        self.fetcher = nil
        
    }
    
    override func driveTypeString() -> String{
        
        return "GoogleDrive"
    }
    
    func startDownload(){
        
        if self.fetcher != nil{
            self.fetcher?.stopFetching()
            self.fetcher = nil
        }
        
        var fileURLStr = ""
        
        if googleConvertableMimetypes.contains(self.mimetype!){
            
            //we need to convert to pdf says by Google
            fileURLStr = String(format: "https://www.googleapis.com/drive/v3/files/%@/export?alt=media&mimeType=application/pdf", self.fileId)
        }
        else {
            
            fileURLStr = String(format: "https://www.googleapis.com/drive/v3/files/%@?alt=media", self.fileId)
        }
        
        self.fetcher = driveService?.fetcherService.fetcher(withURLString: fileURLStr)
        self.fetcher?.destinationFileURL = URL(fileURLWithPath: self.filePathAtLocal)
        
        self.fetcher?.downloadProgressBlock = {bytesWritten, totalBytesWritten, totalBytesExpectedToWrite in
        
            self.status = .Downloading
            
            if (self.fetcher?.response?.expectedContentLength)! <= -1{
                
                self.downloadProgress = -1
            }
            else {
               
                self.downloadProgress = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
            }
            
            
            
            if let handler = self.onDownloadReceiveData{
                
                handler(self, self.downloadProgress)
            }
        }
        
        //begin download data
        self.fetcher?.beginFetch(completionHandler: { data, error in
            
            if error != nil{
                
                self.status = .Error
                
                if let handler = self.onDownloadError{
                    
                    handler(self, CloudDriveError.CloudDriveDownloadError(error as! String))
                }
            }
            else {
                
                self.status = .Complete
                self.downloadProgress = 1.0
                
                if let handler = self.onDownloadComplete{
                    
                    handler(self)
                    
                    self.fetcher = nil
                }
            }
        })
    }
    
    func cancelDownload() {
        
        self.fetcher?.stopFetching()
        self.status = .Cancel
        self.fetcher = nil
        
        if let handler = self.onDownloadCancel{
            
            handler(self)
        }
    }
}
