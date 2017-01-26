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

public func snapshotOfView(inView : UIView, afterScreenUpdate : Bool) -> UIView{
    
    UIGraphicsBeginImageContextWithOptions(inView.bounds.size, false, UIScreen.main.scale)
    
    inView.drawHierarchy(in: inView.bounds, afterScreenUpdates: afterScreenUpdate)
    
    let image = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    
    let snapshot = UIView()
    snapshot.bounds = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
    snapshot.addSubview(UIImageView(image: image))
    
    return snapshot
}

public func imageWithBottomShadow(size:CGSize, imageColor:UIColor, shadowColor:UIColor, shadowHeight:CGFloat) -> UIImage{
    
    let view : UIView = UIView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
    let shadowLayer = CAShapeLayer()
    shadowLayer.frame = CGRect(x:0 , y: size.height - shadowHeight, width: size.width, height: shadowHeight)
    shadowLayer.backgroundColor = shadowColor.cgColor
    view.backgroundColor = imageColor
    view.layer.addSublayer(shadowLayer)
    
    UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
    
    view.layer.render(in: UIGraphicsGetCurrentContext()!)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    
    UIGraphicsEndImageContext()
    
    return image!
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}

extension UITableViewCell {
    func shake(duration: CFTimeInterval = 0.3, pathLength: CGFloat = 15) {
        let position: CGPoint = self.center
        
        let path: UIBezierPath = UIBezierPath()
        path.move(to: CGPoint(x: position.x, y: position.y))
        path.addLine(to: CGPoint(x:position.x-pathLength, y: position.y))
        path.addLine(to: CGPoint(x:position.x+pathLength, y:position.y))
        path.addLine(to: CGPoint(x:position.x-pathLength, y:position.y))
        path.addLine(to: CGPoint(x:position.x+pathLength, y:position.y))
        path.addLine(to: CGPoint(x:position.x, y:position.y))
        
        let positionAnimation = CAKeyframeAnimation(keyPath: "position")
        
        positionAnimation.path = path.cgPath
        positionAnimation.duration = duration
        positionAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        CATransaction.begin()
        self.layer.add(positionAnimation, forKey: nil)
        CATransaction.commit()
    }
}
