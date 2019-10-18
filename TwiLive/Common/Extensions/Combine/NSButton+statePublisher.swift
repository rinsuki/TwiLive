//
//  NSButton+statePublisher.swift
//  TwiLive
//
//  Created by user on 2019/10/18.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import Cocoa
import Combine

extension NSButton {
    func statePublisher(withInitialValue: Bool = false) -> AnyPublisher<NSControl.StateValue, Never> {
        cell!.publisher(for: \.state, options: withInitialValue ? [.initial, .new] : .new)
            .eraseToAnyPublisher()
    }
}
