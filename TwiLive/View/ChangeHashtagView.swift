//
//  ChangeHashtagView.swift
//  TwiLive
//
//  Created by user on 2021/12/26.
//  Copyright © 2021 rinsuki. All rights reserved.
//

import SwiftUI

struct ChangeHashtagView: View {
    @EnvironmentObject var accountStore: AuthorizedAccountStore
    @EnvironmentObject var timelineStore: TimelineStore
    @Binding var isHashtagChanging: Bool
    @State var newHashtag: String = ""
    var canSubmit: Bool {
        return newHashtag.count > 0
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("ハッシュタグ:")
                Text("#")
                TextField("EventHashtag", text: $newHashtag)
                    .frame(width: 200)
                    .lineLimit(1)
                    .submitLabel(.done)
                    .onSubmit {
                        submit()
                    }
            }
            HStack {
                Button("キャンセル") {
                    isHashtagChanging = false
                }
                    .keyboardShortcut(.escape, modifiers: [])
                Spacer()
                Button("OK") {
                    submit()
                }
                    .disabled(!canSubmit)
                    .keyboardShortcut("\r", modifiers: [])
            }
        }
        .introspectWindow { window in
            window.preventsApplicationTerminationWhenModal = false
        }
        .onAppear {
            newHashtag = timelineStore.hashtag
        }
    }
    
    func submit() {
        guard canSubmit else {
            return
        }
        isHashtagChanging = false
        if let accessToken = accountStore.accessToken {
            timelineStore.start(hashtag: newHashtag, accessToken: accessToken)
        }
    }
}
//
//struct ChangeHashtagView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChangeHashtagView()
//    }
//}
