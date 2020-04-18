//
//  ComposeTweetViewController.swift
//  TwiLive
//
//  Created by user on 2019/09/15.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import Cocoa
import Alamofire
import Ikemen

class ComposeTweetViewController: NSViewController {
    private let textView = NSTextView() ※ { v in
        v.isEditable = true
        v.autoresizingMask = .width
    }
    
    private lazy var textScrollView = NSScrollView() ※ { v in
        v.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(48)
        }
        v.documentView = self.textView
        v.borderType = .bezelBorder
        v.hasVerticalScroller = true
    }
    
    private let authorizedAccountScreenNameLabel = TextLabel() ※ { v in
        v.font = .boldSystemFont(ofSize: NSFont.systemFontSize)
        v.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    private let tweetButton = NSButton(title: "ツイート", target: self, action: #selector(tweetButtonClicked(_:))) ※ { v in
        v.keyEquivalent = "\r"
        v.keyEquivalentModifierMask = .command
    }
    
    var accessToken: TwitterAuthAccessToken? {
        didSet {
            accessTokenUpdated()
        }
    }
    
    override func loadView() {
        view = NSStackView(views: [
            textScrollView,
            NSStackView(views: [
                TextLabel(string: "認証中:") ※ { v in v.setContentCompressionResistancePriority(.required, for: .horizontal) },
                authorizedAccountScreenNameLabel,
                SpacerView(),
                tweetButton,
            ]) ※ { v in
                v.setHuggingPriority(.defaultHigh, for: .horizontal)
            }
        ]) ※ { v in
            v.orientation = .vertical
            v.edgeInsets = .init(all: 16)
            v.setHuggingPriority(.defaultHigh, for: .horizontal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        accessTokenUpdated()
    }
    
    func accessTokenUpdated() {
        if let accessToken = accessToken {
            authorizedAccountScreenNameLabel.stringValue = "@" + accessToken.screenName
            authorizedAccountScreenNameLabel.isHidden = false
            tweetButton.isEnabled = true
        } else {
            authorizedAccountScreenNameLabel.isHidden = true
            tweetButton.isEnabled = false
        }
    }
    
    @IBAction func tweetButtonClicked(_ sender: Any) {
        guard let token = accessToken else { return }
        AF.request(token.signer.signedRequest(
            .post, url: URL(string: "https://api.twitter.com/1.1/statuses/update.json")!,
            params: ["status": textView.string]
        )).responseJSON { [unowned self] res in
            switch res.result {
            case .success(let status):
                if res.response?.statusCode != 200 {
                    print(status)
                } else {
                    print(status)
                    self.textView.string = ""
                }
            case .failure(let err):
                print(err)
            }
        }
        
    }
}
