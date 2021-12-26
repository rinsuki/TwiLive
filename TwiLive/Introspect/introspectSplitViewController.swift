//
//  introspectSplitViewController.swift
//  TwiLive
//
//  Created by user on 2021/12/26.
//  Copyright © 2021 rinsuki. All rights reserved.
//

import SwiftUI
import Introspect

extension View {
    func introspectSplitView(customize: @escaping (NSSplitView) -> ()) -> some View {
        return introspect(selector: TargetViewSelector.ancestorOrSiblingContaining, customize: customize)
    }
    
    func introspectSplitViewController(customize: @escaping (NSSplitViewController) -> ()) -> some View {
        return introspectSplitView { splitView in
            if let vc = splitView.delegate as? NSSplitViewController {
                customize(vc)
            }
        }
    }
}
