//
//  AppDelegate.swift
//  jexam
//
//  Created by Philipp Matthes on 11.07.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import UIKit
import UserNotifications
import Material

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let loginController = LoginController()
        let navigationController = AppNavigationController(rootViewController: loginController)
        
        window = UIWindow(frame: Screen.bounds)
        window!.rootViewController = navigationController
        window!.makeKeyAndVisible()
        
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (permissionGranted, error) in
        }
        UNUserNotificationCenter.current().delegate = self

        return true
    }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        let dispatchGroup = DispatchGroup()
        var newData = false
        
        let serialQueue = DispatchQueue(label: "background-queue-jexam", qos: .background)
        
        for tracker in Changelog.trackedLectures {
            dispatchGroup.enter()
            JExam.availableEnrollmentCandidates(forLecture: tracker.lecture.id, queue: serialQueue) {
                candidatesResponse in
                if let candidates = candidatesResponse?.candidates {
                    let notificationContents = tracker.notificationContents(comparing: candidates)
                    if notificationContents.count != 0 {
                        newData = true
                    }
                    self.send(notificationContents: notificationContents)
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.wait()
        
        completionHandler(newData ? .newData : .noData)
    }


}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func send(notificationContents: [UNMutableNotificationContent]) {
        for content in notificationContents {
            DispatchQueue.main.async {
                UIApplication.shared.applicationIconBadgeNumber += 1
            }
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
            let requestIdentifier = "notificationIdentifier"
            let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) {
                error in
            }
        }
    }
    
}

