//
//  TwitterAuthApp.swift
//  TwiLive
//
//  Created by user on 2019/09/14.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import Foundation

struct TwitterAuthApp {
    // 下の一行は馬鹿にしか見えない
    static let `default` = TwitterAuthApp(appKey: "IR9S1FO7yEbpwnPz9nJVpJekX", appSecret: "BxnFDzhGNrd2JWf8eBkR1hBONAcgEptGKlM5w91hNErCQgSxs0")

    var appKey: String
    var appSecret: String
    
    func getRequestToken() -> URLRequest {
        let url = URL(string: "https://api.twitter.com/oauth/request_token")!
        // TODO: もっといい乱数を使う
        let nonce = UUID().uuidString
        let currentTimestamp = Int(Date().timeIntervalSince1970)
        var params = [
            "oauth_callback": "oob",
            "oauth_consumer_key": appKey,
            "oauth_nonce": nonce,
            "oauth_signature_method": "HMAC-SHA1",
            "oauth_timestamp": currentTimestamp.description,
            "oauth_version": "1.0",
            "oauth_token": "",
        ]
        let paramsStr = params
            .sorted { $0.key < $1.key }
            .map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .rfc3986)!)"}
            .joined(separator: "&")
        let signatureTarget = [
            "POST",
            url.absoluteString.addingPercentEncoding(withAllowedCharacters: .rfc3986)!,
            paramsStr.addingPercentEncoding(withAllowedCharacters: .rfc3986)!,
        ]
            .joined(separator: "&")
        let secret = "\(appSecret)&"
        guard let signature = signatureTarget.hmacSHA1(key: secret) else { fatalError("Failed to sign")}
        params["oauth_signature"] = signature
        let header = params
            .sorted { $0.key < $1.key }
            .map { "\($0.key)=\"\($0.value.addingPercentEncoding(withAllowedCharacters: .rfc3986)!)\""}
            .joined(separator: ", ")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(UserAgent, forHTTPHeaderField: "User-Agent")
        request.addValue("OAuth " + header, forHTTPHeaderField: "Authorization")
        return request
    }
}
