//
//  BZLoginManager.swift
//  BZDaily
//
//  Created by BourbonZ on 2018/11/14.
//  Copyright © 2018 BourbonZ. All rights reserved.
//

import UIKit
import Alamofire
class BZLoginManager: NSObject {
    
    static public func loginWithAnyone(block: @escaping (_ token:[String])->()) -> () {
        let url = "http://news-at.zhihu.com/api/7/anonymous-login"
        Alamofire.request(url).responseJSON { (response) in
            response.result.ifSuccess {
                do {
                    let result = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.allowFragments) as! Dictionary <String, Any>
                    let tokenString = result["access_token"] as! String
                    block([tokenString])
                } catch {}
            }
        }
    }
}
