//
//  ViewModel.swift
//  TwiLive
//
//  Created by user on 2019/10/18.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import Foundation
import Combine

class LoginWithTwitterViewModel {
    
    // MARK: Request Token
    enum FetchTokenError {
        case native(error: Error)
        case http(code: Int, message: String)
        case `internal`(message: String)
    }
    
    enum RequestTokenState {
        case loading
        case error(FetchTokenError)
        case success(TwitterAuthRequestToken)
    }
    
    @Published var requestTokenState: RequestTokenState?
    
    var requestTokenCancellable: AnyCancellable?
    
    func getRequestToken() {
        if case .loading = requestTokenState { return }
        let app = TwitterAuthApp.default
        requestTokenState = .loading
        requestTokenCancellable = URLSession.shared
            .dataTaskPublisher(for: app.getRequestToken())
            .map { (data, response) -> RequestTokenState in
                guard let str = String(data: data, encoding: .utf8) else {
                    return .error(.internal(message: "Failed to parse response as UTF-8 string"))
                }
                guard let response = response as? HTTPURLResponse else {
                    return .error(.internal(message: "Failed to cast URLResponse → HTTPURLResponse"))
                }
                guard response.statusCode == 200 else {
                    return .error(.http(code: response.statusCode, message: str))
                }
                let res = str.parseQueryParameters()
                guard res["oauth_callback_confirmed"] == "true" else {
                    return .error(.internal(message: "oauth_callback_confirmed is not true"))
                }
                guard let token = res["oauth_token"], let tokenSecret = res["oauth_token_secret"] else {
                    return .error(.internal(message: "failed to find oauth_token or secret"))
                }
                return .success(.init(app: app, token: token, tokenSecret: tokenSecret))
            }
            .catch { error in
                Just(.error(.native(error: error)))
            }
            .assign(to: \.requestTokenState, on: self)
    }
    
    // MARK: Access Token
    
    @Published var code: String = ""
    
    lazy var canFetchAccessToken: AnyPublisher<Bool, Never> = Publishers.CombineLatest3(
        self.$requestTokenState,
        self.$code,
        self.$accessTokenState
    )
        .map { requestTokenState, code, accessTokenState in
            if case .loading = accessTokenState { return false }
            guard case .success(_) = requestTokenState, code.count >= 7  else {
                return false
            }
            return true
        }
        .eraseToAnyPublisher()
    
    enum AccessTokenState {
        case loading
        case error(FetchTokenError)
        case fetched(TwitterAuthAccessToken)
    }
    
    @Published var accessTokenState: AccessTokenState?
    var accessTokenCancellable: AnyCancellable?
    
    func getAccessToken() {
        guard case .success(let requestToken) = requestTokenState else { return }
        let code = self.code
        accessTokenState = .loading
        accessTokenCancellable = URLSession.shared
            .dataTaskPublisher(for: requestToken.getAccessToken(code: code))
            .map { data, response -> AccessTokenState in
                guard let str = String(data: data, encoding: .utf8) else {
                    return .error(.internal(message: "Failed to parse response as UTF-8 string"))
                }
                guard let response = response as? HTTPURLResponse else {
                    return .error(.internal(message: "Failed to cast URLResponse → HTTPURLResponse"))
                }
                guard response.statusCode == 200 else {
                    return .error(.http(code: response.statusCode, message: str))
                }
                let res = str.parseQueryParameters()
                guard let accessToken = res["oauth_token"], let tokenSecret = res["oauth_token_secret"],
                      let userIdStr = res["user_id"], let screenName = res["screen_name"] else {
                    return .error(.internal(message: "some parameters not exists"))
                }
                let token = TwitterAuthAccessToken(
                    app: requestToken.app,
                    token: accessToken, tokenSecret: tokenSecret,
                    userId: Int64(userIdStr)!, screenName: screenName
                )
                return .fetched(token)
            }
            .catch { error in
                Just(.error(.native(error: error)))
            }
            .assign(to: \.accessTokenState, on: self)
    }
}
