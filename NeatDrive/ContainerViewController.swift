//
//  ContainerViewController.swift
//  NeatDrive
//
//  Created by Nelson on 1/5/17.
//  Copyright © 2017 Nelson. All rights reserved.
//

import Foundation
import UIKit

public struct SegueData {
    
    let title : String
    let sugueId: String
}

class ContainerViewController : UIViewController{
    
    static let seuges : [SegueData] = [
        SegueData(title: "Bluetooth", sugueId: "Bluetooth"),
        SegueData(title: "Wifi", sugueId: "Wifi")
    ]
    
    private func swapViewController(from:UIViewController, to:UIViewController){
        
        to.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        
        from.willMove(toParentViewController: nil)
        self.addChildViewController(to)
        self.transition(from: from, to: to, duration: 0, options: .transitionCrossDissolve, animations: nil) { finished in
            
            from.removeFromParentViewController()
            to.didMove(toParentViewController: self)
        }
    }
    
    func swapViewControllerWithSegueIdentifier(segueId:String){
        
        self.performSegue(withIdentifier: segueId, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if self.childViewControllers.count == 0{
            
            segue.destination.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            
            self.addChildViewController(segue.destination)
            self.view.addSubview(segue.destination.view)
            segue.destination.didMove(toParentViewController: self)
        }
        else {
            
            self.swapViewController(from: self.childViewControllers[0], to: segue.destination)
        }
    }
    
}
