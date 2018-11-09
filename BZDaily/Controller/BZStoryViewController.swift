//
//  BZStoryViewController.swift
//  BZDaily
//
//  Created by 郑伟 on 2018/11/9.
//  Copyright © 2018 BourbonZ. All rights reserved.
//

import UIKit
import YogaKit
import WebKit
import SDWebImage
import Alamofire
class BZStoryViewController: UIViewController , UIScrollViewDelegate {

    var toolBar : BZToolBarView?
    var webview : WKWebView?
    var iconView : UIImageView?
    var titleLabel : UILabel?
    var authorLabel : UILabel?
    
    override func loadView() {
        super.loadView()
        
        self.view.backgroundColor = UIColor.white
        
        self.webview = WKWebView.init()
        self.webview?.scrollView.showsVerticalScrollIndicator = false
        self.webview?.scrollView.showsHorizontalScrollIndicator = false
        self.webview?.scrollView.delegate = self
        self.webview?.scrollView.contentInset = UIEdgeInsets.init(top: 230, left: 0, bottom: 0, right: 0)
        self.view.addSubview(self.webview!)
        
        self.iconView = UIImageView.init()
        self.iconView?.contentMode = UIView.ContentMode.scaleAspectFill
        self.iconView?.clipsToBounds = true
        self.webview!.addSubview(self.iconView!)
        
        self.titleLabel = UILabel.init()
        self.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        self.titleLabel?.shadowColor = UIColor.black
        self.titleLabel?.shadowOffset = CGSize.init(width: 1, height: 1)
        self.titleLabel?.textAlignment = NSTextAlignment.left
        self.titleLabel?.textColor = UIColor.white
        self.iconView?.addSubview(self.titleLabel!)
        
        self.authorLabel = UILabel.init()
        self.authorLabel?.textColor = UIColor.gray
        self.authorLabel?.font = UIFont.systemFont(ofSize: 12)
        self.authorLabel?.textAlignment = NSTextAlignment.right
        self.iconView?.addSubview(self.authorLabel!)
        
        self.toolBar = BZToolBarView.init(frame: CGRect.zero)
        self.view.addSubview(self.toolBar!)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //content data
        self.reloadContentData()
        
        //toolbar data
        self.reloadToolBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.iconView?.configureLayout(block: { (layout) in
            layout.isEnabled = true
            layout.position = YGPositionType.absolute
            layout.height = YGValue.init(integerLiteral: 230)
            layout.width = YGValue.init(CGFloat((UIApplication.shared.keyWindow?.bounds.size.width)!))
        })
        
        self.titleLabel?.configureLayout(block: { (layout) in
            layout.isEnabled = true
            layout.position = YGPositionType.absolute
            layout.marginLeft = YGValue.init(integerLiteral: 15)
            layout.bottom = YGValue.init(integerLiteral: 25)
        })
        
        self.authorLabel?.configureLayout(block: { (layout) in
            layout.isEnabled = true
            layout.position = YGPositionType.absolute
            layout.right = YGValue.init(integerLiteral: 15)
            layout.bottom = YGValue.init(integerLiteral: 10)
        })
        
        self.webview?.configureLayout(block: { (layout) in
            layout.isEnabled = true
            layout.flexGrow = 1
            layout.top = YGValue.init(integerLiteral: 0)
            layout.width = YGValue.init(CGFloat((UIApplication.shared.keyWindow?.bounds.size.width)!))

        })
        
        self.toolBar?.configureLayout(block: { (layout) in
            layout.isEnabled = true
            layout.height = YGValue.init(integerLiteral: 42)
            layout.width = YGValue.init(CGFloat((UIApplication.shared.keyWindow?.bounds.size.width)!))

        })
        
        self.view.configureLayout { (layout) in
            layout.isEnabled = true
            layout.flexDirection = YGFlexDirection.column
            layout.alignItems = YGAlign.center
            layout.width = YGValue.init(CGFloat((UIApplication.shared.keyWindow?.bounds.size.width)!))
        }
        self.view.yoga.applyLayout(preservingOrigin: true)
    }
    
    
    //scrollview delegate
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//
//        self.iconView?.yoga.markDirty()
//        self.iconView?.yoga.top = YGValue.init(CGFloat(scrollView.contentOffset.y) + 230)
//        self.webview?.yoga.isEnabled = true
//        self.webview?.yoga.applyLayout(preservingOrigin: true)
//    }
    
    //content
    func reloadContentData() -> Void {
        let path = Bundle.main.path(forResource: "story", ofType: nil)
        let url = URL.init(fileURLWithPath: path!)
        do {
            let data = try Data.init(contentsOf: url)
            
            do {
                let result = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! Dictionary<String,Any>
                
                //title
                let title = result["title"]
                self.titleLabel?.text = (title as! String)
                
                //author
                let author = result["image_source"]
                self.authorLabel?.text = (author as! String)
                
                //icon
                let imageString = result["image"]
                let imageURL = URL.init(string: (imageString as! String))
                self.iconView?.sd_setImage(with: imageURL, completed: nil)
                
                //css
                let cssPathArray = (result["css"] as? Array<Any>)
                let cssPath = cssPathArray?.first as! String
                
                
                
                Alamofire.request(cssPath).responseString(queue: DispatchQueue.main, encoding: String.Encoding.utf8) { (response) in
                    
                    response.result.ifSuccess {
                        let css = String(data: response.data!, encoding: String.Encoding.utf8)
                        
                        //webview
                        let htmlString = result["body"] as! String
                        let resultString = String.localizedStringWithFormat("<style type=\"text/css\">%@</style>%@", css!,htmlString)
                        self.webview?.loadHTMLString((resultString ), baseURL: nil)
                    }
                    
                }
            } catch  {}
        } catch  {}
    }
    
    //tool bar
    func reloadToolBar() -> Void {
        let path = Bundle.main.path(forResource: "toolbar", ofType: nil)
        let url = URL.init(fileURLWithPath: path!)
        do {
            let data = try Data.init(contentsOf: url)
            
            do {
                let result = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! Dictionary<String,Any>
                
                let count = result["count"] as! Dictionary <String , Any>
                let nice = (count["likes"] as! NSNumber).stringValue
                let comments = (count["comments"] as! NSNumber).stringValue
                self.toolBar?.reloadCount(niceCount: nice, commentCount: comments)
                
            } catch  {}
        } catch  {}
    }
}
