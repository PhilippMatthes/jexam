//
//  TrackersController.swift
//  jexam
//
//  Created by Philipp Matthes on 12.07.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import Material
import UIKit

class TrackerController: TableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(TableViewCell.self, forCellReuseIdentifier: "TableViewCell")
        navigationItem.titleLabel.text = "Tracked Lectures"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let lectureName = Changelog.trackedLectures[indexPath.row].lectureName
        let lectureId = Changelog.trackedLectures[indexPath.row].lectureId
        let enrollmentController = EnrollmentController()
        enrollmentController.lectureName = lectureName
        enrollmentController.lectureId = lectureId
        navigationController?.show(enrollmentController, sender: self)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Changelog.trackedLectures.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell") as? TableViewCell else {return UITableViewCell()}
        cell.textLabel?.text = Changelog.trackedLectures[indexPath.row].lectureName
        return cell
    }
    
}
