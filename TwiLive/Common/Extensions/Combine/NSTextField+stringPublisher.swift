//
//  NSTextField+stringPublisher.swift
//  TwiLive
//
//  Created by user on 2019/10/18.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import Cocoa
import Combine

extension NSTextField {
    var stringPublisher: AnyPublisher<String, Never> {
        NotificationCenter.default.publisher(for: NSControl.textDidChangeNotification, object: self)
            .map { $0.object as! NSTextField }
            .map { $0.stringValue }
            .eraseToAnyPublisher()
    }
}
