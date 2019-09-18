//
//  MainViewController.swift
//  TwiLive
//
//  Created by user on 2019/09/08.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import Cocoa
import SwiftUI

class MainViewController: NSSplitViewController {
    var accessToken: TwitterAuthAccessToken?
    @IBOutlet weak var timelineItem: NSSplitViewItem!
    @IBOutlet weak var composeTweetItem: NSSplitViewItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear() {
        let authorizeSheet = LoginWithTwitterViewController()
        authorizeSheet.delegate = self
        presentAsSheet(authorizeSheet)
    }
}

extension MainViewController: LoginWithTwitterViewControllerDelegate {
    func didFinishAuthorize(token: TwitterAuthAccessToken) {
        accessToken = token
        if let timelineVC = timelineItem.viewController as? TimelineViewController {
            timelineVC.accessToken = token
        }
        if let composeTweetVC = composeTweetItem.viewController as? ComposeTweetViewController {
            composeTweetVC.accessToken = token
        }
    }
}
