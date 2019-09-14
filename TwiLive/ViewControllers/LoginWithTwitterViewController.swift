//
//  LoginWithTwitterViewController.swift
//  TwiLive
//
//  Created by user on 2019/09/14.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import Cocoa
import Alamofire

class LoginWithTwitterViewController: NSViewController {

    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var authorizeUrlField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        progressIndicator.startAnimation(self)
        let request = TwitterAuthApp.default.getRequestToken()
        Alamofire.request(request).responseString { [unowned self] res in
            switch res.result {
            case .success(let str):
                let httpRes = res.response!
                guard httpRes.statusCode == 200 else {
                    self.authorizeUrlField.stringValue = "通信エラー (HTTP \(httpRes.statusCode))\n\(str)"
                    return
                }
                let res = str.parseQueryParameters()
                guard res["oauth_callback_confirmed"] == "true" else {
                    self.authorizeUrlField.stringValue = "取得失敗 (コールバックURI)"
                    return
                }
                guard let token = res["oauth_token"], let tokenSecret = res["oauth_token_secret"] else {
                    self.authorizeUrlField.stringValue = "取得失敗 (トークンが謎)"
                    return
                }
                let url = URL(string: "https://twitter.com/oauth/authorize?oauth_token=\(token)")!
                self.authorizeUrlField.attributedStringValue = NSAttributedString(string: url.absoluteString, attributes: [
                    .link: url,
                    .font: self.authorizeUrlField.font!,
                ])
            case .failure(let err):
                print(err)
            }
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.preventsApplicationTerminationWhenModal = false
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        view.window?.preventsApplicationTerminationWhenModal = true
    }
    
    @IBAction func quitButtonClicked(_ sender: Any) {
        self.dismiss(self)
        NSApplication.shared.terminate(self)
    }
}
