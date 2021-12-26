//
//  AuthorizedAccountStore.swift
//  TwiLive
//
//  Created by user on 2021/12/16.
//  Copyright © 2021 rinsuki. All rights reserved.
//

import Foundation
import KeychainAccess
import Combine

fileprivate let keychain = Keychain(service: "net.rinsuki.apps.mac.TwiLive.keychain")
fileprivate let jsonEncoder = JSONEncoder()
fileprivate let jsonDecoder = JSONDecoder()

class AuthorizedAccountStore: ObservableObject {
    @Published var accessToken: TwitterAuthAccessToken? {
        didSet {
            if let token = accessToken {
                let data = try! JSONEncoder().encode(token)
                keychain[data: "twitter.accessToken"] = data
            } else {
                try! keychain.remove("twitter.accessToken")
            }
        }
    }
    
    init() {
        if let data = keychain[data: "twitter.accessToken"], let token = try? jsonDecoder.decode(TwitterAuthAccessToken.self, from: data) {
            accessToken = token
        } else {
            accessToken = nil
        }
    }
}
