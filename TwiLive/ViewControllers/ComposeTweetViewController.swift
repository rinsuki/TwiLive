//
//  ComposeTweetViewController.swift
//  TwiLive
//
//  Created by user on 2019/09/15.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import Cocoa
import Alamofire

class ComposeTweetViewController: NSViewController {
    @IBOutlet var textView: NSTextView!
    @IBOutlet weak var authorizedAccountScreenNameLabel: NSTextField!
    @IBOutlet weak var tweetButton: NSButton!
    
    var accessToken: TwitterAuthAccessToken? {
        didSet {
            accessTokenUpdated()
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
        Alamofire.request(token.signer.signedRequest(
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
