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

class BZListViewController: UIViewController , UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {

    var listTable : BZListTable?
    var listHeaderView : BZTableHeaderView?
    var naviView : BZNaviView?
    var model : BZListModel?
    
    var listDict : Dictionary<Date, Any>?
    var topArray : Array<Any>?
    

    let cellID = "cell"
    let sectionID = "sectionID"
    
    deinit {
        self.removeObserver(self.naviView!, forKeyPath: "contentOffset")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.addObserver()

//        let header : HTTPHeaders = [
//            "authorization":"Bearer 1pil2HanTpum33V5hDJEIw"
//        ]
//        Alamofire.request("https://news-at.zhihu.com/api/7/stories/latest", headers: header).responseJSON { (response) in
////            self.model = BZListModel.yy_model(withJSON: response.result.value)
////            self.listTable?.reloadData()
//
//            let data = response.value
////            let dict = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as! Dictionary
////            self.listArray = dict!["top_stories"]
////            self.topArray = dict!["stories"]
//            self.listTable?.reloadData()
//        }
        
        let path = Bundle.main.path(forResource: "result", ofType: "json")
        let url = URL.init(fileURLWithPath: path!)
        
        do {
            let data = try Data.init(contentsOf: url)
            
            do {
                let result = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! Dictionary<String,Any>
                let array = (result["stories"] as? Array<Any>)
                self.listDict?.updateValue(array as Any, forKey: Date.init())
                self.listDict?.updateValue(array as Any, forKey: Date.init().addingTimeInterval(10000))

                self.topArray = result["top_stories"] as? Array<Any>
                self.listTable?.reloadData()
                self.listHeaderView?.reloadScrollView(object: self.topArray!)
            } catch  {
                
            }
            
        } catch  {
            
        }
        
        
        
    }
    
    override func loadView() {
        super.loadView()
        
        //data
        self.listDict = Dictionary.init()
        self.topArray = Array.init()
        
        //header
        self.listHeaderView = BZTableHeaderView.init(frame: CGRect.zero)
        self.listHeaderView?.backgroundColor = UIColor.red
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
        
        let screenWidth = UIApplication.shared.keyWindow?.bounds.size.width

        let topView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: screenWidth!, height: 240 + (UIApplication.shared.keyWindow?.safeAreaInsets.bottom)!))
        topView.backgroundColor = UIColor.clear
        self.listTable?.tableHeaderView = topView
        self.listTable?.tableFooterView = UIView.init()
        
        self.naviView = BZNaviView(frame:CGRect.zero)
        self.view.addSubview(self.naviView!)

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
        })
        
        self.naviView?.configureLayout(block: { (layout) in
            layout.isEnabled = true
            layout.left = YGValue.init(floatLiteral: 0)
            layout.right = YGValue.init(floatLiteral: 0)
            layout.top = YGValue.init(integerLiteral: 0)
            layout.height = YGValue.init(integerLiteral: Int(67 + (UIApplication.shared.keyWindow?.safeAreaInsets.bottom)!))
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
    
    //section
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: sectionID) as! BZSectionHeaderView
        
        let keyArray = self.listDict?.keys.sorted()
        let key = keyArray![section]
        
        view.date = key
    
        return view;
    }
    
    //scrollview delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset
        
        if (contentOffset.y < -100 && scrollView.isDragging) {
            scrollView.setContentOffset(CGPoint.init(x: 0, y: -100), animated: false)
            
//            self.naviView!.stopAnimation()
            
//            CGFloat width = self.view.frame.size.width;
//            // 图片宽度
//            CGFloat yOffset = scrollView.contentOffset.y;
//            // 偏移的y值
//            if(yOffset < 0)
//            {CGFloat totalOffset = 200 + ABS(yOffset);
//                CGFloat f = totalOffset / 200;
//                //拉伸后的图片的frame应该是同比例缩放。
//                self.tableView.tableHeaderView.frame =  CGRectMake(- (width *f-width) / 2, yOffset, width * f, totalOffset);
//            }


        } else {
            
//            let offset = contentOffset.y
//            if (offset < 0) {
//
//                self.naviView!.startAnimation()
//                let ratio = offset / 100.0;
//                self.naviView!.updateProgress(progress: ratio)
//
//                self.listHeaderView!.transformBackImage(offset: contentOffset.y)
//            }
        }
        
        
        if (contentOffset.y < 0) {
            let width = UIApplication.shared.keyWindow?.bounds.size.width
            let height = 240 + (UIApplication.shared.keyWindow?.safeAreaInsets.bottom)!
            let radio = -contentOffset.y / 100
            
            let newWidth = CGFloat(width! + width! * radio)
            let newHeight = CGFloat(height + (-contentOffset.y))
//            self.listTable?.tableHeaderView?.frame = CGRect.init(x: (width! - newWidth)/2 , y: -contentOffset.y, width: newWidth, height: newHeight)
            let frame = CGRect.init(x: (width! - newWidth)/2, y: 0, width: newWidth, height: newHeight)
            self.listHeaderView?.frame = frame
            print(frame)

        }
    }
}
