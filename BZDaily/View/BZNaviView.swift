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
    var moreButton : UIButton?
    var circle : BZProgressCircleView?
    
    
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
        
        self.circle = BZProgressCircleView.init()
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
            layout.marginTop = YGValue.init(CGFloat(20 + (UIApplication.shared.keyWindow?.safeAreaInsets.bottom)!))
            layout.marginLeft = YGValue.init(integerLiteral: 0)
            layout.marginRight = YGValue.init(integerLiteral: 0)
            layout.height = YGValue.init(integerLiteral: 47)
            layout.flexDirection = YGFlexDirection.row
        })

        self.circle?.configureLayout(block: { (layout) in
            layout.isEnabled = true
            layout.width = YGValue.init(integerLiteral: 20)
            layout.alignSelf = YGAlign.center
            layout.marginLeft = YGValue.init(integerLiteral: 120)
            layout.height = YGValue.init(integerLiteral: 20)
            layout.position = YGPositionType.absolute
            
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
    
    
    //method
    public func startAnimation() -> Void {
        self.circle?.isHidden = false
    }
    
    public func stopAnimation() -> Void {
        self.circle?.isHidden = true
    }
    
    public func updateProgress(progress : CGFloat) -> Void {
        
        self.circle?.updateProgress(progress: progress)
    }
}
