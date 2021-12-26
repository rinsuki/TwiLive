//
//  TimelineView.swift
//  TwiLive
//
//  Created by user on 2021/12/14.
//  Copyright © 2021 rinsuki. All rights reserved.
//

import SwiftUI
import Introspect

struct TimelineView: View {
    @EnvironmentObject var accountStore: AuthorizedAccountStore
    @EnvironmentObject var timelineStore: TimelineStore
    @State var tweets: [TwitterStatus] = []
    @State var count = 0
    @State var selectedTweet: TwitterStatus?
    
    var body: some View {
        if let token = accountStore.accessToken {
            List(timelineStore.tweets, selection: $selectedTweet) { tweet in
                TweetView(tweet: tweet)
                    .listRowInsets(.init(top: 8, leading: 0, bottom: 8, trailing: 0))
                    .animation(nil)
                    .contextMenu {
                        Button("ツイートをブラウザで開く") {
                            NSWorkspace.shared.open(URL(string: "https://twitter.com/i/status/\(tweet.id)")!)
                        }
                    }
            }
            .listStyle(.plain)
            .introspectTableView { tableView in
                tableView.gridStyleMask = .solidHorizontalGridLineMask
            }
        } else {
            List {
                Text("ログインしてください")
            }
        }
    }
}

struct TimelineView_Previews: PreviewProvider {
    static var previews: some View {
        TimelineView()
    }
}
