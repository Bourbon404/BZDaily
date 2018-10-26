//
//  BZTableHeaderView.swift
//  BZDaily
//
//  Created by 郑伟 on 2018/10/26.
//  Copyright © 2018 BourbonZ. All rights reserved.
//

import UIKit
import YogaKit
class BZTableHeaderView: UIView, UIScrollViewDelegate {
    
    var listScroll : BZScrollView?
    var pageControl : UIPageControl?

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //scroll
        self.listScroll = BZScrollView()
        self.listScroll?.isPagingEnabled = true
        self.listScroll?.delegate = self
        self.listScroll?.showsHorizontalScrollIndicator = false
        self.listScroll?.showsVerticalScrollIndicator = false
        self.addSubview(self.listScroll!)
        
        
        self.pageControl = UIPageControl.init()
        self.addSubview(self.pageControl!)
        
        self.pageControl?.numberOfPages = 4

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
            layout.height = YGValue.init(integerLiteral: Int(220 + ((UIApplication.shared.keyWindow?.safeAreaInsets.bottom)!)))
            layout.left = YGValue.init(integerLiteral: 0)
            layout.width = YGValue.init(integerLiteral: Int(UIApplication.shared.statusBarFrame.width))
            layout.position = YGPositionType.absolute

        })
        
        self.pageControl?.configureLayout(block: { (layout) in
            layout.isEnabled = true
            layout.position = YGPositionType.absolute
            layout.bottom = YGValue.init(floatLiteral: 0)
            layout.marginLeft = YGValue.init(floatLiteral: 0)
            layout.marginRight = YGValue.init(floatLiteral: 0)
        })
        
        self.yoga.isEnabled = true
        self.yoga.applyLayout(preservingOrigin: true)
    }
    
    func addSubView() -> UIImageView {
        let imageView = UIImageView.init()
        self.listScroll?.addSubview(imageView)
        imageView.configureLayout { (layout) in
            layout.isEnabled = true
            layout.width = YGValue.init(CGFloat(((UIApplication.shared.keyWindow?.bounds.size.width)!)))
            layout.height = YGValue.init(integerLiteral: Int(220 + ((UIApplication.shared.keyWindow?.safeAreaInsets.bottom)!)))
            layout.marginTop = YGValue.init(integerLiteral: 0)
            layout.marginLeft = YGValue.init(integerLiteral: 0)
            layout.marginRight = YGValue.init(integerLiteral: 0)
        }
        return imageView
    }
    
    public func reloadScrollView() -> Void {
        //data
        let redView = self.addSubView()
        redView.backgroundColor = UIColor.red

        let yellowView = self.addSubView()
        yellowView.backgroundColor = UIColor.yellow

        let purpleView = self.addSubView()
        purpleView.backgroundColor = UIColor.purple

        let blueView = self.addSubView()
        blueView.backgroundColor = UIColor.blue

        self.listScroll?.contentSize = CGSize.init(width: CGFloat((UIApplication.shared.keyWindow?.bounds.size.width)! * 4), height: 220 + ((UIApplication.shared.keyWindow?.safeAreaInsets.bottom)!))
        self.listScroll?.configureLayout(block: { (layout) in
            layout.isEnabled = true
            layout.flexDirection = YGFlexDirection.row
        })
        self.listScroll?.yoga.applyLayout(preservingOrigin: true)
    }
    
    //UIScrollView Delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
//        let offset = scrollView.contentOffset
//        let page = offset.x.truncatingRemainder(dividingBy: UIScreen.main.bounds.size.width)
//        self.pageControl?.currentPage = Int(page)
    }
}
