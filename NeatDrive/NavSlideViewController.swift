//
//  NavSlideViewController.swift
//  NeatDrive
//
//  Created by Nelson on 1/6/17.
//  Copyright © 2017 Nelson. All rights reserved.
//

import Foundation
import UIKit

class NavSlideViewController : UIViewController{
    
    @IBOutlet weak var prviousButton : UIButton?
    @IBOutlet weak var nextButton : UIButton?
    
    var onPrevious : ((NavSlideViewController) -> ())?
    var onNext : ((NavSlideViewController) -> ())?
    
    private var slideIndex : Int = 0
    var index : Int{
        
        get{
            
            return self.slideIndex
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.prviousButton?.isHidden = true
        self.nextButton?.isHidden = true
    }
    
    func configureIndex(index:Int, hasPrevious:Bool, hasNext:Bool){
        
        self.slideIndex = index
        
        self.nextButton?.isHidden = !hasNext
        self.prviousButton?.isHidden = !hasPrevious
        
        self.nextButton?.removeTarget(self, action: #selector(NavSlideViewController.nextTap), for: .touchUpInside)
        self.prviousButton?.removeTarget(self, action: #selector(NavSlideViewController.prviousTap), for: .touchUpInside)
        
        if hasNext{
            
            self.nextButton?.addTarget(self, action: #selector(NavSlideViewController.nextTap), for: .touchUpInside)
        }
        
        if hasPrevious{
            
            self.prviousButton?.addTarget(self, action: #selector(NavSlideViewController.prviousTap), for: .touchUpInside)
        }
    }
    
    func prviousTap(){
        
        if self.onPrevious != nil{
            
            self.onPrevious!(self)
        }
    }
    
    func nextTap(){
        
        if self.onNext != nil{
            
            self.onNext!(self)
        }
    }
}
