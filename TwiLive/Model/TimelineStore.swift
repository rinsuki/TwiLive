//
//  TimelineStore.swift
//  TwiLive
//
//  Created by user on 2021/12/26.
//  Copyright © 2021 rinsuki. All rights reserved.
//

import Foundation
import SwiftUI

class TimelineStore: ObservableObject {
    @Published private(set) var hashtag: String = ""
    @Published var tweets: [TwitterStatus] = []
    /// 重複追加を防ぐためにSetにidだけ入れておく
    private var tweetIds = Set<Int64>()
    var currentTask: Task<Void, Error>? {
        didSet {
            if oldValue != currentTask {
                oldValue?.cancel()
            }
        }
    }
    
    deinit {
        currentTask?.cancel()
    }
    
    /// ユーザーがTwitterでミュートしているユーザーIDs
    var muteUserIds = Set<Int64>()
    
    func start(hashtag: String, accessToken: TwitterAuthAccessToken) {
        self.hashtag = hashtag
        Task.detached(priority: .userInitiated) {
            let decoder = JSONDecoder()
            let formatter = DateFormatter()
            formatter.locale = .init(identifier: "en_US_POSIX")
            formatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
            decoder.dateDecodingStrategy = .formatted(formatter)
            let fetchMuteListTask = Task {
                guard self.muteUserIds.count == 0 else {
                    return
                }
                // TODO: paging
                let (muteIdsData, muteIdsResponse) = try await accessToken.signer.data(
                    .get, url: URL(string: "https://api.twitter.com/1.1/mutes/users/ids.json")!,
                    params: [:]
                )
                struct MuteIDs: Codable {
                    let ids: [Int64]
                }
                let muteIds = try decoder.decode(MuteIDs.self, from: muteIdsData)
                self.muteUserIds = .init(muteIds.ids)
            }
            await MainActor.run {
                self.tweets = []
                self.tweetIds = .init()
            }
            let (searchData, searchResponse) = try await accessToken.signer.data(
                .get, url: URL(string: "https://api.twitter.com/1.1/search/tweets.json")!,
                params: ["q": "#" + hashtag + " exclude:retweets", "result_type": "recent", "count": "50", "tweet_mode": "extended"]
            )
//            print(String(data: searchData, encoding: .utf8))
            let searchResult = try decoder.decode(TwitterSearchResult.self, from: searchData)
            try await fetchMuteListTask.get()
            let tweets = searchResult.statuses.filter { !self.isTweetShouldSkip(tweet: $0) }
            await MainActor.run {
                self.tweets = tweets
                self.tweetIds = .init(tweets.map { $0.id })
            }
            let streamReq = accessToken.signer.signedRequest(
                .post, url: URL(string: "https://stream.twitter.com/1.1/statuses/filter.json")!,
                params: ["track": hashtag]
            )
            let (stream, streamRes) = try await URLSession.shared.bytes(for: streamReq)
            for try await line in stream.lines {
                if line.starts(with: "{") {
                    do {
                        let tweet = try decoder.decode(TwitterStatus.self, from: line.data(using: .utf8)!)
                        if tweet.retweetedStatus != nil {
                            continue
                        }
                        if self.tweetIds.contains(tweet.id) {
                            continue
                        }
                        if self.isTweetShouldSkip(tweet: tweet) {
                            continue
                        }
                        await MainActor.run {
                            withAnimation(.default) {
                                self.tweets.insert(tweet, at: 0)
                                self.tweetIds.update(with: tweet.id)
                                while self.tweets.count > 100 {
                                    if let tweet = self.tweets.popLast() {
                                        self.tweetIds.remove(tweet.id)
                                    }
                                }
                            }
                        }
                    } catch {
                        print("failed to parse tweet", error)
                    }
                } else {
                    print(line)
                }
            }
        }
    }
    
    func isTweetShouldSkip(tweet: TwitterStatus) -> Bool {
        if tweet.source.contains("Rakuten Group, Inc.") {
            return true
        }
        if muteUserIds.contains(tweet.user.id) {
            return true
        }
        return !tweet.entities.hashtags.contains { $0.text.lowercased() == hashtag.lowercased() }
    }
}
