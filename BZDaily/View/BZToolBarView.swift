//
//  BZToolBarView.swift
//  BZDaily
//
//  Created by BourbonZ on 2018/11/9.
//  Copyright © 2018 BourbonZ. All rights reserved.
//

import UIKit
import YogaKit

/// 按钮类型
///
/// - back: 返回
/// - next: 下一个
/// - nice: 点赞
/// - share: 分享
/// - comment: 评论
enum ToolBarButtonType {
    case back
    case next
    case nice
    case share
    case comment
}

protocol BZToolBarViewDelegate {
    
    /// 点击工具栏按钮
    ///
    /// - Parameter buttonType: 按钮类型
    func didClickButtonWithType(buttonType: ToolBarButtonType)
}

class BZToolBarView: UIView {

    var backButton : UIButton?
    var nextButton : UIButton?
    var niceButton : UIButton?
    var shareButton : UIButton?
    var commentButton : UIButton?
    
    var niceLabel : UILabel?
    var commentLabel : UILabel?
    
    public var delegate : BZToolBarViewDelegate?
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        super.draw(rect)
        
        let path = UIBezierPath.init()
        path.move(to: CGPoint.init(x: 0, y: 0))
        path.addLine(to: CGPoint.init(x: self.frame.size.width, y: 0))
        path.lineWidth = 1.0 / UIScreen.main.scale
        UIColor.lightGray.set()
        path.stroke()
    }
 
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
        
        self.backButton = self.createButton(iconName: "zuobian")
        self.nextButton = self.createButton(iconName: "down-trangle")
        self.niceButton = self.createButton(iconName: "dianzan")
        self.shareButton = self.createButton(iconName: "fenxiang")
        self.commentButton = self.createButton(iconName: "pinglun")
        
        self.backButton?.addTarget(self, action: #selector(clickBackButton), for: UIControl.Event.touchUpInside)
        self.shareButton?.addTarget(self, action: #selector(clickShareButton), for: UIControl.Event.touchUpInside)
        
        self.addSubview(self.backButton!)
        self.addSubview(self.nextButton!)
        self.addSubview(self.niceButton!)
        self.addSubview(self.shareButton!)
        self.addSubview(self.commentButton!)

        self.niceLabel = UILabel.init()
        self.niceLabel?.font = UIFont.systemFont(ofSize: 8)
        self.niceLabel?.textColor = UIColor.gray
        self.niceLabel?.textAlignment = NSTextAlignment.center
        self.niceButton?.addSubview(self.niceLabel!)
        
        self.commentLabel = UILabel.init()
        self.commentLabel?.textColor = UIColor.white
        self.commentLabel?.font = UIFont.systemFont(ofSize: 8)
        self.commentLabel?.textAlignment = NSTextAlignment.center
        self.commentLabel?.backgroundColor = UIColor.init(red: 80/255.0, green: 141/255.0, blue: 210/255.0, alpha: 1)
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
    
    //method
    public func reloadCount(niceCount : String, commentCount : String) -> Void {
        self.niceLabel?.text = niceCount
        self.commentLabel?.text = commentCount
        self.niceLabel?.sizeToFit()
        self.commentLabel?.sizeToFit()
    }
    
    //点击分享按钮
    @objc func clickShareButton() -> Void {
        
        self.delegate?.didClickButtonWithType(buttonType: ToolBarButtonType.share)
    }
    
    //点击返回按钮
    @objc func clickBackButton() -> Void {
        self.delegate?.didClickButtonWithType(buttonType: ToolBarButtonType.back)
    }
}
