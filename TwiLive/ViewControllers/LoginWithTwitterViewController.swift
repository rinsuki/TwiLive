//
//  LoginWithTwitterViewController.swift
//  TwiLive
//
//  Created by user on 2019/09/14.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import Cocoa
import Alamofire
import Ikemen

protocol LoginWithTwitterViewControllerDelegate: class {
    func didFinishAuthorize(token: TwitterAuthAccessToken) -> Void
}

class LoginWithTwitterViewController: NSViewController {
    
    private let progressIndicator = NSProgressIndicator() ※ { v in
        v.style = .spinning
        v.snp.makeConstraints { make in
            make.width.equalTo(16)
        }
    }
    
    private let authorizeUrlField = TextLabel() ※ { v in
        v.isSelectable = true
        v.allowsEditingTextAttributes = true
        v.maximumNumberOfLines = 0
        v.setContentHuggingPriority(.init(rawValue: 249), for: .horizontal)
        v.setContentCompressionResistancePriority(.required, for: .vertical)
    }
    
    private let refreshUrlButton = NSButton(title: "再取得", target: self, action: #selector(refreshUrlButtonClicked(_:)))
    
    private let oauthCodeField = NSTextField() ※ { v in
        v.placeholderString = "1234567"
    }
    
    private let quitButton = NSButton(title: "終了", target: self, action: #selector(quitButtonClicked(_:))) ※ { v in
        v.keyEquivalent = "\u{1b}"
    }
    
    private let authorizeSubmitButton = NSButton(title: "認証", target: self, action: #selector(authorizeButtonClicked(_:))) ※ { v in
        v.keyEquivalent = "\r"
    }
    
    weak var delegate: LoginWithTwitterViewControllerDelegate?
    
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
            DispatchQueue.main.async { [weak self] in self?.updateState() }
        }
    }
    
    override func loadView() {
        view = NSStackView(views: [
            TextLabel() ※ { v in
                v.stringValue = "Twitterアカウントでログインしてください"
                v.font = .boldSystemFont(ofSize: 16)
            },
            TextLabel() ※ { v in
                v.wantsLayer = true
                v.stringValue = """
このアプリケーションを利用するためには、
ブラウザでこのアプリにTwitterアカウントへのアクセス許可を与える必要があります
"""
                v.maximumNumberOfLines = 0
            },
            NSStackView(views: [
                progressIndicator,
                authorizeUrlField,
                refreshUrlButton,
            ]) ※ { v in
                v.setHuggingPriority(.defaultHigh, for: .vertical)
            },
            TextLabel() ※ { v in
                v.stringValue = "上のURLをブラウザで開き認証した後、表示されたPINコードを入力してください。"
            },
            oauthCodeField,
            NSStackView(views: [
                quitButton,
                SpacerView(),
                authorizeSubmitButton
            ]) ※ { v in
                v.setHuggingPriority(.required, for: .vertical)
            },
        ]) ※ { v in
            v.orientation = .vertical
            v.alignment = .leading
            v.edgeInsets = .init(top: 20, left: 20, bottom: 20, right: 20)
            v.snp.makeConstraints { make in make.width.equalTo(480 + (20 * 2)) }
            v.setHuggingPriority(.required, for: .vertical)
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
            authorizeUrlField.layout()
            view.layout()
            view.layoutSubtreeIfNeeded()
            oauthCodeField.isEnabled = true
            authorizeSubmitButton.isEnabled = true
        } else {
            oauthCodeField.isEnabled = false
            authorizeSubmitButton.isEnabled = false
        }
    }
    
    @IBAction func quitButtonClicked(_ sender: Any) {
        self.dismiss(self)
        NSApplication.shared.terminate(self)
    }
    
    @IBAction func refreshUrlButtonClicked(_ sender: Any) {
        getRequestToken()
    }
    
    @IBAction func authorizeButtonClicked(_ sender: Any) {
        guard case .success(let token) = requestTokenState else { return }
        let request = token.getAccessToken(code: oauthCodeField.stringValue)
        Alamofire.request(request).responseString { [unowned self] res in
            switch res.result {
            case .success(let str):
                let res = str.parseQueryParameters()
                guard let accessToken = res["oauth_token"], let tokenSecret = res["oauth_token_secret"],
                      let userIdStr = res["user_id"], let screenName = res["screen_name"] else {
                    return
                }
                let token = TwitterAuthAccessToken(app: token.app, token: accessToken, tokenSecret: tokenSecret, userId: Int64(userIdStr)!, screenName: screenName)
                self.finishAuthorize(token)
            case .failure(let err):
                print(err)
            }
        }
    }
    
    func finishAuthorize(_ token: TwitterAuthAccessToken) {
        self.dismiss(self)
        self.delegate?.didFinishAuthorize(token: token)
    }
}
