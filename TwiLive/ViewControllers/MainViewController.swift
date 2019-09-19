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
    let timelineVC = TimelineViewController()
    let composeTweetVC = ComposeTweetViewController()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        splitView.isVertical = false
        addSplitViewItem(.init(viewController: timelineVC))
        addSplitViewItem(.init(viewController: composeTweetVC))
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
        timelineVC.accessToken = token
        composeTweetVC.accessToken = token
    }
}
