//
//  jExam.swift
//  jexam
//
//  Created by Philipp Matthes on 11.07.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import Alamofire
import Kanna

typealias JSON = [[String: Any]]

class JExam {
    
    private var password: String
    private var username: String
    
    enum Endpoints {
        static let login = "https://jexam.inf.tu-dresden.de/de.jexam.web.v4.5/spring/welcome/de.jexam.web.v4.5/spring/j_acegi_security_check"
        static let logout = "https://jexam.inf.tu-dresden.de/de.jexam.web.v4.5/spring/logout"
        static let scheduler = "https://jexam.inf.tu-dresden.de/de.jexam.web.v4.5/spring/scheduler"
    }
    
    enum XPaths {
        static let scheduleSemesterOptions = "//select[@name='semesterId']/option"
        static let scheduleLecturesJS = "//script[@type='text/javascript']"
    }
    
    init(password: String, username: String) {
        self.password = password
        self.username = username
    }
    
    func login(success: @escaping (Bool) -> ()) {
        let parameters = ["j_username": username, "j_password": password]
        Alamofire.request(Endpoints.login, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: nil).responseString {
            response in
            if response.error != nil {success(false)}
            else if response.response == nil {success(false)}
            else if response.result.value == nil {success(false)}
            else if response.result.value!.contains("Username or password invalid") {success(false)}
            else {success(response.response!.statusCode == 200)}
        }
    }
    
    func logout(success: @escaping (Bool) -> ()) {
        Alamofire.request(Endpoints.logout, method: .post, parameters: nil, encoding: URLEncoding.httpBody, headers: nil).responseString {
            response in
            if response.error != nil {success(false)}
            else if response.response == nil {success(false)}
            else {success(response.response!.statusCode == 200)}
        }
    }
    
    func logout() {
        logout() {success in
            NSLog("%s", "Logged out")
        }
    }
    
    deinit {
        logout()
    }
    
    struct Semester {
        let id: String
        let description: String
    }
    
    func availableScheduleSemesters(semesters: @escaping ([Semester]?) -> ()) {
        Alamofire.request(Endpoints.scheduler, method: .get, parameters: nil, encoding: URLEncoding.httpBody, headers: nil).responseString {
            response in
            do {
                guard let html = response.result.value else {semesters(nil); return;}
                let kannaHTML = try Kanna.HTML(html: html, encoding: .utf8)
                var foundSemesters = [Semester]()
                for option in kannaHTML.xpath(XPaths.scheduleSemesterOptions) {
                    guard
                        let id = option.at_xpath("@value")?.content,
                        let name = option.innerHTML
                    else {continue}
                    foundSemesters.append(Semester(id: id, description: name))
                }
                semesters(foundSemesters)
                return
            } catch {
                semesters(nil)
                return
            }
        }
    }
    
    struct Lecture: Decodable {
        public let abbreviation: String?
        public let contractTeachers: [Teacher]?
        public let id: Int?
        public let isActive: Bool?
        public let isHasPracticalCourse: Bool?
        public let name: String?
        public let semester: String?
        public let url: String?
        
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
    
    struct Teacher: Decodable {
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
    
    func extractLecturesJSON(fromJS js: String) -> [Lecture]? {
        var json = ""
        var bracketCount = 0
        var seekingForFirstBracket = true
        for character in js {
            if !seekingForFirstBracket {json.append(character)}
            if character == "[" {
                if bracketCount == 0 {
                    seekingForFirstBracket = false
                    json.append(character)
                }
                bracketCount += 1
            }
            if character == "]" && !seekingForFirstBracket {
                bracketCount -= 1
                if bracketCount == 0 {
                    break
                }
            }
        }
        guard let data = json.data(using: .utf8) else {return nil}
        do {
            let jsonDecoder = JSONDecoder()
            let decoded = try jsonDecoder.decode([Lecture].self, from: data)
            return decoded
        } catch {
            print(error)
            return nil
        }
    }
    
    func availableLectures(forSemester semester: Semester, lectures: @escaping ([Lecture]?) -> ()) {
        let url = "\(Endpoints.scheduler)?semesterId=\(semester.id)"
        Alamofire.request(url, method: .get, parameters: nil, encoding: URLEncoding.httpBody, headers: nil).responseString {
            response in
            do {
                guard let html = response.result.value else {lectures(nil); return;}
                let kannaHTML = try Kanna.HTML(html: html, encoding: .utf8)
                let wantedJS = kannaHTML.xpath(XPaths.scheduleLecturesJS)
                    .filter {$0.content?.contains("teachingOffers") ?? false}
                for option in wantedJS {
                    guard let html = option.innerHTML else {continue}
                    lectures(self.extractLecturesJSON(fromJS: html))
                    return
                }
                lectures(nil)
            } catch {
                lectures(nil)
                return
            }
        }
    }
    
}
