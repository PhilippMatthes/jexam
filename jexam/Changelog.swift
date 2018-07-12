//
//  Changelog.swift
//  jexam
//
//  Created by Philipp Matthes on 12.07.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation

class LectureTracker: NSObject, NSCoding {
    
    let lectureName: String
    let lectureId: Int
    let enrollmentCandidateIds: [Int]
    
    init(lectureName: String, lectureId: Int, enrollmentCandidateIds: [Int]) {
        self.lectureName = lectureName
        self.lectureId = lectureId
        self.enrollmentCandidateIds = enrollmentCandidateIds
    }
    
    init(lecture: Lecture, enrollmentCandidates: [EnrollmentCandidate]) {
        self.lectureName = lecture.name
        self.lectureId = lecture.id
        self.enrollmentCandidateIds = enrollmentCandidates.map {$0.id}
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(lectureName, forKey: "lectureName")
        aCoder.encode(NSNumber(value: lectureId), forKey: "lectureId")
        aCoder.encode(enrollmentCandidateIds.map {NSNumber(value: $0)}, forKey: "enrollmentCandidateIds")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard
            let lectureName = aDecoder.decodeObject(forKey: "lectureName") as? String,
            let lectureId = aDecoder.decodeObject(forKey: "lectureId") as? NSNumber,
            let enrollmentCandidateIds = aDecoder.decodeObject(forKey: "enrollmentCandidateIds") as? [NSNumber]
        else {return nil}
        self.init(lectureName: lectureName, lectureId: Int(truncating: lectureId), enrollmentCandidateIds: enrollmentCandidateIds.map {Int(truncating: $0)})
    }
    
    static func == (lhs: LectureTracker, rhs: LectureTracker) -> Bool {
        return lhs.lectureId == rhs.lectureId && lhs.enrollmentCandidateIds == rhs.enrollmentCandidateIds
    }
}

class Changelog {
    
    static var notifyAboutBackgroundFetchEvents: Bool {
        get {
            guard
                let notify = UserDefaults.standard.string(forKey: "notify"),
                let notifyBool = Bool(notify)
            else {return false}
            return notifyBool
        }
        set {
            UserDefaults.standard.set(String(newValue), forKey: "notify")
        }
    }
    
    static var trackedLectures: [LectureTracker] {
        get {
            NSKeyedUnarchiver.setClass(LectureTracker.self, forClassName: "LectureTracker")
            guard
                let decoded = UserDefaults.standard.object(forKey: "trackedLectureIds") as? NSData,
                let ids = NSKeyedUnarchiver.unarchiveObject(with: decoded as Data) as? [LectureTracker]
            else {return [LectureTracker]()}
            return ids
        }
        set {
            NSKeyedArchiver.setClassName("LectureTracker", for: LectureTracker.self)
            let encoded = NSKeyedArchiver.archivedData(withRootObject: newValue)
            UserDefaults.standard.set(encoded, forKey: "trackedLectureIds")
        }
    }
    
    static func add(_ lectureTracker: LectureTracker) {
        var ids = trackedLectures
        ids.append(lectureTracker)
        trackedLectures = ids
    }
    
    static func update(_ lectureTracker: LectureTracker) {
        var lectures = trackedLectures
        for (i, tracker) in trackedLectures.enumerated() {
            if tracker.lectureId == lectureTracker.lectureId {
                lectures[i] = lectureTracker
            }
        }
        trackedLectures = lectures
    }
    
    static func tracks(lectureId id: Int) -> Bool {
        for tracker in trackedLectures {
            if tracker.lectureId == id {return true}
        }
        return false
    }
    
    static func remove(lectureId id: Int) {
        for (i, tracker) in trackedLectures.enumerated() {
            if tracker.lectureId == id {
                var ids = trackedLectures
                ids.remove(at: i)
                trackedLectures = ids
            }
        }
    }
    
    static func tracker(forLectureId id: Int, hasChangedComparing comparing: [EnrollmentCandidate]) -> Bool {
        let enrollmentIds = comparing.map {$0.id}
        for tracker in trackedLectures {
            if tracker.lectureId == id {
                let same = enrollmentIds == tracker.enrollmentCandidateIds
                return !same
            }
        }
        return false
    }
}
