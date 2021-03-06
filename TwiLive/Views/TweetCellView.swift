//
//  TweetCellView.swift
//  TwiLive
//
//  Created by user on 2019/09/18.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import Cocoa
import Ikemen
import SnapKit
import Nuke
import HTMLEntities

fileprivate let formatter = DateFormatter() ※ { f in
    f.locale = .init(identifier: "en_US_POSIX")
    f.dateFormat = "HH:mm:ss"
}

class TweetCellView: NSTableCellView {
    private let iconView = NSImageView() ※ { v in
        v.snp.makeConstraints { make in
            make.size.equalTo(48)
        }
    }
    
    private let userNameLabel = TextLabel()
    
    private let userScreenNameLabel = TextLabel() ※ { v in
        v.textColor = .secondaryLabelColor
        v.setContentHuggingPriority(.init(rawValue: 249), for: .horizontal)
    }
    
    private let createdAtLabel = TextLabel()
    
    private let contentLabel = TextLabel() ※ { v in
        v.maximumNumberOfLines = 0
    }
    
    private let sourceLabel = TextLabel() ※ { v in
        v.textColor = .tertiaryLabelColor
        v.lineBreakMode = .byTruncatingTail
    }
    
    init() {
        super.init(frame: .zero)
        let userStackView = NSStackView(views: [
            userNameLabel,
            userScreenNameLabel,
            createdAtLabel,
        ]) ※ { v in
            v.orientation = .horizontal
            v.setHuggingPriority(.required, for: .vertical)
            v.spacing = 4
        }
        let contentStackView = NSStackView(views: [
            userStackView,
            contentLabel,
            sourceLabel,
        ]) ※ { v in
            v.orientation = .vertical
            v.alignment = .leading
            v.setHuggingPriority(.required, for: .vertical)
            v.spacing = 2
        }
        addSubview(iconView)
        addSubview(contentStackView)
        let inset = 6
        iconView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(inset)
            make.bottom.lessThanOrEqualToSuperview().inset(inset)
        }
        contentStackView.snp.makeConstraints { make in
            make.top.trailing.bottom.equalToSuperview().inset(inset)
            make.leading.equalTo(iconView.snp.trailing).inset(-inset)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func load(_ tweet: TwitterStatus) {
        userNameLabel.stringValue = tweet.user.name
        userScreenNameLabel.stringValue = "@" + tweet.user.screenName
        createdAtLabel.stringValue = formatter.string(from: tweet.createdAt)
        contentLabel.stringValue = tweet.text
        sourceLabel.stringValue = tweet.source
        Nuke.loadImage(with: URL(string: tweet.user.profileImageURL.replacingOccurrences(of: "_normal", with: "_400x400"))!, into: iconView)
    }
}
