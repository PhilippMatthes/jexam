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
    var lectureId: Int!
    var lectureName: String!
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
        JExam.availableEnrollmentCandidates(forLecture: lectureId) {
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
        let memberString = c.maxMembers == 0 ? "\(c.currentMembers) enrolled" : "\(c.currentMembers)/\(c.maxMembers) enrolled"
        if c.timeInfo.weekday.weekday == 0 && c.timeInfo.slot == 0 {
            cell.detailTextLabel?.text = "\(c.lectureType) - No time info - \(memberString)"
        } else {
            cell.detailTextLabel?.text = "\(c.lectureType) - \(c.timeInfo.weekday.description()) \(c.timeInfo.slot). DS - \(memberString)"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func prepareNavigationItem() {
        navigationItem.titleLabel.text = lectureName
        
        prepareTrackButton()
    }
    
    func prepareTrackButton() {
        trackLectureButton = IconButton(image: Changelog.tracks(lectureId: lectureId) ? Icon.cm.close : Icon.cm.check)
        trackLectureButton.addTarget(self, action: #selector(trackLecture), for: .touchUpInside)
        navigationItem.rightViews = [trackLectureButton]
    }
    
    @objc func trackLecture() {
        if Changelog.tracks(lectureId: lectureId) {
            Changelog.remove(lectureId: lectureId)
            showAlert("This lecture will not be tracked anymore!")
        } else {
            Changelog.add(LectureTracker(lectureName: lectureName, lectureId: lectureId, enrollmentCandidateIds: enrollmentCandidates.map {$0.id}))
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
