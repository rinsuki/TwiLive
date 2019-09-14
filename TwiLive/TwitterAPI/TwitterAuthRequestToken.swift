//
//  TwitterAuthRequestToken.swift
//  TwiLive
//
//  Created by user on 2019/09/15.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import Foundation

struct TwitterAuthRequestToken {
    var app: TwitterAuthApp
    var token: String
    var tokenSecret: String
    
    var authorizeURL: URL {
        URL(string: "https://twitter.com/oauth/authorize?oauth_token=\(token)")!
    }
    
    func getAccessToken(code: String) -> URLRequest {
        return OAuthSigner(consumerKey: app.appKey, consumerSecret: app.appSecret, oauthToken: token, oauthSecret: tokenSecret)
            .signedRequest(.post, url: URL(string: "https://api.twitter.com/oauth/access_token")!, params: ["oauth_verifier": code])
    }
}
