//
//  BZListViewController.swift
//  BZDaily
//
//  Created by 郑伟 on 2018/10/26.
//  Copyright © 2018 BourbonZ. All rights reserved.
//

import UIKit
import YogaKit
import Alamofire

class BZListViewController: UIViewController , UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, BZTableHeaderViewDelegate {

    var listTable : BZListTable?
    var listHeaderView : BZTableHeaderView?
    var naviView : BZNaviView?
    var model : BZListModel?
    
    var listDict : Dictionary<String, Any>?
    var topArray : Array<Any>?
    

    let cellID = "cell"
    let sectionID = "sectionID"
    
    deinit {
        self.removeObserver(self.naviView!, forKeyPath: "contentOffset")
    }
    
    override func loadView() {
        super.loadView()
        
        //data
        self.listDict = Dictionary.init()
        self.topArray = Array.init()
        
        //header
        self.listHeaderView = BZTableHeaderView.init(frame: CGRect.zero)
        self.listHeaderView?.delegate = self
        self.view.addSubview(self.listHeaderView!)
        
        //table
        self.listTable = BZListTable(frame: CGRect.zero, style:UITableView.Style.grouped)
        var contentInset = self.listTable?.contentInset
        contentInset?.top = -(UIApplication.shared.statusBarFrame.size.height)
        self.listTable?.contentInset = contentInset!
        self.listTable?.dataSource = self
        self.listTable?.delegate = self
        self.listTable?.rowHeight = 90
        self.listTable?.sectionHeaderHeight = 38
        self.listTable?.sectionFooterHeight = 0
        self.listTable?.backgroundColor = UIColor.clear
        self.listTable?.showsVerticalScrollIndicator = false
        self.listTable?.register(BZTableViewCell.self, forCellReuseIdentifier: cellID)
        self.listTable?.register(BZSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: sectionID)
        self.view.addSubview(self.listTable!)
        
        let topView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: (UIApplication.shared.keyWindow?.bounds.size.width)!, height: 240 + (UIApplication.shared.keyWindow?.safeAreaInsets.bottom)!))
        topView.backgroundColor = UIColor.clear
        self.listTable?.tableHeaderView = topView
        self.listTable?.tableFooterView = UIView.init()
        
        self.naviView = BZNaviView(frame:CGRect.zero)
        self.view.addSubview(self.naviView!)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let listURL = "https://news-at.zhihu.com/api/4/news/latest"
        let cacheData = BZCacheManager.objectFromKey(key: "latest")
        if (cacheData != nil) {
            self.configData(data: cacheData! as Data)
        } else {
            Alamofire.request(listURL).responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments) { (response) in
                response.result.ifSuccess {
                    
                    self.configData(data: response.data!)
                    self.addObserver()
                    BZCacheManager.saveObject(data: response.data!, key: "latest")
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.listHeaderView?.configureLayout(block: { (layout) in
            layout.isEnabled = true
            layout.position = YGPositionType.absolute
            layout.left = YGValue.init(integerLiteral: 0)
            layout.right = YGValue.init(integerLiteral: 0)
            layout.top = YGValue.init(integerLiteral: 0)
            layout.height = YGValue.init(CGFloat(240 + (UIApplication.shared.keyWindow?.safeAreaInsets.bottom)!))
        })
        
        //table frame
        self.listTable?.configureLayout(block: { (layout) in
            layout.isEnabled = true
            layout.marginTop = YGValue.init(integerLiteral: 0)
            layout.marginBottom = YGValue.init(integerLiteral: 0)
            layout.marginLeft = YGValue.init(integerLiteral: 0)
            layout.marginRight = YGValue.init(integerLiteral: 0)
            layout.flexGrow = 1
        })
        
        self.naviView?.configureLayout(block: { (layout) in
            layout.isEnabled = true
            layout.left = YGValue.init(floatLiteral: 0)
            layout.right = YGValue.init(floatLiteral: 0)
            layout.top = YGValue.init(integerLiteral: 0)
            layout.height = YGValue.init(integerLiteral: Int(47 + (UIApplication.shared.keyWindow?.safeAreaInsets.top)!))
            layout.position = YGPositionType.absolute
        })
        
        //view
        self.view.configureLayout { (layout) in
            layout.isEnabled = true
        }
        self.view.yoga.applyLayout(preservingOrigin: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    //observer
    func addObserver() -> Void {
        self.listTable?.addObserver(self.naviView!, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.new, context: nil)
//        self.listTable?.addObserver(self.listHeaderView!, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    
    //datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let keyArray = self.listDict?.keys.sorted()
        let key = keyArray![section]
        let array = self.listDict![key] as! Array <Any>
        return array.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {

        return (self.listDict?.keys.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! BZTableViewCell
        
        let keyArray = self.listDict?.keys.sorted()
        let key = keyArray![indexPath.section]
        let array = self.listDict![key] as! Array <Any>
        let object = array[indexPath.row] as! Dictionary<String, Any>
        cell.object = object
        
        return cell
    }
    
    //delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let keyArray = self.listDict?.keys.sorted()
        let key = keyArray![indexPath.section]
        let array = self.listDict![key] as! Array <Any>
        let object = array[indexPath.row] as! Dictionary<String, Any>
        
        let storyController = BZStoryViewController.init()
        storyController.storyID = (object["id"] as! NSNumber).stringValue
        self.navigationController?.pushViewController(storyController, animated: true)
    }
    
    //section
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: sectionID) as! BZSectionHeaderView
        
        let keyArray = self.listDict?.keys.sorted()
        let key = keyArray![section]
        
        view.dateSring = key
    
        return view;
    }
    
    //scrollview delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset
        
        //控制下拉范围
        if (contentOffset.y < -100 && scrollView.isDragging) {
            scrollView.setContentOffset(CGPoint.init(x: 0, y: -100), animated: false)
        }
        
        var rect = CGRect.init(x: 0, y: 0, width: (UIApplication.shared.keyWindow?.bounds.size.width)!, height: 240 + (UIApplication.shared.keyWindow?.safeAreaInsets.bottom)!)
        
        if contentOffset.y >= 0 {
            self.naviView?.stopAnimation()

            //上推时顶部视图向上移动
            rect.origin.y = -contentOffset.y
            self.listHeaderView?.frame = rect
        } else {
            
            //下拉的时候进行放大处理
            self.naviView?.startAnimation()
            let radio = -contentOffset.y / 100.0
            self.naviView?.updateProgress(progress: radio)
            
            let newHeight = 240 + (UIApplication.shared.keyWindow?.safeAreaInsets.bottom)! - contentOffset.y
            rect.size.height = newHeight
            self.listHeaderView?.frame = rect
        }
    }
    
    //配置数据
    func configData(data:Data) -> Void {
        
        do {
            let result = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! Dictionary<String,Any>
            let array = result["stories"]
            let dateString = result["date"] as! String
            
            self.listDict?.updateValue(array as Any, forKey: dateString)
            self.listTable?.reloadData()
            
            self.topArray = result["top_stories"] as? Array<Any>
            self.listHeaderView?.reloadScrollView(object: self.topArray!)
        } catch {}
    }
    
    //点击头部视图
    func didClickHeaderViewWithItem(item: Any) {
        
        let object = item as! Dictionary <String , Any>
        let storyController = BZStoryViewController.init()
        storyController.navigationController?.isNavigationBarHidden = true
        storyController.storyID = (object["id"] as! NSNumber).stringValue
        self.navigationController?.pushViewController(storyController, animated: true)
    }
}
