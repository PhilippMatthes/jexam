//
//  LoginController.swift
//  jexam
//
//  Created by Philipp Matthes on 11.07.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import Material
import UIKit

class LoginController: UIViewController {
    fileprivate var control: Switch!
    fileprivate var label: UILabel!
    fileprivate var userField: TextField!
    fileprivate var passwordField: TextField!
    fileprivate var jExam: JExam!
    
    /// A constant to layout the textFields.
    fileprivate let constant: CGFloat = 32
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.grey.lighten5
        
        prepareNavigationBar()
        preparePasswordField()
        prepareUserField()
        prepareSwitch()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        [userField, passwordField].forEach {$0?.isEnabled = true}
    }
    
}

extension LoginController: SwitchDelegate {
    func switchDidChangeState(control: Switch, state: SwitchState) {
        Changelog.notifyAboutBackgroundFetchEvents = state == .on
    }
}

extension LoginController {
    
    fileprivate func prepareNavigationBar() {
        navigationItem.titleLabel.text = "Login"
        
        let trackersButton = IconButton(image: Icon.cm.moreVertical)
        trackersButton.addTarget(self, action: #selector(showTrackers), for: .touchUpInside)
        navigationItem.rightViews = [trackersButton]
    }
    
    @objc func showTrackers() {
        let trackersController = TrackerController()
        navigationController?.show(trackersController, sender: self)
    }
    
    fileprivate func prepareSwitch() {
        let control = Switch(state: Changelog.notifyAboutBackgroundFetchEvents ? .on : .off, style: .light, size: .small)
        control.delegate = self
        let label = UILabel()
        label.text = "Notify about background fetches"
        label.font = RobotoFont.medium(with: 15.0)
        label.textColor = .black
        
        view.layout(control).center(offsetY: -userField.bounds.height - 120)
        view.layout(label).center(offsetY: -userField.bounds.height - 160)
    }
    
    fileprivate func prepareUserField() {
        userField = TextField()
        userField.placeholder = "Username"
        userField.detail = "jExam Username"
        userField.isClearIconButtonEnabled = true
        userField.delegate = self
        userField.placeholderAnimation = .hidden
        
        if let username = UserDefaults.standard.object(forKey: "username") as? String {
            userField.text = username
        }
        
        view.layout(userField).center(offsetY: -passwordField.bounds.height - 60).left(20).right(20)
    }
    
    fileprivate func preparePasswordField() {
        passwordField = TextField()
        passwordField.placeholder = "Password"
        passwordField.detail = "jExam Password"
        passwordField.delegate = self
        passwordField.clearButtonMode = .whileEditing
        passwordField.isVisibilityIconButtonEnabled = true
        
        // Setting the visibilityIconButton color.
        passwordField.visibilityIconButton?.tintColor = Color.green.base.withAlphaComponent(passwordField.isSecureTextEntry ? 0.38 : 0.54)
        
        view.layout(passwordField).center().left(20).right(20)
    }
}


extension LoginController: TextFieldDelegate {
    public func textFieldDidEndEditing(_ textField: UITextField) {
        (textField as? ErrorTextField)?.isErrorRevealed = false
    }
    
    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        (textField as? ErrorTextField)?.isErrorRevealed = false
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        (textField as? ErrorTextField)?.isErrorRevealed = true
        guard
            let username = userField.text,
            let password = passwordField.text
        else {return true}
        login(username: username, password: password)
        return true
    }
}

extension LoginController {
    func login(username: String, password: String) {
        jExam = JExam(password: password, username: username)
        [userField, passwordField].forEach {$0!.isEnabled = false}
        jExam.logout() {
            success in
            self.jExam.login() {
                success in
                DispatchQueue.main.async {
                    if !success {
                        [self.userField, self.passwordField].forEach {$0!.isEnabled = true}
                    } else {
                        UserDefaults.standard.set(username, forKey: "username")
                        let semesterController = SemesterController()
                        semesterController.jExam = self.jExam
                        self.navigationController?.show(semesterController, sender: self)
                    }
                }
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
