//
//  TwiLiveApp.swift
//  TwiLive
//
//  Created by user on 2021/12/14.
//  Copyright © 2021 rinsuki. All rights reserved.
//

import SwiftUI

@main
struct TwiLiveApp: App {
    @ObservedObject var accountStore = AuthorizedAccountStore()

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(accountStore)
        }
        .commands {
            CommandGroup(replacing: .newItem) {
            }
        }
    }
}
