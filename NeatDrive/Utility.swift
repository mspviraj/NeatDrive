//
//  Utility.swift
//  NeatDrive
//
//  Created by Nelson on 1/3/17.
//  Copyright © 2017 Nelson. All rights reserved.
//

import Foundation


public func deviceRemainingFreeSpaceInBytes() -> Int64? {
    let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
    guard
        let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: documentDirectory),
        let freeSize = systemAttributes[.systemFreeSize] as? NSNumber
        else {
            // something failed
            return nil
    }
    return freeSize.int64Value
}

public func deviceTotalSpaceInBytes() -> Int64? {
    let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
    guard
        let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: documentDirectory),
        let freeSize = systemAttributes[.systemSize] as? NSNumber
        else {
            // something failed
            return nil
    }
    return freeSize.int64Value
}

public struct ByteStringOption : OptionSet{
    
    public let rawValue : Int
    
    static let Number = ByteStringOption(rawValue: 1<<0)
    static let Unit = ByteStringOption(rawValue: 1<<1)
    
    public init(rawValue:Int){
        
        self.rawValue = rawValue
    }
}

private let byteFormatter = ByteCountFormatter()

public func stringFromByte(byte:Int64?, displayOptions:ByteStringOption) -> String{
    
    if let byt = byte{
        
        byteFormatter.countStyle = .decimal
        byteFormatter.includesCount = false
        byteFormatter.includesUnit = false
        
        if displayOptions.contains(.Number){
            
            byteFormatter.includesCount = true
        }
        
        if displayOptions.contains(.Unit){
            
            byteFormatter.includesUnit = true
        }
        
        return byteFormatter.string(fromByteCount: byt)
    }
    
    return "Unkonw"
    
}

public func documentPath() -> String{
    
    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    
    return documentsPath
}
