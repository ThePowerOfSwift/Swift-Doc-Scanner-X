//
//  LocalData.swift
//  DCS SuperScanner
//
//  Created by dynamsoft on 2017/11/6.
//  Copyright © 2017年 com.dynamsoft. All rights reserved.
//

import UIKit

class LocalData: NSObject, NSCoding {
    
    // MARK: - Properties
    var dataName: String
    var dataType: UInt
    var dataTimeStamp: String
    
    // MARK: - Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("/localdata")
    
    // MARK: - Types
    struct PropertyKey {
        static let dataName = "dataName"
        static let dataType = "dataType"
        static let dataTimeStamp = "dataTimeStamp"
    }
    
    // MARK: - Initialization
    init(dataName: String, dataType: UInt, dataTimeStamp: String) {
        self.dataName = dataName
        self.dataType = dataType
        self.dataTimeStamp = dataTimeStamp
    }
    
    // MARK: - NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(dataName, forKey: PropertyKey.dataName)
        aCoder.encode(dataType, forKey: PropertyKey.dataType)
        aCoder.encode(dataTimeStamp, forKey: PropertyKey.dataTimeStamp)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let dataName = aDecoder.decodeObject(forKey: PropertyKey.dataName) as? String else {
            return nil
        }
        guard let dataType = aDecoder.decodeObject(forKey: PropertyKey.dataType) as? UInt else {
            return nil
        }
        guard let dataTimeStamp = aDecoder.decodeObject(forKey: PropertyKey.dataTimeStamp) as? String else {
            return nil
        }
        /// Call designated initializer.
        self.init(dataName: dataName, dataType: dataType, dataTimeStamp: dataTimeStamp)
    }
}
 
