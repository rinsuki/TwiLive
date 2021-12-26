//
//  ComposeTweetView.swift
//  TwiLive
//
//  Created by user on 2021/12/14.
//  Copyright © 2021 rinsuki. All rights reserved.
//

import SwiftUI
import Introspect

struct ComposeTweetView: View {
    @EnvironmentObject var accountStore: AuthorizedAccountStore
    let hashtag: String
    @State var text: String = ""
    @State var isTweetSending = false
    
    var body: some View {
        VStack(spacing: 8) {
            TextEditor(text: $text)
                .frame(minHeight: 36, idealHeight: 100)
                .introspectTextView { textView in
                    textView.enclosingScrollView?.borderType = .bezelBorder
                    textView.setValue("@\(accountStore.accessToken?.screenName ?? "...")で\(hashtag.count > 0 ? "#\(hashtag)を付けて" : "")ツイート", forKey: "placeholderString")
                }
                .font(.system(size: NSFont.systemFontSize))
                .disabled(isTweetSending)
            HStack {
                if let token = accountStore.accessToken {
                    Text("@\(token.screenName)")
                        .lineLimit(1)
                        .fixedSize()
                    Button("ログアウト") {
                        accountStore.accessToken = nil
                    }
                        .fixedSize()
                } else {
                    Text("ログインしていません")
                        .fixedSize()
                }
                Spacer()
                Button("ツイート") {
                    guard let token = accountStore.accessToken else {
                        return
                    }
                    isTweetSending = true
                    if hashtag.count > 0 {
                        text += " #" + hashtag
                    }
                    Task {
                        defer {
                            DispatchQueue.main.async {
                                isTweetSending = false
                            }
                        }
                        do {
                            let res = try await token.signer.data(.post, url: URL(string: "https://api.twitter.com/1.1/statuses/update.json")!, params: [
                                "status": text,
                            ])
                            print(res)
                            text = ""
                        } catch {
                            print(error)
                        }
                    }
                }
                .keyboardShortcut("\r", modifiers: .command)
                .fixedSize()
                .disabled(text.count == 0)
                .disabled(accountStore.accessToken == nil)
                .disabled(isTweetSending)
            }
        }
        .scenePadding()
    }
}

struct ComposeTweetView_Previews: PreviewProvider {
    static var previews: some View {
        ComposeTweetView(hashtag: "")
    }
}
