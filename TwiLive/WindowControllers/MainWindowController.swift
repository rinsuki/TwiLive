//
//  MainWindowController.swift
//  TwiLive
//
//  Created by user on 2019/09/19.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import Cocoa
import Ikemen

class MainWindowController: NSWindowController {
    let mainVC = MainViewController()
    let toolBar = NSToolbar(identifier: "mainWindowToolbar")
    
    init() {
        super.init(window: NSWindow(contentViewController: mainVC))
        self.windowDidLoad()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        toolBar.allowsUserCustomization = true
        toolBar.delegate = self
        window?.toolbar = toolBar
        window?.showsToolbarButton = true
        print("hoge")
    }
}

extension MainWindowController: NSToolbarDelegate {
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [
            .init("Hashtag"),
        ]
    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [
            .init("Hashtag"),
            .space,
            .flexibleSpace,
        ]
    }
    
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        switch itemIdentifier {
        case .init("Hashtag"):
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            item.label = "ハッシュタグ"
            item.paletteLabel = "ハッシュタグ"
            let button = NSButton(title: "#", target: nil, action: nil)
            button.bezelStyle = .texturedRounded
            item.view = button
            return item
        default:
            return nil
        }
    }
}
