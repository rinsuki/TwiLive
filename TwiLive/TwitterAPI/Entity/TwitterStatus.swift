//
//  TwitterStatus.swift
//  TwiLive
//
//  Created by user on 2019/09/15.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import Foundation

struct TwitterStatus: Codable {
    var id: Int64
    var source: String
    var user: TwitterUser
    var text: String
    
    var createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case source
        case user
        case text = "full_text"
        case createdAt = "created_at"
    }
}
