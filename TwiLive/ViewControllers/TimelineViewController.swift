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
    
    var queuedTweets = [TwitterStatus]()
    
    override func loadView() {
        view = scrollView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    let decoder = JSONDecoder() ※ { decoder in
        let formatter = DateFormatter()
        formatter.locale = .init(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
        decoder.dateDecodingStrategy = .formatted(formatter)
    }
    
    func tokenUpdated() {
        guard let token = accessToken else { return }
        let request = token.signer.signedRequest(
            .get, url: URL(string: "https://api.twitter.com/1.1/search/tweets.json")!,
            params: ["q": "MU2020", "result_type": "recent", "count": "100"]
        )
        AF.request(request).responseData { [unowned self] res in
            switch res.result {
            case .success(let data):
                print(String(data: data, encoding: .utf8))
                let obj = try! self.decoder.decode(TwitterSearchResult.self, from: data)
                DispatchQueue.main.async {
                    self.addTweets(obj.statuses)
                }
                let streamReq = token.signer.signedRequest(
                    .post, url: URL(string: "https://stream.twitter.com/1.1/statuses/filter.json")!,
                    params: ["track": "MU2020", "tweet_mode": "extended"]
                )
                let queue = OperationQueue()
                queue.underlyingQueue = DispatchQueue.global(qos: .userInteractive)
                let task = URLSession(configuration: .ephemeral, delegate: self, delegateQueue: queue).dataTask(with: streamReq)
                task.resume()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func addTweets(_ newTweets_: [TwitterStatus]) {
        let newTweets = newTweets_.filter { s in s.retweetedStatus == nil}
        tableView.beginUpdates()
        tweets.insert(contentsOf: newTweets, at: 0)
        tableView.insertRows(at: IndexSet(integersIn: 0..<newTweets.count), withAnimation: .effectGap)
        if tweets.count > 120 {
            let range = 100..<tweets.count
            print(range)
            tweets.removeSubrange(range)
            tableView.removeRows(at: .init(integersIn: range), withAnimation: .effectGap)
        }
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


extension TimelineViewController: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let str = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .init(charactersIn: "\n\r")) else { return }
        do {
            let tweet = try decoder.decode(TwitterStatus.self, from: str.data(using: .utf8)!)
            DispatchQueue.main.async {
                self.addTweets([tweet])
            }
        } catch {
            print(str)
            print(error)
        }
    }
}
