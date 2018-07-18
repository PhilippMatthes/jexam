//
//  LectureDetailController.swift
//  jexam
//
//  Created by Philipp Matthes on 11.07.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import UIKit
import Material

class EnrollmentController: TableViewController {
    
    var enrollmentCandidates = [EnrollmentCandidate]()

    var lecture: Lecture!
    
    var trackLectureButton: IconButton!
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        prepareNavigationItem()
        
        refresh()
    }
    
    @objc func refresh() {
        refreshControl.beginRefreshing()
        JExam.availableEnrollmentCandidates(forLecture: lecture.id) {
            candidates in
            if let response = candidates {
                self.enrollmentCandidates = response.candidates
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            self.refreshControl.endRefreshing()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return enrollmentCandidates.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell") as? TableViewCell
            else {return UITableViewCell()}
        let c = enrollmentCandidates[indexPath.row]
        cell.textLabel?.text = "\(c.name)"
        cell.textLabel?.numberOfLines = 0
        cell.backgroundColor = indexPath.row % 2 == 0 ? Config.darkColor : Config.lightColor
        cell.textLabel?.textColor = .white
        cell.detailTextLabel?.textColor = .white
        cell.detailTextLabel?.numberOfLines = 0
        let str1 = "\(c.lectureType)" + (c.room == nil ? "" : " - \(c.room!.building.abbreviation) \(c.room!.roomNo)")
        var str2: String
        if c.timeInfo.weekday.weekday == 0 && c.timeInfo.slot == 0 {
            str2 = " - No time info"
        } else {
            str2 = " - \(c.timeInfo.weekday.description()) \(c.timeInfo.slot). DS"
        }
        let str3 = c.maxMembers == 0 ? " - \(c.currentMembers) enrolled\n\n" : " - \(c.currentMembers)/\(c.maxMembers) enrolled\n\n"
        let str4 = "Enrollment possible from \(c.freeForEnroll.startTime())"
        let str5 = c.freeForEnroll.stopTime() == nil ? "" : " to \(c.freeForEnroll.stopTime()!)\n"
        let str6 = "Cancelling enrollment possible from \(c.freeForCancel.startTime())"
        let str7 = c.freeForEnroll.stopTime() == nil ? "" : " to \(c.freeForCancel.stopTime()!)\n"
        let str8 = "Teachers: \(c.teachingPersons.map {"\($0.title ?? "") \($0.firstname ?? "") \($0.surname ?? "")"}.joined(separator: ", "))"
        cell.detailTextLabel?.text = str1 + str2 + str3 + str4 + str5 + str6 + str7 + str8
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func prepareNavigationItem() {
        navigationItem.titleLabel.text = lecture.name
        
        prepareTrackButton()
    }
    
    func prepareTrackButton() {
        trackLectureButton = IconButton(image: Changelog.tracks(lectureId: lecture.id) ? Icon.cm.close : Icon.cm.check)
        trackLectureButton.addTarget(self, action: #selector(trackLecture), for: .touchUpInside)
        navigationItem.rightViews = [trackLectureButton]
    }
    
    @objc func trackLecture() {
        if Changelog.tracks(lectureId: lecture.id) {
            Changelog.remove(lectureId: lecture.id)
            showAlert("This lecture will not be tracked anymore!")
        } else {
            let tracker = Tracker(lecture: lecture, enrollmentCandidates: enrollmentCandidates)
            Changelog.add(tracker)
            showAlert("This lecture will now be tracked!")
        }
        prepareTrackButton()
    }
    
    func showAlert(_ alert: String) {
        let alert = UIAlertController(title: alert, message: "The tracking state has changed.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: {
            action in
        }))
        present(alert, animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
