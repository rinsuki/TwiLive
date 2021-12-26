//
//  LoginView.swift
//  TwiLive
//
//  Created by user on 2021/12/14.
//  Copyright © 2021 rinsuki. All rights reserved.
//

import SwiftUI
import Introspect

class LoginViewModel: ObservableObject {
    @MainActor @Published var requestToken: Result<TwitterAuthRequestToken, Error>? = nil
    
    var fetchRequestTokenTask: Task<Void, Never>? = nil
    var fetchAccessTokenTask: Task<Void, Never>? = nil {
        didSet {
            DispatchQueue.main.async {
                self.fetchingAccessToken = self.fetchAccessTokenTask != nil
            }
        }
    }
    @MainActor @Published var fetchingAccessToken: Bool = false
    
    
    @MainActor
    func startFetchRequestToken() {
        guard fetchRequestTokenTask == nil else {
            return
        }
        print("fetching...")
        fetchRequestTokenTask = Task {
            defer {
                fetchRequestTokenTask = nil
            }
            requestToken = nil
            do {
                let token = try await TwitterAuthApp.default.getRequestToken()
                await MainActor.run {
                    requestToken = .success(token)

                }
                print("done")
            } catch {
                requestToken = .failure(error)
            }
        }
    }
    
    @MainActor
    func startFetchAccessToken(code: String, callback: @escaping (TwitterAuthAccessToken) -> Void) {
        guard case let .success(requestToken) = requestToken else {
            return
        }
        
        fetchAccessTokenTask = Task {
            defer {
                fetchAccessTokenTask = nil
            }
            do {
                callback(try await requestToken.getAccessToken(code: code))
            } catch {
                print(error)
            }
        }
    }
}

struct LoginView: View {
    @EnvironmentObject var accountStore: AuthorizedAccountStore
    @ObservedObject var model: LoginViewModel = .init()
    
    @State var pin: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Twitterアカウントでログインしてください").font(.system(size: 16, weight: .bold))
            Text("このアプリケーションを利用するためには、\nブラウザでこのアプリにTwitterアカウントへのアクセス許可を与える必要があります").fixedSize()
            HStack {
                switch model.requestToken {
                case .some(.success(let token)):
                    SelectableLink(url: token.authorizeURL)
                case .some(.failure(let error)):
                    // TODO: more better way
                    Text("Failed... Error: \(error)" as String)
                case .none:
                    Text("Now Loading...")
                }
                Spacer()
                Button("再取得") {
                    model.startFetchRequestToken()
                }
                .disabled(model.requestToken == nil)
            }
            Text("上のURLをブラウザで開き認証した後、表示されたPINコードを入力してください。")
            TextField("PINコード", text: $pin, prompt: Text("1234567"))
            HStack {
                Button("終了") {
                    NSApplication.shared.terminate(nil)
                }
                Spacer()
                if model.fetchingAccessToken {
                    SmallLoadingIndicatorView()
                }
                Button("認証") {
                    model.startFetchAccessToken(code: pin) {
                        accountStore.accessToken = $0
                    }
                }
                .keyboardShortcut("\r")
                .disabled(pin.count < 1)
                .disabled(model.fetchingAccessToken)
            }
        }
        .scenePadding()
        .frame(width: 500)
        .fixedSize()
        .introspectWindow { window in
            window.preventsApplicationTerminationWhenModal = false
        }
        .onAppear {
            model.startFetchRequestToken()
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
