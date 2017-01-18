//
//  MoveFileCell.swift
//  NeatDrive
//
//  Created by Nelson on 1/18/17.
//  Copyright © 2017 Nelson. All rights reserved.
//

import Foundation
import UIKit

class MoveFileCell : UITableViewCell{
    
    let lineWidth = 3
    let lineColor = UIColor.black
    let indentLineLayer = CAShapeLayer()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.indentationLevel > 0{
            
            indentLineLayer.removeFromSuperlayer()
            
            indentLineLayer.bounds = CGRect(x: 0, y: 0, width: CGFloat(self.indentationLevel) * self.indentationWidth, height: self.contentView.frame.height)
            
            let linePath = UIBezierPath()
            linePath.move(to: CGPoint(x: 0, y: 0))
            linePath.addLine(to: CGPoint(x: 0, y: indentLineLayer.bounds.height))
            linePath.move(to: CGPoint(x: 0, y: indentLineLayer.bounds.height/2))
            linePath.addLine(to: CGPoint(x: indentLineLayer.bounds.width, y: indentLineLayer.bounds.height/2))
            indentLineLayer.path = linePath.cgPath
            
            indentLineLayer.position = CGPoint(x: (self.textLabel?.frame.origin.x)! - indentLineLayer.bounds.width/2, y: indentLineLayer.bounds.height/2)
            indentLineLayer.fillColor = nil
            indentLineLayer.lineWidth = CGFloat(lineWidth)
            indentLineLayer.strokeColor = lineColor.cgColor
            
            self.contentView.layer.addSublayer(indentLineLayer)
        }
    }
}
