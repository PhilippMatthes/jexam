//
//  LecturesController.swift
//  jexam
//
//  Created by Philipp Matthes on 11.07.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import UIKit
import Material

class LecturesController: TableViewController {
    
    var jExam: JExam!
    var semester: Semester!
    var lectures = [Lecture]()
    var filter: String?
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.grey.lighten5
        
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        prepareTable()
        prepareSearchBar()
        prepareNavigationItem()
        
        refresh()
    }
    
    @objc func refresh() {
        self.jExam.availableLectures(forSemester: semester) {
            lectures in
            guard let lectures = lectures else {return}
            if lectures.count == 0 {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
                return
            }
            self.lectures = lectures
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredLectures().count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell") as? TableViewCell else {return UITableViewCell()}
        let lectures = filteredLectures()
        cell.textLabel?.text = lectures[indexPath.row].name
        cell.detailTextLabel?.text = lectures[indexPath.row].semester
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let enrollmentController = EnrollmentController()
        enrollmentController.lectureId = filteredLectures()[indexPath.row].id
        enrollmentController.lectureName = filteredLectures()[indexPath.row].name
        enrollmentController.modalPresentationStyle = .overCurrentContext
        navigationController?.show(enrollmentController, sender: self)
    }
    
    func filteredLectures() -> [Lecture] {
        guard let filter = filter else {return lectures}
        return lectures.filter {$0.name.contains(filter)}
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

fileprivate extension LecturesController {
    
    func prepareTable() {
        tableView.register(TableViewCell.self, forCellReuseIdentifier: "TableViewCell")
    }
    
    func prepareSearchBar() {
        guard let searchBar = searchBarController?.searchBar else {return}
        searchBar.delegate = self
    }
    
    func prepareNavigationItem() {
        navigationItem.titleLabel.text = semester.description
    }

}

extension LecturesController: SearchBarDelegate {
    func searchBar(searchBar: SearchBar, didChange textField: UITextField, with text: String?) {
        filter = textField.text
        tableView.reloadData()
    }
    
    func searchBar(searchBar: SearchBar, didClear textField: UITextField, with text: String?) {
        filter = nil
        tableView.reloadData()
    }
}
