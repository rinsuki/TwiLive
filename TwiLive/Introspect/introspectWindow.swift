//
//  introspectWindow.swift
//  TwiLive
//
//  Created by user on 2021/12/26.
//  Copyright © 2021 rinsuki. All rights reserved.
//

import SwiftUI
import Introspect

extension View {
    func introspectWindow(customize: @escaping (NSWindow) -> ()) -> some View {
        return introspect(selector: { $0 }) { view in
            if let window = view.window {
                customize(window)
            }
        }
    }
}
