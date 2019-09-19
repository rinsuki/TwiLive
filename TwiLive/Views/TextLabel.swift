//
//  TextLabel.swift
//  TwiLive
//
//  Created by user on 2019/09/18.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import Cocoa

class TextLabel: NSTextField {
    init(string: String? = nil) {
        super.init(frame: .zero)
        isEditable = false
        drawsBackground = false
        isBezeled = false
        maximumNumberOfLines = 1
        setContentCompressionResistancePriority(.init(9), for: .horizontal)
        font = .systemFont(ofSize: NSFont.systemFontSize)
        if let string = string {
            stringValue = string
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
