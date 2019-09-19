//
//  MainWindowController.swift
//  TwiLive
//
//  Created by user on 2019/09/19.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {
    let mainVC = MainViewController()
    
    init() {
        super.init(window: NSWindow(contentViewController: mainVC))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }

}
