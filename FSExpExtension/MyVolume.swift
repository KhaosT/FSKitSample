//
//  MyVolume.swift
//  FSKitExp
//
//  Created by Khaos Tian on 6/27/24.
//

import FSKit
import os

final class MyVolume: FSVolume, FSVolumeOperations {
    
    private let root: MyItem = {
        let item = MyItem(name: "/")
        item.attributes.type = .dir
        item.attributes.mode = 0b111_111_111
        return item
    }()
    
    var volumeStatistics: FSKitStatfsResult {
        return FSKitStatfsResult.statFS(
            withBlockSize: 1,
            ioSize: 1,
            totalBlocks: 1,
            availableBlocks: 0,
            freeBlocks: 0,
            totalFiles: 1,
            freeFiles: 0,
            fsSubType: 0,
            fsTypeName: "MyFS"
        )
    }
    
    override var volumeSupportedCapabilities: FSVolumeSupportedCapabilities {
        let capabilities = FSVolumeSupportedCapabilities()
        capabilities.supportsNoVolumeSizes = true
        return capabilities
    }
    
    override init() {
        super.init()
        
        volumeID = FSVolumeIdentifier(
            uuid: UUID(uuidString: "BC74BFE1-3ADA-4489-A4F2-B432A08DD00B")!
        )
        volumeName = "TestV1"
        volumeState = .ready
    }
    
    func setNewState(
        _ wantedState: FSVolumeState,
        forced: Bool,
        replyHandler reply: @escaping (FSVolumeState, (any Error)?) -> Void
    ) {
        NSLog("🐛 State: \(wantedState)")
        reply(wantedState, nil)
    }
    
    func mount(
        _ options: FSTaskOptionsBundle,
        replyHandler reply: @escaping (FSItem?, (any Error)?) -> Void
    ) {
        NSLog("🐛 Mount: \(options)")
        
        reply(root, nil)
    }
    
    func unmount(_ reply: @escaping () -> Void) {
        NSLog("🐛 Unmount")
        reply()
    }
    
    func synchronize(_ reply: @escaping ((any Error)?) -> Void) {
        NSLog("🐛 synchronize")
        reply(nil)
    }
    
    func getItemAttributes(
        _ item: FSItem,
        requestedAttributes desired: FSItemGetAttributesRequest,
        replyHandler reply: @escaping (FSItemAttributes?, (any Error)?) -> Void
    ) {
        if let item = item as? MyItem {
            NSLog("🐛 getItemAttributes1: \(item.name), \(desired)")
            reply(item.attributes, nil)
        } else {
            NSLog("🐛 getItemAttributes2: \(item), \(desired)")
            reply(nil, fs_errorForPOSIXError(POSIXError.EIO.rawValue))
        }
    }
    
    func setItemAttributes(
        _ item: FSItem,
        requestedAttributes newAttributes: FSItemSetAttributesRequest,
        replyHandler reply: @escaping (FSItemAttributes?, (any Error)?) -> Void
    ) {
        NSLog("🐛 setItemAttributes: \(item), \(newAttributes)")
        if let item = item as? MyItem {
            mergeAttributes(item.attributes, request: newAttributes)
            reply(item.attributes, nil)
        } else {
            reply(nil, fs_errorForPOSIXError(POSIXError.EIO.rawValue))
        }
    }
    
    func lookupName(
        _ name: FSFileName,
        inDirectory directory: FSItem,
        replyHandler reply: @escaping (FSItem?, (any Error)?) -> Void
    ) {
        NSLog("🐛 lookupName: \(String(describing: name.string)), \(directory)")
        
        guard let directory = directory as? MyItem else {
            reply(nil, fs_errorForPOSIXError(POSIXError.ENOENT.rawValue))
            return
        }
        
        if let name = name.string, let item = directory.children[name] {
            reply(item, nil)
        } else {
            reply(nil, fs_errorForPOSIXError(POSIXError.ENOENT.rawValue))
        }
    }
    
    func reclaim(
        _ item: FSItem,
        replyHandler reply: @escaping ((any Error)?) -> Void
    ) {
        NSLog("🐛 reclaim: \(item)")
        reply(nil)
    }
    
    func readSymbolicLink(
        _ item: FSItem,
        replyHandler reply: @escaping (FSFileName?, (any Error)?) -> Void
    ) {
        NSLog("🐛 readSymbolicLink: \(item)")
        reply(nil, fs_errorForPOSIXError(POSIXError.EIO.rawValue))
    }
    
