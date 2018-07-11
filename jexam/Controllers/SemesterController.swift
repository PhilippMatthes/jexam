//
//  SemesterController.swift
//  jexam
//
//  Created by Philipp Matthes on 11.07.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import Material
import UIKit

class SemesterController: TableViewController {
    
    var semesters = [JExam.Semester]()
    var jExam: JExam!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.grey.lighten5
        
        tableView.register(TableViewCell.self, forCellReuseIdentifier: "TableViewCell")
        
        self.jExam.availableScheduleSemesters() {
            semesters in
            guard let semesters = semesters else {return}
            if semesters.count == 0 {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
                return
            }
            self.semesters = semesters
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return semesters.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell") else {return UITableViewCell()}
        cell.textLabel?.text = semesters[indexPath.row].description
        cell.detailTextLabel?.text = semesters[indexPath.row].id
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let lecturesController = LecturesController()
        lecturesController.jExam = jExam
        lecturesController.semester = semesters[indexPath.row]
        let searchController = SearchBarController(rootViewController: lecturesController)
        present(searchController, animated: true, completion: nil)
    }
    
}
