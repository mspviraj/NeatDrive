//
//  AppDelegate.swift
//  NeatDrive
//
//  Created by Nelson on 12/28/16.
//  Copyright © 2016 Nelson. All rights reserved.
//

import UIKit
import LTHPasscodeViewController

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //customize navigation bar
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().barTintColor = UIColor(netHex: 0xeb5a27)
        
        let attributes : [String:AnyObject] = [
            NSForegroundColorAttributeName:UIColor.white,
            NSFontAttributeName: UIFont(name: "Lato-Regular", size: 21)!
        ]
        
        UINavigationBar.appearance().titleTextAttributes = attributes
        
        //init system folder manager
        _ = SystemFolderManager.shareInstance
        
        //passcode check
        let dispatchTime = DispatchTime.now() + .seconds(0)
        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
            
            if LTHPasscodeViewController.doesPasscodeExist(){
                
                LTHPasscodeViewController.sharedUser().hidesCancelButton = true
                LTHPasscodeViewController.sharedUser().showLockScreen(withAnimation: true, withLogout: false, andLogoutTitle: nil)
            }
        }
        
        
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        CloudDriveManager.shareInstance.handleRedirect(url: url)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        if LTHPasscodeViewController.doesPasscodeExist(){
            
            LTHPasscodeViewController.sharedUser().enablePasscodeWhenApplicationEntersBackground()
        }
        else {
            
            LTHPasscodeViewController.sharedUser().disablePasscodeWhenApplicationEntersBackground()
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

