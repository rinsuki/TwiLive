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
    
    enum FetchAccessTokenError: Error {
        case http(code: Int, message: String)
        case `internal`(message: String)
    }
    
    func getAccessTokenRequest(code: String) -> URLRequest {
        return OAuthSigner(consumerKey: app.appKey, consumerSecret: app.appSecret, oauthToken: token, oauthSecret: tokenSecret)
            .signedRequest(.post, url: URL(string: "https://api.twitter.com/oauth/access_token")!, params: ["oauth_verifier": code])
    }
    
    func getAccessToken(code: String) async throws -> TwitterAuthAccessToken {
        let (data, response) = try await URLSession.shared.data(for: getAccessTokenRequest(code: code))
        guard let str = String(data: data, encoding: .utf8) else {
            throw FetchAccessTokenError.internal(message: "Failed to parse response as UTF-8 string")
        }
        guard let response = response as? HTTPURLResponse else {
            throw FetchAccessTokenError.internal(message: "Failed to cast URLResponse → HTTPURLResponse")
        }
        guard response.statusCode == 200 else {
            throw FetchAccessTokenError.http(code: response.statusCode, message: str)
        }
        let res = str.parseQueryParameters()
        guard let accessToken = res["oauth_token"], let tokenSecret = res["oauth_token_secret"],
              let userIdStr = res["user_id"], let screenName = res["screen_name"] else {
            throw FetchAccessTokenError.internal(message: "some parameters not exists")
        }
        return TwitterAuthAccessToken(
            app: app,
            token: accessToken, tokenSecret: tokenSecret,
            userId: Int64(userIdStr)!, screenName: screenName
        )
    }
}
