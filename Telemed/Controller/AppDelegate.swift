//
//  AppDelegate.swift
//  Telemed
//
//  Created by Macbook on 12/22/18.
//  Copyright © 2018 drsocgr14. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import RealmSwift
import AppCenter
import AppCenterAnalytics
import AppCenterCrashes

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var loginStatus = false
    var language = "english"
    
    let server = Credentials.server
    
    let defaults = UserDefaults.standard
    
    enum KeychainError: Error {
        case noPassword
        case unexpectedPasswordData
        case unhandledError(status: OSStatus)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        MSAppCenter.start("40f2a167-a199-4b01-ac8e-bf43c32e2104", withServices:[ MSAnalytics.self, MSCrashes.self ])
        
        // Override point for customization after application launch.
//        FirebaseApp.configure()
        
//        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
//                                    kSecAttrServer as String: server,
//                                    kSecMatchLimit as String: kSecMatchLimitOne,
//                                    kSecReturnAttributes as String: true,
//                                    kSecReturnData as String: true]
//
//        var item: CFTypeRef?
//        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
//        do {
//            guard status != errSecItemNotFound else { throw KeychainError.noPassword }
//            guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
//            guard let existingItem = item as? [String : Any],
//                let passwordData = existingItem[kSecValueData as String] as? Data,
//                let password = String(data: passwordData, encoding: String.Encoding.utf8),
//                let account = existingItem[kSecAttrAccount as String] as? String
//                else {
//                    throw KeychainError.unexpectedPasswordData
//                }
//            let credentials = Credentials(username: account, password: password)
//            loginInfo["username"] = credentials.username
//            loginInfo["password"] = credentials.password
//        } catch {
//            print(error)
//        }
        
        
        let realm = try! Realm()
//
//        let newTracker = Trackers()
//        newTracker.name = "test2"
//        let anotherTracker = Trackers()
//        anotherTracker.name = "test1"
//        do {
//            try realm.write {
//                realm.add(newTracker)
//                realm.add(anotherTracker)
//            }
//        } catch {
//            print("Error adding tracker \(error)")
//        }

        print(realm.configuration.fileURL!)
        
        loginStatus = defaults.bool(forKey: "loginStatus")
        language = defaults.string(forKey: "language") ?? "english"

        let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewControlleripad : UIViewController = mainStoryboardIpad.instantiateViewController(withIdentifier: "rootView") as! RootViewController
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = initialViewControlleripad
        self.window?.makeKeyAndVisible()
        
        if !loginStatus {
            let mainLoginVC: UIViewController = mainStoryboardIpad.instantiateViewController(withIdentifier: "login")
            mainLoginVC.modalPresentationStyle = .fullScreen
            initialViewControlleripad.present(mainLoginVC, animated: false)
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
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
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Telemed")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

