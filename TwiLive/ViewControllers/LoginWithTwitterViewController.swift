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
    @IBOutlet weak var refreshUrlButton: NSButton!
    
    private enum RequestTokenError {
        case native(error: Error)
        case http(code: Int, message: String)
        case `internal`(message: String)
    }
    
    private enum RequestTokenState {
        case loading
        case error(RequestTokenError)
        case success(TwitterAuthRequestToken)
    }
    
    private var requestTokenState: RequestTokenState? {
        didSet {
            updateState()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        getRequestToken()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.preventsApplicationTerminationWhenModal = false
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        view.window?.preventsApplicationTerminationWhenModal = true
    }
    
    func getRequestToken() {
        if case .loading = requestTokenState { return }
        let app = TwitterAuthApp.default
        let request = app.getRequestToken()
        requestTokenState = .loading
        Alamofire.request(request).responseString { [unowned self] res in
            switch res.result {
            case .success(let str):
                let httpRes = res.response!
                guard httpRes.statusCode == 200 else {
                    self.requestTokenState = .error(.http(code: httpRes.statusCode, message: str))
                    return
                }
                let res = str.parseQueryParameters()
                guard res["oauth_callback_confirmed"] == "true" else {
                    self.requestTokenState = .error(.internal(message: "oauth_callback_confirmed is not true"))
                    return
                }
                guard let token = res["oauth_token"], let tokenSecret = res["oauth_token_secret"] else {
                    self.requestTokenState = .error(.internal(message: "failed to find oauth_token or secret"))
                    return
                }
                self.requestTokenState = .success(.init(app: app, token: token, tokenSecret: tokenSecret))
            case .failure(let err):
                self.requestTokenState = .error(.native(error: err))
            }
        }
    }
    
    func updateState() {
        if case .loading = requestTokenState {
            progressIndicator.startAnimation(self)
            progressIndicator.isHidden = false
            authorizeUrlField.stringValue = "取得中…"
            refreshUrlButton.isEnabled = false
        } else {
            progressIndicator.stopAnimation(self)
            progressIndicator.isHidden = true
            refreshUrlButton.isEnabled = true
        }
        
        if case .error(let err) = requestTokenState {
            switch err {
            case .native(let error):
                authorizeUrlField.stringValue = "エラー(ネイティブ):\n\(error.localizedDescription)\n\nInternal: \(error)"
            case .http(let code, let message):
                authorizeUrlField.stringValue = "エラー(HTTP \(code)):\n\(message)"
            case .internal(let message):
                authorizeUrlField.stringValue = "エラー(内部):\n\(message)"
            }
        }
        
        if case .success(let token) = requestTokenState {
            let url = token.authorizeURL
            authorizeUrlField.attributedStringValue = NSAttributedString(string: url.absoluteString, attributes: [
                .link: url,
                .font: self.authorizeUrlField.font!,
            ])
        }
    }
    
    @IBAction func quitButtonClicked(_ sender: Any) {
        self.dismiss(self)
        NSApplication.shared.terminate(self)
    }
    
    @IBAction func refreshUrlButtonClicked(_ sender: Any) {
        getRequestToken()
    }
}
