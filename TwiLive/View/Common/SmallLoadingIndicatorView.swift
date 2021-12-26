//
//  SmallLoadingIndicatorView.swift
//  TwiLive
//
//  Created by user on 2021/12/16.
//  Copyright © 2021 rinsuki. All rights reserved.
//

import SwiftUI

struct SmallLoadingIndicatorView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSProgressIndicator {
        let v = NSProgressIndicator(frame: .init(x: 0, y: 0, width: 16, height: 16))
        v.translatesAutoresizingMaskIntoConstraints = false
        v.widthAnchor.constraint(equalToConstant: 16).isActive = true
        v.heightAnchor.constraint(equalToConstant: 16).isActive = true
        v.style = .spinning
        v.startAnimation(nil)
        return v
    }
    
    func updateNSView(_ nsView: NSProgressIndicator, context: Context) {
    }
}
