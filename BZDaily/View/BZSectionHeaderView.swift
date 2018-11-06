//
//  BZSectionHeaderView.swift
//  BZDaily
//
//  Created by 郑伟 on 2018/10/26.
//  Copyright © 2018 BourbonZ. All rights reserved.
//

import UIKit
import YogaKit
class BZSectionHeaderView: UITableViewHeaderFooterView {
    var dateLabel : UILabel?
    var colorBackgroundView : UIView?
    var formatter : DateFormatter?
    
    var date : Date? {
        didSet {
            let string = self.formatter?.string(from: date!)
            self.dateLabel?.text = string!
        }
    }
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        self.formatter = DateFormatter.init()
        self.formatter?.dateFormat = "MM月dd日 EEEE"
        
        self.dateLabel = UILabel.init()
        self.dateLabel?.textColor = UIColor.white
        self.dateLabel?.textAlignment = NSTextAlignment.center
        self.dateLabel?.backgroundColor = UIColor.init(red: 80/255.0, green: 141/255.0, blue: 210/255.0, alpha: 1)
        self.contentView.addSubview(self.dateLabel!)
        

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.dateLabel?.configureLayout(block: { (layout) in
            layout.isEnabled = true
            layout.top = YGValue.init(floatLiteral: 0)
            layout.marginLeft = YGValue.init(floatLiteral: 0)
            layout.marginRight = YGValue.init(floatLiteral: 0)
            layout.height = YGValue.init(floatLiteral: 38)
        })
    
        self.contentView.yoga.isEnabled = true
        self.contentView.yoga.applyLayout(preservingOrigin: true)
    }

}
