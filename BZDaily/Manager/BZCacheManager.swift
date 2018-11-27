//
//  BZCacheManager.swift
//  BZDaily
//
//  Created by 郑伟 on 2018/11/19.
//  Copyright © 2018 BourbonZ. All rights reserved.
//

import UIKit

class BZCacheManager: NSObject {
    
    static public func saveObject(data : Data, key : String) -> Void {
        var accountPath=NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        accountPath += "/"
        accountPath += key

        NSKeyedArchiver.archiveRootObject(data as Any, toFile: accountPath)
    }
    
    static public func objectFromKey(key : String) -> Data? {
        var accountPath=NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        accountPath += "/"
        accountPath += key
        let data = NSKeyedUnarchiver.unarchiveObject(withFile: accountPath)
        if data == nil {
            return nil
        }
        return (data as! Data)

    }
}
