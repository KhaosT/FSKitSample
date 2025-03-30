//
//  MyFSItem.swift
//  FSKitExp
//
//  Created by Khaos Tian on 3/30/25.
//

import Foundation
import FSKit

final class MyFSItem: FSItem {
    
    private static var id: UInt64 = FSItem.Identifier.rootDirectory.rawValue + 1
    static func getNextID() -> UInt64 {
        let current = id
        id += 1
        return current
    }
    
    let name: FSFileName
    let id = MyFSItem.getNextID()
    
    var attributes = FSItem.Attributes()
    var xattrs: [FSFileName: Data] = [:]
    var data: Data?
    
    private(set) var children: [FSFileName: MyFSItem] = [:]
    
    init(name: FSFileName) {
        self.name = name
        attributes.fileID = FSItem.Identifier(rawValue: id) ?? .invalid
        attributes.size = 0
        attributes.allocSize = 0
        attributes.flags = 0
        
        var timespec = timespec()
        timespec_get(&timespec, TIME_UTC)
        
        attributes.addedTime = timespec
        attributes.birthTime = timespec
        attributes.changeTime = timespec
        attributes.modifyTime = timespec
    }
    
    func addItem(_ item: MyFSItem) {
        children[item.name] = item
    }
    
    func removeItem(_ item: MyFSItem) {
        children[item.name] = nil
    }
}
