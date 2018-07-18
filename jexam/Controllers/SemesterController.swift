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
    
    var semesters = [Semester]()
    var jExam: JExam!
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareNavigationItem()
        prepareTabItem()
        view.backgroundColor = Color.grey.lighten5
        
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        tableView.register(TableViewCell.self, forCellReuseIdentifier: "TableViewCell")
        
        refresh()
    }
    
    @objc func refresh() {
        self.jExam.availableScheduleSemesters() {
            semesters in
            guard let semesters = semesters else {return}
            if semesters.count == 0 {
                DispatchQueue.main.async {
                    self.showAlert()
                }
                return
            }
            self.semesters = semesters
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "Oops...", message: "Something went wrong. Maybe you are still logged in on another computer. Try again later!", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Go back to login", style: .cancel, handler: {
            action in
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return semesters.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell") else {return UITableViewCell()}
        cell.textLabel?.text = semesters[indexPath.row].description
        cell.detailTextLabel?.text = semesters[indexPath.row].id
        cell.backgroundColor = indexPath.row % 2 == 0 ? Config.darkColor : Config.lightColor
        cell.textLabel?.textColor = .white
        cell.detailTextLabel?.textColor = .white
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let lecturesController = LecturesController()
        lecturesController.jExam = jExam
        lecturesController.semester = semesters[indexPath.row]
        let searchController = SearchBarController(rootViewController: lecturesController)
        let searchButton = IconButton(image: Icon.cm.search)
        searchButton.isEnabled = false
        searchController.searchBar.leftViews = [searchButton]
        navigationController?.show(searchController, sender: self)
    }
    
    func prepareNavigationItem() {
        navigationItem.titleLabel.text = "Available Semesters"
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    fileprivate func prepareTabItem() {
        tabItem.title = "Enrollment"
        
        tabItem.setTabItemImage(Icon.add, for: .normal)
        tabItem.setTabItemImage(Icon.pen, for: .selected)
        tabItem.setTabItemImage(Icon.photoLibrary, for: .highlighted)
    }
    
}
