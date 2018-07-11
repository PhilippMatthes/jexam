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

class LectureDetailController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var teacherLabel: UILabel!
    @IBOutlet weak var table: TableView!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var semesterLabel: UILabel!
    @IBOutlet weak var hasPracticalCourseLabel: UILabel!
    @IBOutlet weak var isActiveLabel: UILabel!
    
    var lecture: JExam.Lecture!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        view.backgroundColor = .clear
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tap)
        
        nameLabel.text = lecture.name ?? ""
        urlLabel.text = lecture.url ?? ""
        semesterLabel.text = lecture.semester ?? ""
        hasPracticalCourseLabel.text = "Has practical Courses: " + (lecture.isHasPracticalCourse != nil ? String(lecture.isHasPracticalCourse!) : "n/a")
        isActiveLabel.text = "Is active: " + (lecture.isActive != nil ? String(lecture.isActive!) : "n/a")
        
        table.delegate = self
        table.dataSource = self
        table.register(TableViewCell.self, forCellReuseIdentifier: "TableViewCell")
        table.reloadData()
    }
    
    @objc func handleTap() {
        dismiss(animated: true, completion: nil)
    }
    
}

extension LectureDetailController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lecture.contractTeachers?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell") as? TableViewCell,
            let contractTeachers = lecture.contractTeachers
        else {return UITableViewCell()}
        let t = contractTeachers[indexPath.row]
        cell.textLabel?.text = "\(t.title ?? "") \(t.firstname ?? "") \(t.surname ?? "")"
        return cell
    }
}
