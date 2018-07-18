//
//  GradesController.swift
//  jexam
//
//  Created by Philipp Matthes on 16.07.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import Material
import UIKit
import WebKit

class GradesController: UIViewController {
    
    var jExam: JExam!
    var webView: WKWebView?
    var data: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareTabItem()
        view.backgroundColor = .white
        
        jExam.resultsAsPdf() {
            data in
            self.data = data
            self.loadPdf()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        prepareWebView()
        loadPdf()
    }
    
    func loadPdf() {
        guard let data = data else {return}
        self.webView?.load(data, mimeType: "application/pdf", characterEncodingName:"", baseURL: URL(string: "http://google.com")!)
    }
    
    fileprivate func prepareWebView() {
        webView = WKWebView()
        
        view.layout(webView!).bottom().top().left().right()
    }
    
    fileprivate func prepareTabItem() {
        tabItem.title = "Grades"
        
        tabItem.setTabItemImage(Icon.add, for: .normal)
        tabItem.setTabItemImage(Icon.pen, for: .selected)
        tabItem.setTabItemImage(Icon.photoLibrary, for: .highlighted)
    }
    
}
