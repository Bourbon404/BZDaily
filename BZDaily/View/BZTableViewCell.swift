//
//  BZTableViewCell.swift
//  BZDaily
//
//  Created by 郑伟 on 2018/10/26.
//  Copyright © 2018 BourbonZ. All rights reserved.
//

import UIKit
import YogaKit
import SDWebImage
class BZTableViewCell: UITableViewCell {

    var titleLabel : UILabel?
    var iconView : UIImageView?
    var object : Dictionary<String, Any>? {
        didSet {
            //title
            let title = object!["title"]
            self.titleLabel?.text = (title as! String)
            
            //image
            let imageArray = (object!["images"]) as! Array<Any>
            let imagePath = imageArray.first as! String
            let url = URL.init(string: imagePath)
            self.iconView?.sd_setImage(with: url!, completed: nil)
            
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = UITableViewCell.SelectionStyle.none
        self.separatorInset = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 10)
        
        //titleLabel
        self.titleLabel = UILabel.init()
        self.contentView.addSubview(self.titleLabel!)
        
        //iconView
        self.iconView = UIImageView.init()
        self.iconView?.contentMode = UIView.ContentMode.scaleAspectFill
        self.contentView.addSubview(self.iconView!)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.titleLabel?.configureLayout(block: { (layout) in
            layout.isEnabled = true
            layout.marginTop = YGValue.init(integerLiteral: 15)
            layout.marginLeft = YGValue.init(integerLiteral: 10)
            layout.height = YGValue.init(integerLiteral: 20)
            layout.flexGrow = 1
        })
        
        self.iconView?.configureLayout(block: { (layout) in
            layout.isEnabled = true
            layout.width = YGValue.init(integerLiteral: 75)
            layout.height = YGValue.init(integerLiteral: 60)
            layout.marginTop = YGValue.init(integerLiteral: 15)
            layout.marginRight = YGValue.init(integerLiteral: 15)
            layout.marginLeft = YGValue.init(integerLiteral: 15)
        })
        
        self.contentView.configureLayout { (layout) in
            layout.isEnabled = true
            layout.flexDirection = YGFlexDirection.row
        }
        self.contentView.yoga.applyLayout(preservingOrigin: true)
    }
}
