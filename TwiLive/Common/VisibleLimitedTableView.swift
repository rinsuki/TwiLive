//
//  VisibleLimitedTableView.swift
//  TwiLive
//
//  Created by user on 2019/09/18.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import AppKit

class VisibleLimitedTableView: NSTableView {
    override func prepareContent(in rect: NSRect) {
        super.prepareContent(in: visibleRect)
    }
}
