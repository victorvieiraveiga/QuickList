//
//  AppDelegate.swift
//  TodoList
//
//  Created by Victor Vieira Veiga on 07/10/20.
//  Copyright © 2020 Victor Vieira Veiga. All rights reserved.
//

import UIKit
import RealmSwift
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //print (Realm.Configuration.defaultConfiguration.fileURL)
        
        
        do {
            _ = try Realm()
            
        } catch  {
            print ("Error initialising new realm\(error)")
        }
        
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        return true
    }

}

