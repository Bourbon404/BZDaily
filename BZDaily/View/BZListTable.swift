//
//  BZListTable.swift
//  BZDaily
//
//  Created by BourbonZ on 2018/10/26.
//  Copyright © 2018 BourbonZ. All rights reserved.
//

import UIKit

class BZListTable: UITableView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let headerView = self.tableHeaderView
        if (headerView?.frame.contains(point))! {
            return nil
        }; return super.hitTest(point, with: event)
    }
}
