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
        self.listHeaderView = BZTableHeaderView.init(frame: CGRect.init(x: 0, y: 0, width: screenWidth!, height: 220 + (UIApplication.shared.keyWindow?.safeAreaInsets.bottom)!))
        self.listHeaderView!.backgroundColor = UIColor.clear
        self.listTable?.tableHeaderView = self.listHeaderView
        self.listTable?.tableFooterView = UIView.init()

        
        self.naviView = BZNaviView(frame:CGRect.zero)
        self.view.addSubview(self.naviView!)

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    
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
            layout.height = YGValue.init(integerLiteral: Int(47 + (UIApplication.shared.keyWindow?.safeAreaInsets.bottom)!))
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
        if (contentOffset.y < 0 && scrollView.isDragging) {
            scrollView.setContentOffset(CGPoint.zero, animated: false)
        }
    }
}
