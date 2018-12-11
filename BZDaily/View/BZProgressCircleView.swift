//
//  BZProgressCircleView.swift
//  BZDaily
//
//  Created by BourbonZ on 2018/11/8.
//  Copyright © 2018 BourbonZ. All rights reserved.
//

import UIKit

class BZProgressCircleView: UIView {

    var circleLayer : CAShapeLayer?

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    override init(frame: CGRect) {
        super.init(frame: frame)
        //菊花
        self.circleLayer = CAShapeLayer.init()
        self.circleLayer?.fillColor = UIColor.clear.cgColor
        self.circleLayer?.strokeColor = UIColor.white.cgColor
        self.layer.addSublayer(self.circleLayer!)
        self.circleLayer?.frame = CGRect.init(x: 0, y: 0, width: 20, height: 20)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //method
    
    public func updateProgress(progress : CGFloat) -> Void {
        
        let path = UIBezierPath.init(arcCenter: CGPoint.init(x: 10, y: 10), radius: 10, startAngle: 0, endAngle: CGFloat(Double.pi * 2) * progress, clockwise: true)
        self.circleLayer?.path = path.cgPath
    }
    
}
