//
//  TimelineViewController.swift
//  TwiLive
//
//  Created by user on 2019/09/13.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import Cocoa
import Alamofire
import Ikemen

class TimelineViewController: NSViewController {
    private let tableView = NSTableView(frame: .zero) ※ { v in
        v.headerView = nil
        v.gridStyleMask = .solidHorizontalGridLineMask
        v.usesAutomaticRowHeights = true
        v.addTableColumn(NSTableColumn(identifier: .init("tweets")))
    }
    private lazy var scrollView = NSScrollView(frame: .zero) ※ { v in
        v.hasVerticalScroller = true
        v.documentView = self.tableView
    }
    
    var accessToken: TwitterAuthAccessToken? {
        didSet {
            tokenUpdated()
        }
    }
    
    private var tweets: [TwitterStatus] = []
    
    override func loadView() {
        view = scrollView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tokenUpdated() {
        guard let token = accessToken else { return }
        let request = token.signer.signedRequest(
            .get, url: URL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json")!,
            params: ["tweet_mode": "extended"]
        )
        Alamofire.request(request).responseData { [unowned self] res in
            switch res.result {
            case .success(let data):
                let decoder = JSONDecoder()
                let formatter = DateFormatter()
                formatter.locale = .init(identifier: "en_US_POSIX")
                formatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
                decoder.dateDecodingStrategy = .formatted(formatter)
                let obj = try! decoder.decode(Array<TwitterStatus>.self, from: data)
                self.addTweets(obj)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func addTweets(_ newTweets: [TwitterStatus]) {
        tableView.beginUpdates()
        tweets.insert(contentsOf: newTweets, at: 0)
        tableView.insertRows(at: IndexSet(integersIn: 0..<tweets.count), withAnimation: .effectGap)
        tableView.endUpdates()
    }
}

extension TimelineViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = TweetCellView()
        let tweet = tweets[row]

        cell.load(tweet)

        return cell
    }
}

extension TimelineViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return tweets.count
    }
}
