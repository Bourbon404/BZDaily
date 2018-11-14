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
    var statusBarView : UIView?
    
    public var storyID : String?
    
    
    override func loadView() {
        super.loadView()
        
        self.view.backgroundColor = UIColor.white
        
        self.webview = WKWebView.init()
        self.webview?.scrollView.showsVerticalScrollIndicator = false
        self.webview?.scrollView.showsHorizontalScrollIndicator = false
        self.webview?.scrollView.delegate = self
        self.webview?.scrollView.contentInset = UIEdgeInsets.init(top: UIApplication.shared.statusBarFrame.size.height, left: 0, bottom: 0, right: 0)
        self.view.addSubview(self.webview!)
        
        self.iconView = UIImageView.init()
        self.iconView?.contentMode = UIView.ContentMode.scaleAspectFill
        self.iconView?.clipsToBounds = true
        self.webview?.scrollView.addSubview(self.iconView!)
        
        self.titleLabel = UILabel.init()
        self.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        self.titleLabel?.shadowColor = UIColor.black
        self.titleLabel?.shadowOffset = CGSize.init(width: 1, height: 1)
        self.titleLabel?.textAlignment = NSTextAlignment.left
        self.titleLabel?.numberOfLines = 0
        self.titleLabel?.textColor = UIColor.white
        self.iconView?.addSubview(self.titleLabel!)
        
        self.authorLabel = UILabel.init()
        self.authorLabel?.textColor = UIColor.gray
        self.authorLabel?.font = UIFont.systemFont(ofSize: 12)
        self.authorLabel?.textAlignment = NSTextAlignment.right
        self.iconView?.addSubview(self.authorLabel!)
        
        self.toolBar = BZToolBarView.init(frame: CGRect.zero)
        self.view.addSubview(self.toolBar!)
        
        self.statusBarView = UIView.init()
        self.statusBarView?.backgroundColor = UIColor.clear
        self.view.addSubview(self.statusBarView!)
        
        
        self.toolBar?.backButton?.addTarget(self, action: #selector(clickBackAction), for: UIControl.Event.touchUpInside)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //content data
        self.reloadContentData()
        
        //toolbar data
        self.reloadToolBar()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.iconView?.configureLayout(block: { (layout) in
            layout.isEnabled = true
            layout.position = YGPositionType.absolute
            layout.top = YGValue.init(integerLiteral: Int(-(UIApplication.shared.statusBarFrame.height)))
            layout.height = YGValue.init(integerLiteral: 230)
            layout.width = YGValue.init(CGFloat((UIApplication.shared.keyWindow?.bounds.size.width)!))
        })
        
        self.titleLabel?.configureLayout(block: { (layout) in
            layout.isEnabled = true
            layout.position = YGPositionType.absolute
            layout.left = YGValue.init(integerLiteral: 15)
            layout.right = YGValue.init(integerLiteral: 15)
            layout.bottom = YGValue.init(integerLiteral: Int(50 + UIApplication.shared.statusBarFrame.height))
        })
        
        self.authorLabel?.configureLayout(block: { (layout) in
            layout.isEnabled = true
            layout.position = YGPositionType.absolute
            layout.alignSelf = YGAlign.flexEnd
            layout.marginRight = YGValue.init(integerLiteral: 15)
            layout.bottom = YGValue.init(integerLiteral: Int(20 + UIApplication.shared.statusBarFrame.height))
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
        
        self.webview?.scrollView.configureLayout(block: { (layout) in
            layout.isEnabled = true
        })
        
        self.statusBarView?.configureLayout(block: { (layout) in
            layout.isEnabled = true
            layout.position = YGPositionType.absolute
            layout.left = YGValue.init(integerLiteral: 0)
            layout.right = YGValue.init(integerLiteral: 0)
            layout.height = YGValue.init(integerLiteral: Int(UIApplication.shared.statusBarFrame.size.height))
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
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let contentOffset = scrollView.contentOffset
        
        //控制状态栏
        if contentOffset.y <= 230 {
            
            UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: true)
            self.statusBarView?.backgroundColor = UIColor.clear
        } else {
            
            UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.default, animated: true)
            self.statusBarView?.backgroundColor = UIColor.white
        }
        
        //控制下拉距离
        if (contentOffset.y < -100 && scrollView.isDragging) {
            scrollView.setContentOffset(CGPoint.init(x: 0, y: -100), animated: false)
        }
    }
    
    //content
    func reloadContentData() -> Void {
        
        var path = "https://news-at.zhihu.com/api/7/story/"
        path.append(self.storyID!)
        
        Alamofire.request(path).responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments) { (response) in
            
            response.result.ifSuccess {
                do {
                    let result = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.allowFragments) as! Dictionary<String,Any>

                    //title
                    let title = result["title"]
                    self.titleLabel?.text = (title as! String)
                    
                    //author
                    let author = result["image_source"]
                    self.authorLabel?.text = (author as! String)

                    self.titleLabel?.sizeToFit()
                    self.authorLabel?.sizeToFit()
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
                            let body = result["body"] as! String

                            var html = "<html>"
                            html += "<head>"
                            html += "<meta name=\"viewport\" content=\"width=device-width,initial-scale=1.0,minimum-scale=1.0,maximum-scale=1.0,user-scalable=no,viewport-fit=cover\">"
                            html += "<style type=\"text/css\">"
                            html += css!
                            html += "</style>"
                            html += "</head>"
                            html += "<body>"
                            html += body
                            html += "</body>"
                            html += "</html>"

                            self.webview?.loadHTMLString((html), baseURL: nil)
                        }
                    }
                } catch  {}
            }
        }
    }
    
    //tool bar
    func reloadToolBar() -> Void {

        let path = "https://news-at.zhihu.com/api/7/story-extra/" + self.storyID!
        Alamofire.request(path).responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments) { (response) in
            response.result.ifSuccess {
                do {
                    let result = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.allowFragments) as! Dictionary<String, Any>
                    let count = result["count"] as! Dictionary <String , Any>
                    let nice = (count["likes"] as! NSNumber).stringValue
                    let comments = (count["comments"] as! NSNumber).stringValue
                    self.toolBar?.reloadCount(niceCount: nice, commentCount: comments)
                } catch{}
            }
        }
    }
    
    //action
    @objc func clickBackAction() -> Void {
        self.navigationController?.popViewController(animated: true)
    }
}
