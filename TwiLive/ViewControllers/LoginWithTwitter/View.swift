//
//  View.swift
//  TwiLive
//
//  Created by user on 2019/10/18.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import Cocoa
import Ikemen

class LoginWithTwitterView: NSStackView {
    let progressIndicator = NSProgressIndicator() ※ { v in
        v.style = .spinning
        v.isDisplayedWhenStopped = false
        v.snp.makeConstraints { make in
            make.width.equalTo(16)
        }
    }
    
    let authorizeUrlField = TextLabel() ※ { v in
        v.isSelectable = true
        v.allowsEditingTextAttributes = true
        v.maximumNumberOfLines = 0
        v.setContentHuggingPriority(.init(rawValue: 249), for: .horizontal)
        v.setContentCompressionResistancePriority(.required, for: .vertical)
    }
    
    let refreshUrlButton = NSButton(title: "再取得", target: nil, action: nil)
    
    let oauthCodeField = NSTextField() ※ { v in
        v.placeholderString = "1234567"
    }
    
    let quitButton = NSButton(title: "終了", target: nil, action: nil) ※ { v in
        v.keyEquivalent = "\u{1b}"
    }
    
    let fetchAccessTokenButton = NSButton(title: "認証", target: nil, action: nil) ※ { v in
        v.keyEquivalent = "\r"
    }
   
    init() {
        super.init(frame: .zero)
        let views = [
            TextLabel() ※ { v in
                v.stringValue = "Twitterアカウントでログインしてください"
                v.font = .boldSystemFont(ofSize: 16)
            },
            TextLabel() ※ { v in
                v.wantsLayer = true
                v.stringValue = """
このアプリケーションを利用するためには、
ブラウザでこのアプリにTwitterアカウントへのアクセス許可を与える必要があります
"""
                v.maximumNumberOfLines = 0
            },
            NSStackView(views: [
                progressIndicator,
                authorizeUrlField,
                refreshUrlButton,
            ]) ※ { v in
                v.setHuggingPriority(.required, for: .vertical)
            },
            TextLabel() ※ { v in
                v.stringValue = "上のURLをブラウザで開き認証した後、表示されたPINコードを入力してください。"
            },
            oauthCodeField,
            NSStackView(views: [
                quitButton,
                SpacerView(),
                fetchAccessTokenButton
            ]) ※ { v in
                v.setHuggingPriority(.required, for: .vertical)
            },
        ]
        views.forEach(addArrangedSubview)
        
        orientation = .vertical
        alignment = .leading
        edgeInsets = .init(all: 20)
        snp.makeConstraints { make in
            make.width.equalTo(480 + (20 * 2))
        }
        setHuggingPriority(.required, for: .vertical)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