    func createItemNamed(
        _ name: FSFileName,
        type: FSItemType,
        inDirectory directory: FSItem,
        attributes newAttributes: FSItemSetAttributesRequest,
        replyHandler reply: @escaping (FSItem?, (any Error)?) -> Void
    ) {
        NSLog("🐛 createItemNamed: \(String(describing: name.string)) - \(newAttributes.mode)")
        
        guard let directory = directory as? MyItem else {
            reply(nil, fs_errorForPOSIXError(POSIXError.EIO.rawValue))
            return
        }
        
        let item = MyItem(name: name.string ?? "Unknown")
        mergeAttributes(item.attributes, request: newAttributes)
        directory.addItem(item)
        
        reply(item, nil)
    }
    
    func createSymbolicLinkNamed(
        _ name: FSFileName,
        inDirectory directory: FSItem,
        attributes newAttributes: FSItemSetAttributesRequest,
        linkContents contents: Data,
        replyHandler reply: @escaping (FSItem?, (any Error)?) -> Void
    ) {
        NSLog("🐛 createSymbolicLinkNamed: \(name)")
        reply(nil, fs_errorForPOSIXError(POSIXError.EIO.rawValue))
    }
    
    func createLinkof(
        _ item: FSItem,
        named name: FSFileName,
        inDirectory directory: FSItem,
        replyHandler reply: @escaping ((any Error)?) -> Void
    ) {
        NSLog("🐛 createLinkof: \(name)")
        reply(fs_errorForPOSIXError(POSIXError.EIO.rawValue))
    }
    
    func remove(
        _ item: FSItem,
        named name: FSFileName,
        fromDirectory directory: FSItem,
        replyHandler reply: @escaping ((any Error)?) -> Void
    ) {
        NSLog("🐛 remove: \(name)")
        if let item = item as? MyItem, let directory = directory as? MyItem {
            directory.removeItem(item)
            reply(nil)
        } else {
            reply(fs_errorForPOSIXError(POSIXError.EIO.rawValue))
        }
    }
    
    func renameItem(
        _ item: FSItem,
        inDirectory sourceDirectory: FSItem,
        named sourceName: FSFileName,
        toDirectory destinationDirectory: FSItem,
        newName destinationName: FSFileName,
        overItem: FSItem?,
        with options: FSRenameItemOptions = [],
        replyHandler reply: @escaping ((any Error)?) -> Void
    ) {
        NSLog("🐛 renameItem: \(item)")
        reply(fs_errorForPOSIXError(POSIXError.EIO.rawValue))
    }
    
    func enumerateDirectory(
        _ directory: FSItem,
        startingAtCookie cookie: UInt64,
        verifier: UInt64,
        provideAttributes: Bool,
        attributes: FSItemGetAttributesRequest?,
        using packer: @escaping FSDirEntryPacker,
        replyHandler reply: @escaping (UInt64, (any Error)?) -> Void
    ) {
        NSLog("🐛 enumerateDirectory: \(directory)")

        guard let directory = directory as? MyItem else {
            reply(0, fs_errorForPOSIXError(POSIXError.ENOENT.rawValue))
            return
        }
        
        for (idx, item) in directory.children.values.enumerated() {
            let isLast = (idx == directory.children.count - 1)
            
            let v = packer(
                FSFileName(string: item.name),
                item.attributes.type,
                item.id,
                item.id,
                item.attributes,
                isLast
            )
            
            NSLog("🐛 V: \(v) - isLast: \(isLast)")
        }
        
        reply(1, nil)
    }
    
    func activate(
        _ options: FSTaskOptionsBundle,
        replyHandler reply: @escaping (FSItem?, (any Error)?) -> Void
    ) {
        NSLog("🐛 activate: \(options)")
        reply(
            root,
            nil
        )
    }
    
    func deactivate(_ options: Int, replyHandler reply: @escaping ((any Error)?) -> Void) {
        NSLog("🐛 deactivate: \(options)")
        reply(nil)
    }
    
    func pc_LINK_MAX() -> Int32 {
        return 256
    }
    
    func pc_NAME_MAX() -> Int32 {
        return 256
    }
    
    func pc_CHOWN_RESTRICTED() -> Int32 {
        return 1
    }
    
    func pc_NO_TRUNC() -> Int32 {
        return 1
    }
    
    func pc_CASE_SENSITIVE() -> Int32 {
        return 0
    }
    
    func pc_CASE_PRESERVING() -> Int32 {
        return 1
    }
    
    func pc_XATTR_SIZE_BITS() -> Int32 {
        return 64
    }
    
