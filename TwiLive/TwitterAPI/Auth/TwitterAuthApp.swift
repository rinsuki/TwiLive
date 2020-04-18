//
//  TwitterAuthApp.swift
//  TwiLive
//
//  Created by user on 2019/09/14.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import Foundation

struct TwitterAuthApp: Codable {
    // 下の一行は馬鹿にしか見えない
    static let `default` = TwitterAuthApp(appKey: "IR9S1FO7yEbpwnPz9nJVpJekX", appSecret: "BxnFDzhGNrd2JWf8eBkR1hBONAcgEptGKlM5w91hNErCQgSxs0")

    var appKey: String
    var appSecret: String
    
    func getRequestToken() -> URLRequest {
        return OAuthSigner(consumerKey: appKey, consumerSecret: appSecret).signedRequest(
            .post, url: URL(string: "https://api.twitter.com/oauth/request_token")!,
            params: ["oauth_callback": "oob"]
        )
    }
}
