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
        
        // 30 min
        application.setMinimumBackgroundFetchInterval(1800)
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (permissionGranted, error) in
        }
        UNUserNotificationCenter.current().delegate = self

        return true
    }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        NSLog("Performing background fetch for the following lectures: [\(Changelog.trackedLectures.map {$0.lectureName}.joined(separator: ", "))].")
        
        let dispatchGroup = DispatchGroup()
        var newData = false
        var c = [EnrollmentCandidate]()
        
        let serialQueue = DispatchQueue(label: "background-queue-jexam", qos: .background)
        
        for tracker in Changelog.trackedLectures {
            dispatchGroup.enter()
            JExam.availableEnrollmentCandidates(forLecture: tracker.lectureId, queue: serialQueue) {
                candidatesResponse in
                if let candidates = candidatesResponse?.candidates {
                    c.append(contentsOf: candidates)
                    NSLog("Downloaded enrollment candidates for \(tracker.lectureName) \(tracker.lectureId): \(candidates)")
                    if Changelog.tracker(forLectureId: tracker.lectureId, hasChangedComparing: candidates) {
                        NSLog("Changes in enrollment candidates detected!")
                        newData = true
                        let title = "\(tracker.lectureName) changed!"
                        let infoText = "\(tracker.lectureName) now has \(candidates.count) enrollment options:\n\n" + candidates.map {"\($0.lectureType) \($0.name) on Weekday: \($0.timeInfo.weekday.description()) - \($0.room?.building.abbreviation ?? "") \($0.room?.roomNo ?? "")\n"} .joined(separator: "")
                        self.sendNotification(title: title, infoText: infoText)
                        Changelog.update(LectureTracker(lectureName: tracker.lectureName, lectureId: tracker.lectureId, enrollmentCandidateIds: candidates.map {$0.id}))
                        
                    }
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.wait()
        
        if !newData && Changelog.notifyAboutBackgroundFetchEvents {
            let title = "Background Fetch"
            let infoText = "Performed background fetch for \(Changelog.trackedLectures.map {$0.lectureName}.joined(separator: ", ")) and found the following enrollment candidates: \n\n " + c.map {"\($0.lectureType) \($0.name) on Weekday: \($0.timeInfo.weekday.description()) - \($0.room?.building.abbreviation ?? "") \($0.room?.roomNo ?? "")\n"} .joined(separator: "")
            sendNotification(title: title, infoText: infoText)
        }
        
        completionHandler(newData ? .newData : .noData)
    }


}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func sendNotification(title: String, infoText: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = infoText
        UIApplication.shared.applicationIconBadgeNumber += 1
        content.categoryIdentifier = "notification"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let requestIdentifier = "notificationIdentifier"
        let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) {
            error in
        }
    }
    
}

