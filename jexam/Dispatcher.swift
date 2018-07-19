//
//  NotificationCenter.swift
//  jexam
//
//  Created by Philipp Matthes on 19.07.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit

struct NotificationContent: Codable {
    let title: String
    let subtitle: String
    let body: String
    let important: Bool
    let tracker: Tracker
    
    func asUNMutableNotificationContent() -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.body = body
        content.sound = important ? UNNotificationSound.defaultCritical : UNNotificationSound.default
        content.categoryIdentifier = important ? "important" : "unimportant"
        return content
    }
    
    private enum CodingKeys: String, CodingKey {
        case title = "title"
        case subtitle = "subtitle"
        case body = "body"
        case important = "important"
        case tracker = "tracker"
    }
}

class Dispatcher {
    static var notificationContents: [NotificationContent] {
        get {
            guard
                let data = UserDefaults.standard.object(forKey: "notifications") as? Data,
                let notifications = try? PropertyListDecoder().decode(Array<NotificationContent>.self, from: data)
                else {return [NotificationContent]()}
            return notifications
        }
        set {
            guard let encodedData = try? PropertyListEncoder().encode(newValue) else {return}
            UserDefaults.standard.set(encodedData, forKey: "notifications")
        }
    }
    
    static func dispatch(_ notificationContents: [NotificationContent]) {
        self.notificationContents += notificationContents
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = self.notificationContents.count
            for content in notificationContents {
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                
                let requestIdentifier = "notificationIdentifier"
                let request = UNNotificationRequest(identifier: requestIdentifier, content: content.asUNMutableNotificationContent(), trigger: trigger)
                
                UNUserNotificationCenter.current().add(request) {
                    error in
                }
            }
        }
    }
    
    static func userHasSeen(_ notificationContents: [NotificationContent]) {
        for notification in notificationContents {
            remove(notification)
        }
    }
    
    static func remove(_ notificationContent: NotificationContent) {
        var tempContents = self.notificationContents
        search: for (i, notification) in self.notificationContents.enumerated() {
            if notification.tracker.lecture.id == notificationContent.tracker.lecture.id {
                tempContents.remove(at: i)
                break search
            }
        }
        self.notificationContents = tempContents
    }
    
    static func removeAll() {
        self.notificationContents = [NotificationContent]()
    }
    
}
