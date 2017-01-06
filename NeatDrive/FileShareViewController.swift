//
//  FileShareViewController.swift
//  NeatDrive
//
//  Created by Nelson on 1/3/17.
//  Copyright © 2017 Nelson. All rights reserved.
//

import Foundation
import BetterSegmentedControl

class FileShareViewController : SlidableViewController{
    
    
    @IBOutlet weak var segment : BetterSegmentedControl?
    
    weak var containerController : ContainerViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "File Share"
        
        var titles : [String] = Array<String>()
        
        for data in ContainerViewController.seuges{
            
            titles.append(data.title)
        }
        
        self.segment?.titles = titles
        self.segment?.addTarget(self, action: #selector(FileShareViewController.segmentChangeIndex(segment:)), for: .valueChanged)
        
        do {
            try self.segment?.set(index: 1)
        } catch  {
            print("Error setting segment control index")
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.disablePanGesture()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "EmbedSegue"{
        
            self.containerController = segue.destination as? ContainerViewController
        }
    }

    func segmentChangeIndex(segment: BetterSegmentedControl){
        
        let data = ContainerViewController.seuges[Int(segment.index)]
        
        self.containerController?.swapViewControllerWithSegueIdentifier(segueId: data.sugueId)
    }
}
