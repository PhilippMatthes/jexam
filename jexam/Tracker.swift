//
//  Tracker.swift
//  jexam
//
//  Created by Philipp Matthes on 19.07.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation

struct Tracker: Codable {
    public let lecture: Lecture
    public let enrollmentCandidates: [EnrollmentCandidate]
    
    init(lecture: Lecture, enrollmentCandidates: [EnrollmentCandidate]) {
        self.lecture = lecture
        self.enrollmentCandidates = enrollmentCandidates
    }
    
    func hasChanged(comparing candidates: [EnrollmentCandidate]) -> Bool {
        return candidates.map {$0.id} == self.enrollmentCandidates.map {$0.id}
    }
    
    func notificationContents(comparing candidates: [EnrollmentCandidate]) -> [NotificationContent] {
        var contents = [NotificationContent]()
        guard hasChanged(comparing: candidates) else {return contents}
        
        if candidates.count != enrollmentCandidates.count {
            let diff = candidates.count - enrollmentCandidates.count
            let subtitle = diff > 0 ? "There are \(diff) new enrollment options!" : "\(-diff) enrollment options were removed!"
            let body = candidates.map {"\($0.lectureType) \($0.name) on Weekday: \($0.timeInfo.weekday.description()) - \($0.room?.building.abbreviation ?? "") \($0.room?.roomNo ?? "")\n"} .joined(separator: "")
            let content = NotificationContent(title: lecture.name, subtitle: subtitle, body: body, important: true, tracker: self)
            contents.append(content)
        }
        
        for candidate in candidates {
            for enrollmentCandidate in enrollmentCandidates {
                if enrollmentCandidate.id == candidate.id {
                    
                    let subtitle = "New activities on \(candidate.lectureType) \(candidate.name)"
                    
                    var body = "\(candidate.timeInfo.weekday.description()) \(candidate.timeInfo.slot). DS \(candidate.room?.building.abbreviation ?? "") \(candidate.room?.roomNo ?? "")\n"
                    
                    let memberDiff = candidate.currentMembers - enrollmentCandidate.currentMembers
                    let maxMemberDiff = candidate.maxMembers - enrollmentCandidate.maxMembers
                    let dayDiff = candidate.timeInfo.weekday.weekday - enrollmentCandidate.timeInfo.weekday.weekday
                    let timeDiff = candidate.timeInfo.slot - enrollmentCandidate.timeInfo.slot
                    let enrollmentStatusChanged = candidate.enrollmentStatus != enrollmentCandidate.enrollmentStatus
                    let enrollStartChanged = candidate.freeForEnroll.start != enrollmentCandidate.freeForEnroll.start
                    let enrollEndChanged = candidate.freeForEnroll.stop != enrollmentCandidate.freeForEnroll.stop
                    let cancelStartChanged = candidate.freeForCancel.start != enrollmentCandidate.freeForCancel.start
                    let cancelEndChanged = candidate.freeForCancel.stop != enrollmentCandidate.freeForCancel.stop
                    let lectureTypeChanged = candidate.lectureType != enrollmentCandidate.lectureType
                    let nameChanged = candidate.name != enrollmentCandidate.name
                    let teachingPersonsDiff = candidate.teachingPersons.count - enrollmentCandidate.teachingPersons.count
                    
                    var somethingChanged = false
                    
                    if memberDiff != 0 {
                        somethingChanged = true
                        body += memberDiff > 0 ? "\(memberDiff) new enrollments\n" : "\(-memberDiff) students cancelled their enrollment\n"
                    }
                    
                    if maxMemberDiff != 0 {
                        somethingChanged = true
                        body += maxMemberDiff > 0 ? "The members limit was raised by \(maxMemberDiff) to \(candidate.maxMembers)\n" : "The members limit was truncated by \(-maxMemberDiff) to \(candidate.maxMembers)\n"
                    }
                    
                    if dayDiff != 0 {
                        somethingChanged = true
                        body += "The day was changed from \(enrollmentCandidate.timeInfo.weekday.description()) to \(candidate.timeInfo.weekday.description())\n"
                    }
                    
                    if timeDiff != 0 {
                        somethingChanged = true
                        body += "The time was changed from \(enrollmentCandidate.timeInfo.slot). DS to \(candidate.timeInfo.slot). DS\n"
                    }
                    
                    if enrollmentStatusChanged {
                        somethingChanged = true
                        body += "The enrollment status was changed from \(enrollmentCandidate.enrollmentStatus) to \(candidate.enrollmentStatus)\n"
                    }
                    
                    if enrollStartChanged || enrollEndChanged {
                        somethingChanged = true
                        body += "The enrollment now starts at \(candidate.freeForEnroll.startTime())"
                        body += candidate.freeForEnroll.stopTime() == nil ? "\n" : " and runs until \(candidate.freeForEnroll.stopTime()!)\n"
                    }
                    
                    if cancelStartChanged || cancelEndChanged {
                        somethingChanged = true
                        body += "The enrollment is now free for cancel from \(candidate.freeForCancel.startTime())"
                        body += candidate.freeForCancel.stopTime() == nil ? "\n" : " until \(candidate.freeForCancel.stopTime()!)\n"
                    }
                    
                    if lectureTypeChanged {
                        somethingChanged = true
                        body += "The lecture type changed from \(enrollmentCandidate.lectureType) to \(candidate.lectureType)\n"
                    }
                    
                    if nameChanged {
                        somethingChanged = true
                        body += "The name changed from \(enrollmentCandidate.name) to \(candidate.name)\n"
                    }
                    
                    if teachingPersonsDiff != 0 {
                        somethingChanged = true
                        body += teachingPersonsDiff > 0 ? "There are \(teachingPersonsDiff) new teachers\n" : "\(-teachingPersonsDiff) were removed\n"
                    }
                    
                    if somethingChanged {
                        let content = NotificationContent(title: lecture.name, subtitle: subtitle, body: body, important: false, tracker: self)
                        contents.append(content)
                    }
                }
            }
        }
        return contents
    }
    
    private enum CodingKeys: String, CodingKey {
        case lecture = "lecture"
        case enrollmentCandidates = "enrollmentCandidates"
    }
}
