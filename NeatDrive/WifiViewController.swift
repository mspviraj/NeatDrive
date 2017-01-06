//
//  WifiViewController.swift
//  NeatDrive
//
//  Created by Nelson on 1/6/17.
//  Copyright © 2017 Nelson. All rights reserved.
//

import Foundation
import UIKit

class WifiViewController : UIPageViewController, UIPageViewControllerDataSource{
    
    var slideControllers : [NavSlideViewController]?
    var currentSlideIndex : Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pageControl = UIPageControl.appearance()
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = UIColor.blue
        
        self.dataSource = self
        
        let onPrevious : (NavSlideViewController)->() = { (slide : NavSlideViewController) in
            
            let curIndex = self.slideControllers?.index(of: slide)
            
            if curIndex == 0{
                
                return
            }
            
            let newIndex = curIndex! - 1
            
            self.currentSlideIndex = newIndex
            
            let controller : UIViewController = (self.slideControllers?[newIndex])!
            
            self.setViewControllers([controller], direction: .reverse, animated: true, completion: { finished in
                
                (controller as! NavSlideViewController).configureIndex(index: newIndex, hasPrevious:  newIndex == 0 ? false : true, hasNext: newIndex == ((self.slideControllers?.count)! - 1) ? false : true)
            })
        }
        
        let onNext : (NavSlideViewController)->() = { (slide : NavSlideViewController) in
            
            let curIndex = self.slideControllers?.index(of: slide)
            
            if curIndex! == ((self.slideControllers?.count)! - 1){
                
                return
            }
            
            let newIndex = curIndex! + 1
            
            self.currentSlideIndex = newIndex
            
            let controller : UIViewController = (self.slideControllers?[newIndex])!
            
            self.setViewControllers([controller], direction: .forward, animated: true, completion: { finished in
                
                (controller as! NavSlideViewController).configureIndex(index: newIndex, hasPrevious: newIndex == 0 ? false : true, hasNext: newIndex == ((self.slideControllers?.count)! - 1) ? false : true)
            })
        }
        
        slideControllers = [
        
            self.storyboard?.instantiateViewController(withIdentifier: "WifiFirstSlide") as! NavSlideViewController,
            self.storyboard?.instantiateViewController(withIdentifier: "WifiSecondSlide") as! NavSlideViewController,
            self.storyboard?.instantiateViewController(withIdentifier: "WifiThirdSlide") as! NavSlideViewController
        ]
        
        
        for controller in self.slideControllers!{
            
            controller.onPrevious = onPrevious
            controller.onNext = onNext
        }
        
        
        let controller : UIViewController = (self.slideControllers?[0])!
        self.setViewControllers([controller], direction: .forward, animated: true, completion: { finished in
            
            (controller as! NavSlideViewController).configureIndex(index: 0, hasPrevious: false, hasNext: 0 == ((self.slideControllers?.count)! - 1) ? false : true)
        })
        
        for subView in self.view.subviews{
            
            if let scrollview = subView as? UIScrollView{
                
                scrollview.isScrollEnabled = false
            }
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let index = self.slideControllers?.index(of: (viewController as! NavSlideViewController))
        
        if index == 0{
            
            return nil
        }
        else {
            
            return self.slideControllers?[index! - 1]
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        let index = self.slideControllers?.index(of: (viewController as! NavSlideViewController))
        
        if index! == ((self.slideControllers?.count)! - 1){
            
            return nil
        }
        else {
            
            return self.slideControllers?[index! + 1]
        }
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        
        return (self.slideControllers?.count)!
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        
        return self.currentSlideIndex
    }
}
