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
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = Dispatcher.notificationContents.count
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = Dispatcher.notificationContents.count
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
                    Dispatcher.dispatch(notificationContents)
                    let updatedTracker = Tracker(lecture: tracker.lecture, enrollmentCandidates: candidates)
                    Changelog.update(updatedTracker)
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.wait()
        
        completionHandler(newData ? .newData : .noData)
    }


}

