//
//  TwitterAuthAccessToken.swift
//  TwiLive
//
//  Created by user on 2019/09/15.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import Foundation

struct TwitterAuthAccessToken: Codable {
    var app: TwitterAuthApp
    var token: String
    var tokenSecret: String
    var userId: Int64
    var screenName: String
    
    var signer: OAuthSigner {
        OAuthSigner(consumerKey: app.appKey, consumerSecret: app.appSecret, oauthToken: token, oauthSecret: tokenSecret)
    }
}
