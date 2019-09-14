//
//  UserAgent.swift
//  TwiLive
//
//  Created by user on 2019/09/14.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import Cocoa

fileprivate func getOSVersionString() -> String {
    let version = ProcessInfo.processInfo.operatingSystemVersion
    var str = "\(version.majorVersion).\(version.minorVersion)"
    if version.patchVersion > 0 {
        str += ".\(version.patchVersion)"
    }
    return str
}
let UserAgent = "TwiLive-Mac/\(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String) macOS/\(getOSVersionString())"
