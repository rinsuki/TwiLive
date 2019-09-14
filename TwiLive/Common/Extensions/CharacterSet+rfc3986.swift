//
//  CharacterSet+rfc3986.swift
//  TwiLive
//
//  Created by user on 2019/09/14.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import Foundation

extension CharacterSet {
    static var rfc3986: CharacterSet {
        var base = alphanumerics
        base.insert(charactersIn: "-_.~")
        return base
    }
    
    static var rfc3986WithSlash: CharacterSet {
        var base = rfc3986
        base.insert("/")
        return base
    }
}