    func pc_FILESIZEBITS() -> Int32 {
        return 17
    }
    
    private func mergeAttributes(_ existing: FSItemAttributes, request: FSItemSetAttributesRequest) {
        if request.uidWasConsumed {
            existing.uid = request.uid
        }
        
        if request.gidWasConsumed {
            existing.gid = request.gid
        }
        
        if request.typeWasConsumed {
            existing.type = request.type
        }
        
        if request.modeWasConsumed {
            existing.mode = request.mode
        }
        
        if request.numLinksWasConsumed {
            existing.numLinks = request.numLinks
        }
        
        if request.bsdFlagsWasConsumed {
            existing.bsdFlags = request.bsdFlags
        }
        
        if request.sizeWasConsumed {
            existing.size = request.size
        }
        
        if request.allocSizeWasConsumed {
            existing.allocSize = request.allocSize
        }
        
        if request.fileidWasConsumed {
            existing.fileid = request.fileid
        }
        
        if request.parentidWasConsumed {
            existing.parentid = request.parentid
        }
        
        if request.accessTimeWasConsumed {
            var timespec = timespec()
            request.accessTime(&timespec)
            existing.setAccessTime(&timespec)
        }
        
        if request.changeTimeWasConsumed {
            var timespec = timespec()
            request.changeTime(&timespec)
            existing.setChangeTime(&timespec)
        }
        
        if request.modifyTimeWasConsumed {
            var timespec = timespec()
            request.modifyTime(&timespec)
            existing.setModifyTime(&timespec)
        }
        
        if request.addedTimeWasConsumed {
            var timespec = timespec()
            request.addedTime(&timespec)
            existing.setAddedTime(&timespec)
        }
        
        if request.birthTimeWasConsumed {
            var timespec = timespec()
            request.birthTime(&timespec)
            existing.setBirthTime(&timespec)
        }
        
        if request.backupTimeWasConsumed {
            var timespec = timespec()
            request.backupTime(&timespec)
            existing.setBackupTime(&timespec)
        }
    }
}

extension MyVolume: FSVolumeOpenCloseOperations {
    
    func open(
        _ item: FSItem,
        withMode mode: Int32,
        replyHandler reply: @escaping ((any Error)?) -> Void
    ) {
        if let item = item as? MyItem {
            NSLog("🐛 open: \(item.name)")
        } else {
            NSLog("🐛 open: \(item)")
        }
        reply(nil)
    }
    
    func close(
        _ item: FSItem,
        keepingMode mode: Int32,
        replyHandler reply: @escaping ((any Error)?) -> Void
    ) {
        if let item = item as? MyItem {
            NSLog("🐛 close: \(item.name)")
        } else {
            NSLog("🐛 close: \(item)")
        }
        reply(nil)
    }
}

extension MyVolume: FSVolumeXattrOperations {
    
    var xattrOperationsInhibited: Bool {
        get {
            NSLog("🐛 xattrOperationsInhibited called")
            return true
        }
        
        set {
            NSLog("🐛 xattrOperationsInhibited set: \(newValue)")
        }
    }
    
    func xattr(
        of item: FSItem,
        named name: FSFileName,
        replyHandler reply: @escaping (Data?, (any Error)?) -> Void
    ) {
        NSLog("🐛 xattr: \(item)")
        reply(nil, nil)
    }
    
    func setXattrOf(
        _ item: FSItem,
        named name: FSFileName,
        value: Data?,
        how: FSKitXattrCreateRequirementAndFlags,
        replyHandler reply: @escaping ((any Error)?) -> Void
    ) {
        NSLog("🐛 setXattrOf: \(item)")
        reply(nil)
    }
    
    func listXattrs(of item: FSItem, replyHandler reply: @escaping ([String]?, (any Error)?) -> Void) {
        NSLog("🐛 listXattrs: \(item)")
        reply([], nil)
    }
}

extension MyVolume: FSVolumeReadWriteOperations {
    
    func read(
        fromFile item: FSItem,
        offset: UInt64,
        length: Int,
        buffer: FSMutableFileDataBuffer,
        replyHandler reply: @escaping (Int, (any Error)?) -> Void
    ) {
        NSLog("🐛 read: \(item)")
        reply(0, nil)
    }
    
    func write(
        toFile item: FSItem,
        offset: UInt64,
        buffer: Data,
        replyHandler reply: @escaping (Int, (any Error)?) -> Void
    ) {
        NSLog("🐛 write: \(item)")
        reply(buffer.count, nil)
    }
}
