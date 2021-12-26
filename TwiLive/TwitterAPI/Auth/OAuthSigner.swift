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
        let bodyParams = params.filter { (key, value) in !key.starts(with: "oauth_") }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        if bodyParams.count > 0{
            let paramsString = bodyParams
                .sorted { $0.key < $1.key }
                .map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .rfc3986)!)"}
                .joined(separator: "&")
            if method == .get {
                print(paramsString)
                var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
                components.percentEncodedQuery = paramsString
                request.url = components.url
            } else {
                let paramsData = paramsString.data(using: .utf8)!
                request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                request.httpBody = paramsData
            }
        }
        request.addValue(UserAgent, forHTTPHeaderField: "User-Agent")
        request.addValue("OAuth " + header, forHTTPHeaderField: "Authorization")
        return request
    }
    
    func data(_ method: HTTPMethod, url: URL, params: [String: String]) async throws -> (Data, URLResponse) {
        let request = signedRequest(method, url: url, params: params)
        return try await URLSession.shared.data(for: request)
    }
}
