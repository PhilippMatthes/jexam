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
    var semester: JExam.Semester!
    var lectures = [JExam.Lecture]()
    var filter: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.grey.lighten5
        
        prepareTable()
        prepareSearchBar()
        
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
        cell.textLabel?.text = lectures[indexPath.row].name ?? "n/a"
        cell.detailTextLabel?.text = lectures[indexPath.row].semester ?? "n/a"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: "Controllers", bundle: nil)
        let lectureDetailController = storyBoard.instantiateViewController(withIdentifier: "LectureDetailController") as! LectureDetailController
        lectureDetailController.lecture = filteredLectures()[indexPath.row]
        lectureDetailController.modalPresentationStyle = .overCurrentContext
        present(lectureDetailController, animated: true, completion: nil)
    }
    
    func filteredLectures() -> [JExam.Lecture] {
        guard let filter = filter else {return lectures}
        return lectures.filter {$0.name?.contains(filter) ?? false}
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
