//
//  TwitterStatus.swift
//  TwiLive
//
//  Created by user on 2019/09/15.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import Foundation

struct SubStatus: Codable, Hashable {
    
}

struct ExtendedTweet: Codable, Hashable {
    var full_text: String
    var entities: TwitterEntities
}

struct TwitterEntities: Codable, Hashable {
    struct Hashtag: Codable, Hashable {
        var text: String
    }
    var hashtags: [Hashtag]
}

struct TwitterStatus: Codable, Identifiable, Hashable {
    var id: Int64
    var source: String
    var user: TwitterUser
    var _text: String?
    var _fullText: String?
    var retweetedStatus: SubStatus?
    var truncated: Bool
    var _entities: TwitterEntities
    var extendedTweet: ExtendedTweet?
    
    var createdAt: Date
    
    var text: String {
        return extendedTweet?.full_text ?? _fullText ?? _text!
    }
    
    var entities: TwitterEntities {
        return extendedTweet?.entities ?? _entities
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case source
        case user
        case _text = "text"
        case _fullText = "full_text"
        case truncated
        case extendedTweet = "extended_tweet"
        case retweetedStatus = "retweeted_status"
        case createdAt = "created_at"
        case _entities = "entities"
    }
}
