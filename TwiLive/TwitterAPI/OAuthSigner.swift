//
//  OAuthSigner.swift
//  TwiLive
//
//  Created by user on 2019/09/15.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import Foundation
import Alamofire

struct OAuthSigner {
    var consumerKey: String
    var consumerSecret: String
    var oauthToken: String = ""
    var oauthSecret: String = ""
    
    func signedRequest(_ method: HTTPMethod, url: URL, params: [String: String]) -> URLRequest {
        // TODO: もっといい乱数を使う
        let nonce = UUID().uuidString
        let currentTimestamp = Int(Date().timeIntervalSince1970)
        var oauthParams = [
            "oauth_consumer_key": consumerKey,
            "oauth_nonce": nonce,
            "oauth_signature_method": "HMAC-SHA1",
            "oauth_timestamp": currentTimestamp.description,
            "oauth_version": "1.0",
            "oauth_token": oauthToken,
        ]
        for (key, value) in params where key.starts(with: "oauth_") {
            oauthParams[key] = value
        }
        let mergedParams = params.merging(oauthParams, uniquingKeysWith: { $1 })
        print(mergedParams)
        let paramsStr = mergedParams
            .sorted { $0.key < $1.key }
            .map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .rfc3986)!)"}
            .joined(separator: "&")
        let signatureTarget = [
            method.rawValue,
            url.absoluteString.addingPercentEncoding(withAllowedCharacters: .rfc3986)!,
            paramsStr.addingPercentEncoding(withAllowedCharacters: .rfc3986)!,
        ]
            .joined(separator: "&")
        let secret = "\(consumerSecret)&\(oauthSecret)"
        guard let signature = signatureTarget.hmacSHA1(key: secret) else { fatalError("Failed to sign")}
        oauthParams["oauth_signature"] = signature
        let header = oauthParams
            .sorted { $0.key < $1.key }
            .map { "\($0.key)=\"\($0.value.addingPercentEncoding(withAllowedCharacters: .rfc3986)!)\""}
            .joined(separator: ", ")
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.addValue(UserAgent, forHTTPHeaderField: "User-Agent")
        request.addValue("OAuth " + header, forHTTPHeaderField: "Authorization")
        return request
        
    }
}
