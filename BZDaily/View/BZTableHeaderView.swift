//
//  BZTableHeaderView.swift
//  BZDaily
//
//  Created by 郑伟 on 2018/10/26.
//  Copyright © 2018 BourbonZ. All rights reserved.
//

import UIKit
import YogaKit

protocol BZTableHeaderViewDelegate {
    func didClickHeaderViewWithItem(item:Any)
}

class BZTableHeaderView: UIView, UIScrollViewDelegate {
    
    var listScroll : BZScrollView?
    var pageControl : UIPageControl?
    var timer : Timer?
    var allItem : Array<Any>?
    var delegate : BZTableHeaderViewDelegate?
    var bottomLayer : CAGradientLayer?
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { (currentTimer) in
            let contentOffset = self.listScroll?.contentOffset;
            var x = contentOffset!.x + self.frame.size.width
            x = x.truncatingRemainder(dividingBy: (self.listScroll?.contentSize.width)!)
            self.listScroll?.setContentOffset(CGPoint.init(x: x, y: 0), animated: true)
        })
        
        //scroll
        self.listScroll = BZScrollView()
        self.listScroll?.isPagingEnabled = true
        self.listScroll?.delegate = self
        self.listScroll?.isUserInteractionEnabled = false
        self.listScroll?.showsHorizontalScrollIndicator = false
        self.listScroll?.showsVerticalScrollIndicator = false
        self.addSubview(self.listScroll!)
        
        self.bottomLayer = CAGradientLayer.init()
        self.bottomLayer?.startPoint = CGPoint.init(x: 0.5, y: 0)
        self.bottomLayer?.endPoint = CGPoint.init(x: 0.5, y: 1)
        self.bottomLayer?.colors = [UIColor.clear.cgColor,UIColor.black.withAlphaComponent(0.5).cgColor]
        self.layer.addSublayer(self.bottomLayer!)
        
        self.pageControl = UIPageControl.init()
        self.addSubview(self.pageControl!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //scroll frame
        self.listScroll?.configureLayout(block: { (layout) in
            layout.isEnabled = true
            layout.top = YGValue.init(integerLiteral: 0)
            layout.height = YGValue.init(integerLiteral: Int(240 + ((UIApplication.shared.keyWindow?.safeAreaInsets.bottom)!)))
            layout.left = YGValue.init(integerLiteral: 0)
            layout.width = YGValue.init(integerLiteral: Int(UIApplication.shared.statusBarFrame.width))
            layout.position = YGPositionType.absolute

        })
        
        self.pageControl?.configureLayout(block: { (layout) in
            layout.isEnabled = true
            layout.position = YGPositionType.absolute
            layout.bottom = YGValue.init(floatLiteral: 10)
            layout.marginLeft = YGValue.init(floatLiteral: 0)
            layout.marginRight = YGValue.init(floatLiteral: 0)
        })
        
        self.yoga.isEnabled = true
        self.yoga.applyLayout(preservingOrigin: true)
        
        self.bottomLayer?.frame = CGRect.init(x: 0, y: self.frame.size.height - 100, width: (UIApplication.shared.keyWindow?.frame.size.width)!, height: 100)

    }
    
    func addSubView(url: URL, title:String, tag:Int) -> Void {
        let imageView = UIImageView.init()
        imageView.contentMode = UIView.ContentMode.scaleAspectFill
        imageView.sd_setImage(with: url, completed: nil)
        self.listScroll?.addSubview(imageView)
        imageView.configureLayout { (layout) in
            layout.isEnabled = true
            layout.width = YGValue.init(CGFloat(((UIApplication.shared.keyWindow?.bounds.size.width)!)))
            layout.height = YGValue.init(integerLiteral: Int(240 + ((UIApplication.shared.keyWindow?.safeAreaInsets.bottom)!)))
            layout.marginTop = YGValue.init(integerLiteral: 0)
            layout.marginLeft = YGValue.init(integerLiteral: 0)
            layout.marginRight = YGValue.init(integerLiteral: 0)
        }
        
        let label = UILabel.init()
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.white
        label.text = title
        imageView.addSubview(label)
        label.configureLayout { (layout) in
            layout.isEnabled = true
            layout.marginTop = YGValue.init(integerLiteral: Int(145 + ((UIApplication.shared.keyWindow?.safeAreaInsets.bottom)!)))
            layout.marginBottom = YGValue.init(integerLiteral: 0)
            layout.marginLeft = YGValue.init(integerLiteral: 15)
            layout.marginRight = YGValue.init(integerLiteral: 40)
        }
        //add gesture
        imageView.isUserInteractionEnabled = true
        imageView.tag = tag
        let gesture = UITapGestureRecognizer.init(target: self, action: #selector(didClickItem(gesture:)))
        imageView.addGestureRecognizer(gesture)
    }
    
    public func reloadScrollView(object : Array<Any>) -> Void {
        
        self.allItem = object
        
        self.pageControl?.numberOfPages = object.count
        //data
        for dict in object {
            let tmp = dict as! Dictionary<String, Any>
            let imagePath = tmp["image"]
            let url = URL.init(string: imagePath as! String)
            
            let title = tmp["title"]
            
            let tag = (object as NSArray).index(of: dict)
            self.addSubView(url: url!, title: title as! String, tag: tag)
            
        }
        self.listScroll?.contentSize = CGSize.init(width: CGFloat((UIApplication.shared.keyWindow?.bounds.size.width)! * CGFloat(object.count)), height: 240 + ((UIApplication.shared.keyWindow?.safeAreaInsets.bottom)!))
        self.listScroll?.configureLayout(block: { (layout) in
            layout.isEnabled = true
            layout.flexDirection = YGFlexDirection.row
        })
        self.listScroll?.yoga.applyLayout(preservingOrigin: true)
        
        self.timer?.fire()
        
    }
    
    //UIScrollView Delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offset = scrollView.contentOffset
        
        if (offset.x + self.frame.size.width > scrollView.contentSize.width) {
            scrollView.setContentOffset(CGPoint.zero, animated: false)
        }
    
        let page = scrollView.contentOffset.x / self.frame.size.width
        if (page <= 4) {
            self.pageControl?.currentPage = Int(page)
        }
        
    }
    

    @objc func didClickItem(gesture:UIGestureRecognizer) -> Void {
        
        if (self.delegate != nil) {
            let view = gesture.view
            let object = self.allItem![(view?.tag)!]
            self.delegate?.didClickHeaderViewWithItem(item: object)
        }
    }
    
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        
//        if keyPath == "contentOffset" {
//            let point = change?[NSKeyValueChangeKey.newKey] as! CGPoint
//            let value = -(point.y)
//            if (value <= 100 && value >= 0) {
//                let radio = (value / 100.0) + 1
//                self.layer.anchorPoint = CGPoint.init(x: 100, y: 100)
//                self.transform = CGAffineTransform.init(scaleX: radio, y: radio)
//            }
//            
//        }
//    }
    
}
