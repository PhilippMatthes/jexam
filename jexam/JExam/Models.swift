//
//  Models.swift
//  jexam
//
//  Created by Philipp Matthes on 12.07.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation

struct Semester: Codable {
    let id: String
    let description: String
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case description = "description"
    }
}

struct Lecture: Codable {
    
    public let abbreviation: String
    public let contractTeachers: [Teacher]
    public let id: Int
    public let isActive: Bool
    public let isHasPracticalCourse: Bool
    public let name: String
    public let semester: String
    public let url: String
    
    private enum CodingKeys: String, CodingKey {
        case abbreviation = "abbreviation"
        case contractTeachers = "contractTeachers"
        case id = "id"
        case isActive = "isActive"
        case isHasPracticalCourse = "isHasPracticalCourse"
        case name = "name"
        case semester = "semester"
        case url = "url"
    }

}

struct Teacher: Codable {
    public let firstname: String?
    public let gender: String?
    public let id: Int?
    public let surname: String?
    public let title: String?
    
    private enum CodingKeys: String, CodingKey {
        case firstname = "firstname"
        case gender = "gender"
        case id = "id"
        case surname = "surname"
        case title = "title"
    }
}

struct EnrollmentCandidatesResponse: Codable {
    public let results: Int
    public let toID: Int
    public let action: String
    public let success: Bool
    public let candidates: [EnrollmentCandidate]
    
    private enum CodingKeys: String, CodingKey {
        case results = "results"
        case toID = "toID"
        case action = "action"
        case success = "success"
        case candidates = "rows"
    }
}

struct EnrollmentCandidate: Codable {
    public let enrollmentCandidates: Int
    public let freeForCancel: CancelationInformation
    public let timeInfo: TimeInformation
    public let teachingOfferId: Int
    public let enrollmentStatus: String
    public let sppw: Int
    public let id: Int
    public let groupNo: Int
    public let sublectures: [Lecture]?
    public let maxMembers: Int
    public let name: String
    public let freeForEnroll: FreeForEnrollmentInformation
    public let currentMembers: Int
    public let day: Int
    public let teachingOfferFors: [TeachingOffer]
    public let slot: Int
    public let lectureType: String
//    public let freeForEnrollCandidates: FreeForEnrollmentCandidate?
    public let week: Int
    public let room: Room?
    public let teachingPersons: [Teacher]
    
    private enum CodingKeys: String, CodingKey {
        case enrollmentCandidates = "enrollmentCandidates"
        case freeForCancel = "freeForCancel"
        case timeInfo = "timeInfo"
        case teachingOfferId = "teachingOfferId"
        case enrollmentStatus = "enrollmentStatus"
        case sppw = "sppw"
        case id = "id"
        case groupNo = "groupNo"
        case sublectures = "sublectures"
        case maxMembers = "maxMembers"
        case name = "name"
        case freeForEnroll = "freeForEnroll"
        case currentMembers = "currentMembers"
        case day = "day"
        case teachingOfferFors = "teachingOfferFors"
        case slot = "slot"
        case lectureType = "lectureType"
        //    case freeForEnrollCandidates = FreeForEnrollmentCandidate?
        case week = "week"
        case room = "room"
        case teachingPersons = "teachingPersons"
    }
}

struct CancelationInformation: Codable {
    public let stop: UInt64?
    public let start: UInt64
    public let slot: Int
    public let week: Int
    
    private enum CodingKeys: String, CodingKey {
        case stop = "stop"
        case start = "start"
        case slot = "slot"
        case week = "week"
    }
}

struct TimeInformation: Codable {
    public let weekday: Weekday
    public let slot: Int
    public let week: Int
    
    private enum CodingKeys: String, CodingKey {
        case weekday = "weekday"
        case slot = "slot"
        case week = "week"
    }
}

struct Weekday: Codable {
    public let weekday: Int
    
    private enum CodingKeys: String, CodingKey {
        case weekday = "weekday"
    }
    
    func description() -> String {
        switch weekday {
        case 1: return "Monday"
        case 2: return "Tuesday"
        case 3: return "Wednesday"
        case 4: return "Thursday"
        case 5: return "Friday"
        case 6: return "Saturday"
        case 7: return "Sunday"
        default: return "n/a"
        }
    }
}

struct FreeForEnrollmentInformation: Codable {
    public let stop: UInt64?
    public let start: UInt64
    public let slot: Int
    public let week: Int
    
    private enum CodingKeys: String, CodingKey {
        case stop = "stop"
        case start = "start"
        case slot = "slot"
        case week = "week"
    }
}

struct TeachingOffer: Codable {
    public let id: Int
    public let subjectCategory: SubjectCategory
    public let studyRegulationID: Int
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case subjectCategory = "subjectCategory"
        case studyRegulationID = "studyRegulationID"
    }
}

struct SubjectCategory: Codable {
    public let id: Int
    public let name: String
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
    }
}

struct Room: Codable {
    public let building: Building
    public let roomNo: String
    
    private enum CodingKeys: String, CodingKey {
        case building = "building"
        case roomNo = "roomNo"
    }
}

struct Building: Codable {
    public let abbreviation: String
    
    private enum CodingKeys: String, CodingKey {
        case abbreviation = "abbreviation"
    }
}
