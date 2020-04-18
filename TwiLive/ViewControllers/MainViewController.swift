//
//  MainViewController.swift
//  TwiLive
//
//  Created by user on 2019/09/08.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import Cocoa
import KeychainAccess

fileprivate let keychain = Keychain(service: "com.twitter.oauth")
fileprivate let jsonEncoder = JSONEncoder()
fileprivate let jsonDecoder = JSONDecoder()

class MainViewController: NSSplitViewController {
    var accessToken: TwitterAuthAccessToken? {
        didSet {
            timelineVC.accessToken = accessToken
            composeTweetVC.accessToken = accessToken
            if let token = accessToken {
                let data = try! JSONEncoder().encode(token)
                keychain[data: "accessToken"] = data
            } else {
                try! keychain.remove("accessToken")
            }
        }
    }
    let timelineVC = TimelineViewController()
    let composeTweetVC = ComposeTweetViewController()
    
    var isFirstAppear = true

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        splitView.isVertical = false
        addSplitViewItem(.init(viewController: timelineVC))
        addSplitViewItem(.init(viewController: composeTweetVC))
        
        if  let data = keychain[data: "accessToken"],
            let token = try? jsonDecoder.decode(TwitterAuthAccessToken.self, from: data) {
            accessToken = token
        }
    }
    
    override func viewDidAppear() {
        isFirstAppear = false
        if accessToken == nil {
            let authorizeSheet = LoginWithTwitterViewController()
            authorizeSheet.delegate = self
            presentAsSheet(authorizeSheet)
        }
    }
}

extension MainViewController: LoginWithTwitterViewControllerDelegate {
    func didFinishAuthorize(token: TwitterAuthAccessToken) {
        accessToken = token
    }
}
