//
//  MyItem.swift
//  FSKitExp
//
//  Created by Khaos Tian on 6/27/24.
//

import FSKit

final class MyItem: FSUnaryItem {
    
    private static var id: UInt64 = 0
    static func getNextID() -> UInt64 {
        let current = id
        id += 1
        return current
    }
    
    let name: FSFileName
    let id = MyItem.getNextID()
    
    var attributes = FSItemAttributes()
    var xattrs: [FSFileName: Data] = [:]
    var data: Data?
    
    private(set) var children: [FSFileName: MyItem] = [:]
    
    init(name: FSFileName) {
        self.name = name
        attributes.fileID = id
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
    
    func addItem(_ item: MyItem) {
        children[item.name] = item
    }
    
    func removeItem(_ item: MyItem) {
        children[item.name] = nil
    }
}
