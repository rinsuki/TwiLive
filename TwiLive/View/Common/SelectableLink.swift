//
//  SelectableLink.swift
//  TwiLive
//
//  Created by user on 2021/12/16.
//  Copyright © 2021 rinsuki. All rights reserved.
//

import SwiftUI

struct SelectableLink: NSViewRepresentable {
    let url: URL
    
    private func attributedString() -> NSAttributedString {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byTruncatingTail
        return NSAttributedString(string: url.absoluteString, attributes: [
            .link: url,
            .font: NSFont.systemFont(ofSize: NSFont.systemFontSize),
            .paragraphStyle: paragraph,
        ])
    }
    
    func makeNSView(context: Context) -> NSTextField {
        let field = NSTextField(labelWithAttributedString: attributedString())
        field.allowsEditingTextAttributes = true
        field.isEditable = false
        field.isSelectable = true
        field.usesSingleLineMode = true
        field.translatesAutoresizingMaskIntoConstraints = false
        field.maximumNumberOfLines = 1
        return field
    }
    
    func updateNSView(_ field: NSTextField, context: Context) {
        if field.attributedStringValue.string != url.absoluteString {
            field.attributedStringValue = attributedString()
        }
    }
}
