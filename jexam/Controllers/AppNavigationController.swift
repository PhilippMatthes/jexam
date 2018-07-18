//
//  NavigationController.swift
//  jexam
//
//  Created by Philipp Matthes on 11.07.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import Material

class AppNavigationController: NavigationController {
    open override func prepare() {
        super.prepare()
        prepareNavigationItem()
        isMotionEnabled = true
        
        guard let v = navigationBar as? NavigationBar else {return}
        
        v.backgroundColor = .white
        v.depthPreset = .none
        v.dividerColor = Color.grey.lighten2
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func prepareNavigationItem() {
        navigationItem.titleLabel.text = "jExam Management"
    }
}
