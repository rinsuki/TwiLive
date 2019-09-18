//
//  TwitterUser.swift
//  TwiLive
//
//  Created by user on 2019/09/15.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import Foundation

struct TwitterUser: Codable {
    var id: Int64
    var name: String
    var screenName: String
    var profileImageURL: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case screenName = "screen_name"
        case profileImageURL = "profile_image_url_https"
    }
}
