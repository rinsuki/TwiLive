//
//  ViewController.swift
//  TwiLive
//
//  Created by user on 2019/09/08.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import Cocoa
import SwiftUI

class ViewController: NSSplitViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear() {
        let authorizeSheet = StoryboardScene.Main.loginWithTwitter.instantiate()
        presentAsSheet(authorizeSheet)
    }
}

