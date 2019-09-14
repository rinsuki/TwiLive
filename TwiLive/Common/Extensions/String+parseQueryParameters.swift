//
//  String+parseQueryParameters.swift
//  TwiLive
//
//  Created by user on 2019/09/15.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import Foundation

extension String {
    func parseQueryParameters() -> [String: String] {
        var dict: [String:String] = [:]
        for comp in self.split(separator: "&") {
            let c = comp.split(separator: "=").map(String.init)
            dict[c[0]] = c[1]
        }
        return dict
    }
}
