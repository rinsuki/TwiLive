//
//  TweetView.swift
//  TwiLive
//
//  Created by user on 2021/12/14.
//  Copyright © 2021 rinsuki. All rights reserved.
//

import SwiftUI
import NukeUI

fileprivate let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = .init(identifier: "en_US_POSIX")
    formatter.dateFormat = "HH:mm:ss"
    return formatter
}()

struct TweetView: View {
    var tweet: TwitterStatus
    
    var body: some View {
        HStack {
            LazyImage(source: tweet.user.profileImageURL.replacingOccurrences(of: "_normal.", with: "."))
                .frame(width: 48, height: 48)
//            image.frame(width: 48, height: 48)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(tweet.user.name)
                        .lineLimit(1)
                        .layoutPriority(500)
                    Text("@\(tweet.user.screenName)" as String)
                        .lineLimit(1)
                        .foregroundColor(.secondary)
                        .layoutPriority(900)
                    Spacer()
                    Text(formatter.string(from: tweet.createdAt))
                        .lineLimit(1)
                        .layoutPriority(800)
                }
                Text(tweet.text)
                Text(tweet.source)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
    }
}
