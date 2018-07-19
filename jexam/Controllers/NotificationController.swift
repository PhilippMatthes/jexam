//
//  NotificationController.swift
//  jexam
//
//  Created by Philipp Matthes on 19.07.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import Material

class NotificationController: TableViewController {
    
    var notificationContents = Dispatcher.notificationContents
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(TableViewCell.self, forCellReuseIdentifier: "TableViewCell")
        prepareNavigationBar()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationContents.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell") as? TableViewCell else {return UITableViewCell()}
        let notification = notificationContents[indexPath.row]
        cell.imageView?.image = notification.important ? Icon.addCircle : nil
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = notification.title + "\n" + notification.subtitle
        cell.detailTextLabel?.numberOfLines = 0
        cell.detailTextLabel?.text = notification.body
        cell.backgroundColor = indexPath.row % 2 == 0 ? Config.darkColor : Config.lightColor
        cell.textLabel?.textColor = .white
        cell.detailTextLabel?.textColor = .white
        return cell
    }
    
    fileprivate func prepareNavigationBar() {
        navigationItem.titleLabel.text = "Notifications"
        
        let trackersButton = IconButton(image: Icon.cm.close)
        trackersButton.addTarget(self, action: #selector(removeAll), for: .touchUpInside)
        
        navigationItem.rightViews = [trackersButton]
    }
    
    @objc func removeAll() {
        Dispatcher.removeAll()
        self.notificationContents = Dispatcher.notificationContents
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let enrollmentController = EnrollmentController()
        enrollmentController.lecture = self.notificationContents[indexPath.row].tracker.lecture
        navigationController?.show(enrollmentController, sender: self)
    }
}
