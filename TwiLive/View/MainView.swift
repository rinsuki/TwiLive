//
//  MainView.swift
//  TwiLive
//
//  Created by user on 2021/12/14.
//  Copyright © 2021 rinsuki. All rights reserved.
//

import SwiftUI
import Introspect

struct MainView: View {
    @EnvironmentObject var accountStore: AuthorizedAccountStore
    @ObservedObject var timelineStore = TimelineStore()
    @State var isHashtagChanging = false
    
    var body: some View {
        VSplitView {
            TimelineView()
            ComposeTweetView(hashtag: timelineStore.hashtag)
        }
        .animation(nil)
        .introspectSplitViewController { vc in
            vc.splitViewItems.last?.holdingPriority = .init(rawValue: 251)
        }
        .sheet(isPresented: .init(get: { accountStore.accessToken == nil }, set: { _ in }), onDismiss: nil) {
            LoginView()
        }
        .toolbar {
            Button {
                isHashtagChanging = true
            } label: {
                Image(systemName: "number")
            }
            .sheet(isPresented: $isHashtagChanging) {
                ChangeHashtagView(isHashtagChanging: $isHashtagChanging)
                    .scenePadding()
            }
        }
        .environmentObject(timelineStore)
        .navigationSubtitle(Text(timelineStore.hashtag.count > 0 ? "#\(timelineStore.hashtag)" : ""))
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
