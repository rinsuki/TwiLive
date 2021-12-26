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
    
    func getRequestTokenRequest() -> URLRequest {
        return OAuthSigner(consumerKey: appKey, consumerSecret: appSecret).signedRequest(
            .post, url: URL(string: "https://api.twitter.com/oauth/request_token")!,
            params: ["oauth_callback": "oob"]
        )
    }
    
    enum FetchRequestTokenError: Error {
        case http(code: Int, message: String)
        case `internal`(message: String)
    }
    
    func getRequestToken() async throws -> TwitterAuthRequestToken {
        let (data, response) = try await URLSession.shared.data(for: getRequestTokenRequest())
        guard let str = String(data: data, encoding: .utf8) else {
            throw FetchRequestTokenError.internal(message: "Failed to parse response as UTF-8 string")
        }
        guard let response = response as? HTTPURLResponse else {
            throw FetchRequestTokenError.internal(message: "Failed to cast URLResponse → HTTPURLResponse")
        }
        guard response.statusCode == 200 else {
            throw FetchRequestTokenError.http(code: response.statusCode, message: str)
        }
        let res = str.parseQueryParameters()
        guard res["oauth_callback_confirmed"] == "true" else {
            throw FetchRequestTokenError.internal(message: "oauth_callback_confirmed is not true")
        }
        guard let token = res["oauth_token"], let tokenSecret = res["oauth_token_secret"] else {
            throw FetchRequestTokenError.internal(message: "failed to find oauth_token or secret")
        }

        return TwitterAuthRequestToken(app: self, token: token, tokenSecret: tokenSecret)
    }
}
