//
//  CircleView.swift
//  NeatDrive
//
//  Created by Nelson on 1/11/17.
//  Copyright © 2017 Nelson. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class CircleView : UIView{
    
    private let ringLayer = CAShapeLayer()
    private let circleLayer = CAShapeLayer()
    
    @IBInspectable var margin : CGFloat = 0
    @IBInspectable var outterRingWith : CGFloat = 5
    @IBInspectable var innerGap : CGFloat = 3
    
    
    var isSelect : Bool = false{
        
        didSet{
            
            self.circleLayer.isHidden = !isSelect
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let radius: CGFloat = self.bounds.width - self.margin
        
        
        let outterRingPath = UIBezierPath(roundedRect: CGRect(x: margin, y: margin, width: radius - margin, height: radius - margin)  , cornerRadius: radius)
        let innerRingPath = UIBezierPath(roundedRect: CGRect(x: margin+self.outterRingWith, y: margin+self.outterRingWith, width: radius - self.outterRingWith*2 - margin, height: radius - self.outterRingWith*2 - margin), cornerRadius: radius)
        
        outterRingPath.append(innerRingPath)
        outterRingPath.usesEvenOddFillRule = true
        
        
        self.ringLayer.path = outterRingPath.cgPath
        self.ringLayer.position = CGPoint(x: 0, y: 0)
        self.ringLayer.fillRule = kCAFillRuleEvenOdd
        self.ringLayer.fillColor = UIColor.red.cgColor
        self.layer.addSublayer(self.ringLayer)
        
        self.circleLayer.path = UIBezierPath(roundedRect: CGRect(x: margin+self.outterRingWith+self.innerGap, y: margin+self.outterRingWith+self.innerGap, width: radius - self.outterRingWith*2 - self.innerGap*2 - margin, height: radius - self.outterRingWith*2 - self.innerGap*2 - margin), cornerRadius: radius).cgPath
        self.circleLayer.position = CGPoint(x: 0, y: 0)
        self.circleLayer.fillColor = UIColor.red.cgColor
        self.layer.addSublayer(self.circleLayer)
        
        self.circleLayer.isHidden = !self.isSelect
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        self.layoutSubviews()
    }
}
