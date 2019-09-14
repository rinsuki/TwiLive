//
//  TimelineViewController.swift
//  TwiLive
//
//  Created by user on 2019/09/13.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import Cocoa

class TimelineViewController: NSViewController {

    @IBOutlet weak var tableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        tableView.dataSource = self
    }
}

extension TimelineViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return 100000
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return "hoge \(row)"
    }
}
