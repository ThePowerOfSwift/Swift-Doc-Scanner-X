//
//  KeyChainManager.swift
//  Doc-Scanner-X
//
//  Created by dynamsoft on 2017/11/30.
//  Copyright © 2017年 Dynamsoft. All rights reserved.
//

import Foundation
import Security


class KeyChainManager {
    
    // MARK: - Class Methods
    
    static func saveUUID(_ uuid: String){
        let keyChainItem = [kSecClass as String: kSecAttrAccount, kSecValueData as String: uuid] as [String : Any]
        SecItemAdd(keyChainItem as CFDictionary, nil)
    }
    
    /**
     Read UUID from KeyChain. If there isn't UUID in KeyChain, generate one and save it.
     - Returns: User unique ID
    */
    static func readUUID() -> String? {
        var result: AnyObject?
        
        /// Initialize the search query.
        let query = [kSecClass as String: kSecAttrAccount, kSecReturnData as String: kCFBooleanTrue, kSecMatchLimit as String: kSecMatchLimitOne] as [String: Any]

        SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer(&result))
        var uuid = result as? String
        if uuid == nil {
            uuid = UIDevice.current.identifierForVendor?.uuidString
            saveUUID(uuid!)
            return uuid
        } else {
            return uuid
        }
    }
}
