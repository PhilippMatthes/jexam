//
//  Changelog.swift
//  jexam
//
//  Created by Philipp Matthes on 12.07.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import UserNotifications

class Changelog {
    
    static var trackedLectures: [Tracker] {
        get {
            guard
                let data = UserDefaults.standard.object(forKey: "trackedLectures") as? Data,
                let lectures = try? PropertyListDecoder().decode(Array<Tracker>.self, from: data)
            else {return [Tracker]()}
            return lectures
        }
        set {
            guard let encodedData = try? PropertyListEncoder().encode(newValue) else {return}
            UserDefaults.standard.set(encodedData, forKey: "trackedLectures")
        }
    }
    
    static func add(_ tracker: Tracker) {
        var trackers = trackedLectures
        trackers.append(tracker)
        trackedLectures = trackers
    }
    
    static func update(_ tracker: Tracker) {
        var trackers = trackedLectures
        for (i, t) in trackedLectures.enumerated() {
            if tracker.lecture.id == t.lecture.id {
                trackers[i] = tracker
            }
        }
        trackedLectures = trackers
    }
    
    static func tracks(lectureId id: Int) -> Bool {
        for tracker in trackedLectures {
            if tracker.lecture.id == id {return true}
        }
        return false
    }
    
    static func remove(lectureId id: Int) {
        for (i, t) in trackedLectures.enumerated() {
            if t.lecture.id == id {
                var trackers = trackedLectures
                trackers.remove(at: i)
                trackedLectures = trackers
            }
        }
    }
    
    static func tracker(forLectureId id: Int, hasChangedComparing candidates: [EnrollmentCandidate]) -> Bool {
        for tracker in trackedLectures {
            if tracker.lecture.id == id {
                return tracker.hasChanged(comparing: candidates)
            }
        }
        return false
    }
}
