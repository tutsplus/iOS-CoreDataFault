//
//  AppDelegate.swift
//  Faulting
//
//  Created by Bart Jacobs on 30/10/15.
//  Copyright © 2015 Envato Tuts+. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {

        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        // Instantiate Root Navigation Controller
        let rootNavigationController = mainStoryboard.instantiateViewController(withIdentifier: "StoryboardIDRootNavigationController") as! UINavigationController
        
        // Configure View Controller
        if let listsViewController = rootNavigationController.topViewController as? ListsViewController {
            listsViewController.managedObjectContext = self.managedObjectContext
        }
        
        // Configure Window
        window?.rootViewController = rootNavigationController
        
        return true
        
    }

    func applicationWillResignActive(_ application: UIApplication) {}
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        saveManagedObjectContext()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {}
    
    func applicationDidBecomeActive(_ application: UIApplication) {}
    
    func applicationWillTerminate(_ application: UIApplication) {
        saveManagedObjectContext()
    }

    // MARK: -
    // MARK: Core Data Stack
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "Faulting", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let persistentStoreCoordinator = self.persistentStoreCoordinator
        
        // Initialize Managed Object Context
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        
        // Configure Managed Object Context
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        
        return managedObjectContext
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // Initialize Persistent Store Coordinator
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        // URL Documents Directory
        let URLs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let applicationDocumentsDirectory = URLs[(URLs.count - 1)]
        
        // URL Persistent Store
        let URLPersistentStore = applicationDocumentsDirectory.appendingPathComponent("Faulting.sqlite")
        
        do {
            // Add Persistent Store to Persistent Store Coordinator
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: URLPersistentStore, options: nil)
            
        } catch {
            // Populate Error
            var userInfo = [String: AnyObject]()
            userInfo[NSLocalizedDescriptionKey] = "There was an error creating or loading the application's saved data." as AnyObject
            userInfo[NSLocalizedFailureReasonErrorKey] = "There was an error creating or loading the application's saved data." as AnyObject
            
            userInfo[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "com.tutsplus.Faulting", code: 1001, userInfo: userInfo)
            
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            
            abort()
        }
        
        return persistentStoreCoordinator
    }()
    
    // MARK: -
    // MARK: Helper Methods
    private func saveManagedObjectContext() {
        do {
            try self.managedObjectContext.save()
        } catch {
            let saveError = error as NSError
            print("\(saveError), \(saveError.userInfo)")
        }
    }

}

