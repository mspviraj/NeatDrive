//
//  LocalFileMetadata.swift
//  NeatDrive
//
//  Created by Nelson on 1/9/17.
//  Copyright © 2017 Nelson. All rights reserved.
//

import Foundation



struct LocalFileMetadata {
    
    private static let byteFormatter = ByteCountFormatter()
    private static let dateFormatter = DateFormatter()
    
    private let fileURL : URL
    
    var FileURL : URL{
        
        get{
            
            return self.fileURL
        }
    }
    
    var FilePath : String{
        
        get{
            
            return self.fileURL.path
        }
    }
    
    private let fileSize : UInt64
    
    var FileSize : UInt64{
        
        get{
            
            return self.fileSize
        }
    }
    
    var FileSizeString : String{
        
        get{
            
            LocalFileMetadata.byteFormatter.countStyle = .decimal
            LocalFileMetadata.byteFormatter.includesCount = true
            LocalFileMetadata.byteFormatter.includesUnit = true
            
            return LocalFileMetadata.byteFormatter.string(fromByteCount: Int64(self.fileSize))
        }
    }
    
    private let createDate : Date?
    
    var CreateDate : Date?{
        
        get{
            
            if self.createDate  == nil{
                
                return nil
            }
            
            return self.createDate
        }
    }
    
    var CreateDateString : String?{
        
        get{
            
            if self.createDate  == nil{
                
                return nil
            }
            
            LocalFileMetadata.dateFormatter.dateStyle = .long
            LocalFileMetadata.dateFormatter.timeStyle = .medium
            
            return LocalFileMetadata.dateFormatter.string(from: self.createDate!)
        }
    }
    
    private let modifyDate : Date?
    
    var ModifyDate : Date?{
        
        get{
            
            if self.modifyDate  == nil{
                
                return nil
            }
            
            return self.modifyDate
        }
    }
    
    var ModifyDateString : String?{
        
        get{
            
            if self.modifyDate  == nil{
                
                return nil
            }
            
            LocalFileMetadata.dateFormatter.dateStyle = .long
            LocalFileMetadata.dateFormatter.timeStyle = .medium
            
            return LocalFileMetadata.dateFormatter.string(from: self.modifyDate!)
        }
    }
    
    private let filename : String
    
    var FileName : String{
        
        return self.filename
    }
    
    var FileExtension : String{
        
        return (self.filename as NSString).pathExtension
    }
    
    private let isFolder : Bool
    
    var IsFolder : Bool{
    
        get{
            
            return self.isFolder
        }
    }
    
    private let metadataId : NSUUID = NSUUID()
    
    var MetadataID : NSUUID{
        
        get{
            
            return self.metadataId
        }
    }
    
    init(_fileURL:URL, _fileSize:UInt64, _createDate:Date?, _modifyDate:Date?, _filename:String, _isFolder:Bool){
        
        self.fileURL = _fileURL
        self.fileSize = _fileSize
        self.createDate = _createDate
        self.modifyDate = _modifyDate
        self.filename = _filename
        self.isFolder = _isFolder
    }
    
    func isEqualTo(metaData : LocalFileMetadata) -> Bool{
        
        return self.metadataId.uuidString == metaData.MetadataID.uuidString
    }
}
