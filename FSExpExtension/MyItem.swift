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
    
    let name: String
    let id = MyItem.getNextID()
    
    var attributes = FSItemAttributes()
    var xattrs: [String: Data] = [:]
    var data: Data?
    
    private(set) var children: [String: MyItem] = [:]
    
    init(name: String) {
        self.name = name
        attributes.fileid = id
        attributes.size = 0
        attributes.allocSize = 0
        attributes.bsdFlags = 0
        
        var timespec = timespec()
        timespec_get(&timespec, TIME_UTC)
        
        attributes.setAddedTime(&timespec)
        attributes.setBirthTime(&timespec)
        attributes.setChangeTime(&timespec)
        attributes.setModifyTime(&timespec)
    }
    
    func addItem(_ item: MyItem) {
        children[item.name] = item
    }
    
    func removeItem(_ item: MyItem) {
        children[item.name] = nil
    }
}
