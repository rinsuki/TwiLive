//
//  String+hmacSHA1.swift
//  TwiLive
//
//  Created by user on 2019/09/14.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import Foundation
import CommonCrypto

extension String {
    public func hmacSHA1(key: String) -> String? {
        guard let cKey = key.cString(using: .utf8) else { return nil }
        guard let cData = self.cString(using: .utf8) else { return nil }
        var result = Array<CUnsignedChar>.init(repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA1), cKey, Int(strlen(cKey)), cData, Int(strlen(cData)), &result)
        let data = Data(bytes: result, count: Int(CC_SHA1_DIGEST_LENGTH))
        return data.base64EncodedString()
    }
}
