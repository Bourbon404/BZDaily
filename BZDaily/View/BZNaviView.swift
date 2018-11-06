//
//  BZNaviView.swift
//  BZDaily
//
//  Created by 郑伟 on 2018/10/26.
//  Copyright © 2018 BourbonZ. All rights reserved.
//

import UIKit
import YogaKit
class BZNaviView: UIView {

    var titleLabel : UILabel?
    var circle : UIActivityIndicatorView?
    var moreButton : UIButton?
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    deinit {

    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.titleLabel = UILabel.init()
        self.titleLabel?.textColor = UIColor.white
        self.titleLabel?.textAlignment = NSTextAlignment.center
        self.addSubview(self.titleLabel!)

        self.titleLabel?.text = "今日新闻"
        
        //菊花
        self.circle = UIActivityIndicatorView.init(style: UIActivityIndicatorView.Style.white)
        self.titleLabel?.addSubview(self.circle!)
        
        
        self.moreButton = UIButton.init(type: UIButton.ButtonType.custom)
        let image = UIImage.init(imageLiteralResourceName: "gengduo")
        self.moreButton?.setImage(image, for: UIControl.State.normal)
        self.titleLabel?.addSubview(self.moreButton!)

        self.backgroundColor = UIColor.clear

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.titleLabel?.configureLayout(block: { (layout) in
            layout.isEnabled = true
            layout.marginTop = YGValue.init(CGFloat((UIApplication.shared.keyWindow?.safeAreaInsets.bottom)!))
            layout.marginLeft = YGValue.init(integerLiteral: 0)
            layout.marginRight = YGValue.init(integerLiteral: 0)
            layout.height = YGValue.init(integerLiteral: 47)
            layout.flexDirection = YGFlexDirection.row
        })
        
        self.circle?.configureLayout(block: { (layout) in
            layout.isEnabled = true
            layout.position = YGPositionType.absolute
            layout.width = 20
            layout.height = 20
            layout.alignSelf = YGAlign.center
            layout.marginLeft = YGValue.init(CGFloat(self.frame.size.width / 2 - 60))
        })

        self.moreButton?.configureLayout(block: { (layout) in
            layout.isEnabled = true
            layout.width = YGValue.init(integerLiteral: 20)
            layout.height = YGValue.init(integerLiteral: 17)
            layout.alignSelf = YGAlign.center
            layout.marginLeft = 10
        })
        
        self.yoga.isEnabled = true
        self.yoga.applyLayout(preservingOrigin: true)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {

        if keyPath == "contentOffset" {
            let point = change?[NSKeyValueChangeKey.newKey] as! CGPoint
            if (point.y <= 0) {
                self.backgroundColor = UIColor.clear
            } else if (point.y <= 100) {
                let value = point.y / 100.0
                self.backgroundColor = UIColor.init(red: 80/255.0, green: 141/255.0, blue: 210/255.0, alpha: value)
            } else {
                self.backgroundColor = UIColor.init(red: 80/255.0, green: 141/255.0, blue: 210/255.0, alpha: 1)
            }
        }
    }
}
