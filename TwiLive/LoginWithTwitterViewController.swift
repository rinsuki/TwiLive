//
//  LoginWithTwitterViewController.swift
//  TwiLive
//
//  Created by user on 2019/09/14.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import Cocoa

class LoginWithTwitterViewController: NSViewController {

    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        progressIndicator.startAnimation(self)
    }
    
}
