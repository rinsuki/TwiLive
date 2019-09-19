//
//  NSEdgeInsets+easyInit.swift
//  TwiLive
//
//  Created by user on 2019/09/19.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import Foundation

extension NSEdgeInsets {
    init(all: CGFloat) {
        self.init(top: all, left: all, bottom: all, right: all)
    }
    
    init(horizontal: CGFloat, vertical: CGFloat) {
        self.init(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
    }
}
