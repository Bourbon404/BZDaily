//
//  BZToolBarView.swift
//  BZDaily
//
//  Created by 郑伟 on 2018/11/9.
//  Copyright © 2018 BourbonZ. All rights reserved.
//

import UIKit
import YogaKit
class BZToolBarView: UIView {

    var backButton : UIButton?
    var nextButton : UIButton?
    var niceButton : UIButton?
    var shareButton : UIButton?
    var commentButton : UIButton?
    
    var niceLabel : UILabel?
    var commentLabel : UILabel?
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backButton = self.createButton(iconName: "zuobian")
        self.nextButton = self.createButton(iconName: "down-trangle")
        self.niceButton = self.createButton(iconName: "dianzan")
        self.shareButton = self.createButton(iconName: "fenxiang")
        self.commentButton = self.createButton(iconName: "pinglun")
        
        self.addSubview(self.backButton!)
        self.addSubview(self.nextButton!)
        self.addSubview(self.niceButton!)
        self.addSubview(self.shareButton!)
        self.addSubview(self.commentButton!)

        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 1.0 / UIScreen.main.scale
        
        self.niceLabel = UILabel.init()
        self.niceLabel?.font = UIFont.systemFont(ofSize: 8)
        self.niceLabel?.textColor = UIColor.gray
        self.niceLabel?.textAlignment = NSTextAlignment.center
        self.niceButton?.addSubview(self.niceLabel!)
        
        self.commentLabel = UILabel.init()
        self.commentLabel?.textColor = UIColor.white
        self.commentLabel?.font = UIFont.systemFont(ofSize: 8)
        self.commentLabel?.textAlignment = NSTextAlignment.center
        self.commentLabel?.backgroundColor = UIColor.blue
        self.commentButton?.addSubview(self.commentLabel!)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backButton?.configureLayout(block: { (layout) in
            layout.isEnabled = true
            layout.width = YGValue.init(integerLiteral: 20)
            layout.height = YGValue.init(integerLiteral: 20)
        })
        
        self.nextButton?.configureLayout(block: { (layout) in
            layout.isEnabled = true
            layout.width = YGValue.init(integerLiteral: 20)
            layout.height = YGValue.init(integerLiteral: 20)
        })
        
        self.niceButton?.configureLayout(block: { (layout) in
            layout.isEnabled = true
            layout.width = YGValue.init(integerLiteral: 20)
            layout.height = YGValue.init(integerLiteral: 20)
        })
        
        self.shareButton?.configureLayout(block: { (layout) in
            layout.isEnabled = true
            layout.width = YGValue.init(integerLiteral: 20)
            layout.height = YGValue.init(integerLiteral: 20)
        })
        
        self.commentButton?.configureLayout(block: { (layout) in
            layout.isEnabled = true
            layout.width = YGValue.init(integerLiteral: 20)
            layout.height = YGValue.init(integerLiteral: 20)
        })
        
        self.configureLayout { (layout) in
            layout.isEnabled = true
            layout.alignItems = YGAlign.center
            layout.flexDirection = YGFlexDirection.row
            layout.justifyContent = YGJustify.spaceAround
        }
        
        self.niceLabel?.configureLayout(block: { (layout) in
            layout.isEnabled = true
            layout.left = YGValue.init(integerLiteral: 15)
            layout.top = YGValue.init(integerLiteral: -5)
        })
        
        self.commentLabel?.configureLayout(block: { (layout) in
            layout.isEnabled = true
            layout.left = YGValue.init(integerLiteral: 10)
            layout.top = YGValue.init(integerLiteral: -5)
            layout.width = YGValue.init(integerLiteral: 40)
        })
        
        self.yoga.applyLayout(preservingOrigin: true)
    }
    
    func createButton(iconName:String) -> UIButton {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setImage(UIImage.init(named: iconName), for: UIControl.State.normal)
        return button
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func reloadCount(niceCount : String, commentCount : String) -> Void {
        self.niceLabel?.text = niceCount
        self.commentLabel?.text = commentCount
        self.niceLabel?.sizeToFit()
        self.commentLabel?.sizeToFit()
    }
    
}
