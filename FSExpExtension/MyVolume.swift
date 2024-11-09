//
//  MyVolume.swift
//  FSKitExp
//
//  Created by Khaos Tian on 6/27/24.
//

import FSKit
import os

final class MyVolume: FSVolume {
    init() {
        super.init(
            volumeID: FSVolume.Identifier(
                uuid: UUID(uuidString: "BC74BFE1-3ADA-4489-A4F2-B432A08DD00B")!
            ),
            volumeName: FSFileName(string: "TestV1")
        )
    }
    
    private let root: MyItem = {
        let item = MyItem(name: FSFileName(string: "/"))
        item.attributes.parentID = 0
        item.attributes.uid = 0
        item.attributes.gid = 0
        item.attributes.linkCount = 1
        item.attributes.type = .directory
        item.attributes.mode = UInt32(S_IFDIR | 0b111_000_000)
        item.attributes.allocSize = 1
        item.attributes.size = 1
        return item
    }()
}

extension MyVolume: FSVolume.PathConfOperations {
    var maxLinkCount: Int32 {
        .max
    }

    var maxNameLength: Int32 {
        .max
    }

    var isChownRestricted: Bool {
        false
    }

    var isLongNameTruncated: Bool {
        false
    }

    var maxXattrSizeInBits: Int32 {
        .max
    }

    var maxFileSizeInBits: Int32 {
        .max
    }
}

extension MyVolume: FSVolume.Operations {

    var volumeStatistics: FSStatFSResult {
        let result = FSStatFSResult(fsTypeName: "MyFS")
        result.blockSize = 1024000
        result.ioSize = 1024000
        result.totalBlocks = 1024000
        result.availableBlocks = 1024000
        result.freeBlocks = 1024000
        result.totalFiles = 1024000
        result.freeFiles = 1024000
        result.filesystemSubType = 0
        return result
    }

    var supportedVolumeCapabilities: FSVolume.SupportedCapabilities {
        let capabilities = FSVolume.SupportedCapabilities()
        capabilities.supportsHardLinks = true
        capabilities.supportsSymbolicLinks = true
        capabilities.supportsPersistentObjectIDs = true
        capabilities.doesNotSupportVolumeSizes = true
        capabilities.supportsHiddenFiles = true
        capabilities.supports64BitObjectIDs = true
        return capabilities
    }

    func mount(options: [String]) async throws -> FSItem {
        NSLog("🐛 Mount: \(options)")

        return root
    }

    func unmountWithReplyHandler() async {
        NSLog("🐛 unmountWithReplyHandler")
    }

    func unmount() async throws {
        NSLog("🐛 unmount")
    }
    
    func synchronizeWithReplyHandler() async throws {
        NSLog("🐛 synchronizeWithReplyHandler")
    }

    func synchronize() async throws {
        NSLog("🐛 synchronize")
    }
    
    func getAttributes(_ desiredAttributes: FSItemGetAttributesRequest, of item: FSItem) async throws -> FSItemAttributes {
        if let item = item as? MyItem {
            NSLog("🐛 getItemAttributes1: \(item.name), \(desiredAttributes)")
            return item.attributes
        } else {
            NSLog("🐛 getItemAttributes2: \(item), \(desiredAttributes)")
            throw fs_errorForPOSIXError(POSIXError.EIO.rawValue)
        }
    }

    func setAttributes(_ newAttributes: FSItemSetAttributesRequest, on item: FSItem) async throws -> FSItemAttributes {
        NSLog("🐛 setItemAttributes: \(item), \(newAttributes)")
        if let item = item as? MyItem {
            mergeAttributes(item.attributes, request: newAttributes)
            return item.attributes
        } else {
            throw fs_errorForPOSIXError(POSIXError.EIO.rawValue)
        }
    }
    
    func lookupItem(named name: FSFileName, inDirectory directory: FSItem) async throws -> (FSItem, FSFileName) {
        NSLog("🐛 lookupName: \(String(describing: name.string)), \(directory)")
        
        guard let directory = directory as? MyItem else {
            throw fs_errorForPOSIXError(POSIXError.ENOENT.rawValue)
        }
        
        if let item = directory.children[name] {
            return (item, name)
        } else {
            throw fs_errorForPOSIXError(POSIXError.ENOENT.rawValue)
        }
    }

    func reclaim(item: FSItem) async throws {
        NSLog("🐛 reclaim: \(item)")
    }
    
    func readSymbolicLink(_ item: FSItem) async throws -> FSFileName {
        NSLog("🐛 readSymbolicLink: \(item)")
        throw fs_errorForPOSIXError(POSIXError.EIO.rawValue)
    }
    
    func createItem(
        named name: FSFileName,
        type: FSItemType,
        inDirectory directory: FSItem,
        attributes newAttributes: FSItemSetAttributesRequest
    ) async throws -> (FSItem, FSFileName) {
        NSLog("🐛 createItem: \(String(describing: name.string)) - \(newAttributes.mode)")
        
        guard let directory = directory as? MyItem else {
            throw fs_errorForPOSIXError(POSIXError.EIO.rawValue)
        }
        
        let item = MyItem(name: name)
        mergeAttributes(item.attributes, request: newAttributes)
        item.attributes.parentID = directory.id
        item.attributes.type = type
        directory.addItem(item)
        
        return (item, name)
    }
    
    func createSymbolicLink(
        named name: FSFileName,
        inDirectory directory: FSItem,
        attributes newAttributes: FSItemSetAttributesRequest,
        linkContents contents: FSFileName
    ) async throws -> (FSItem, FSFileName) {
        NSLog("🐛 createSymbolicLink: \(name)")
        throw fs_errorForPOSIXError(POSIXError.EIO.rawValue)
    }
    
    func createLink(to item: FSItem, named name: FSFileName, inDirectory directory: FSItem) async throws -> FSFileName {
        NSLog("🐛 createLink: \(name)")
        throw fs_errorForPOSIXError(POSIXError.EIO.rawValue)
    }
    
    func remove(
        item: FSItem,
        named name: FSFileName,
        fromDirectory directory: FSItem
    ) async throws {
        NSLog("🐛 remove: \(name)")
        if let item = item as? MyItem, let directory = directory as? MyItem {
            directory.removeItem(item)
        } else {
            throw fs_errorForPOSIXError(POSIXError.EIO.rawValue)
        }
    }
    
    func rename(
        item: FSItem,
        inDirectory sourceDirectory: FSItem,
        named sourceName: FSFileName,
        toNewName destinationName: FSFileName,
        inDirectory destinationDirectory: FSItem,
        overItem: FSItem?
    ) async throws -> FSFileName {
        NSLog("🐛 rename: \(item)")
        throw fs_errorForPOSIXError(POSIXError.EIO.rawValue)
    }
    
    func enumerateDirectory(
        _ directory: FSItem,
        startingAtCookie cookie: FSDirectoryCookie,
        verifier: FSDirectoryVerifier,
        providingAttributes attributes: FSItemGetAttributesRequest?,
        using packer: @escaping FSDirectoryEntryPacker
    ) async throws -> FSDirectoryVerifier {
        NSLog("🐛 enumerateDirectory: \(directory) - \(cookie) - \(verifier) - \(String(describing: attributes))")

        guard let directory = directory as? MyItem else {
            throw fs_errorForPOSIXError(POSIXError.ENOENT.rawValue)
        }
        
        NSLog("🐛 enumerateDirectory - \(directory.name)")
        
        for (idx, item) in directory.children.values.enumerated() {
            let isLast = (idx == directory.children.count - 1)
            
            let v = packer(
                item.name,
                item.attributes.type,
                item.id,
                idx,
                attributes != nil ? item.attributes : nil,
                isLast
            )
            
            NSLog("🐛 V: \(v) - \(item.name) - \(item.attributes.type) - isLast: \(isLast)")
        }

        return 0
    }
    
    func activate(options: [String]) async throws -> FSItem {
        NSLog("🐛 activate: \(options)")
        return root
    }

    func deactivate(options: FSDeactivateOptions = []) async throws {
        NSLog("🐛 deactivate: \(options)")
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
        return 8 * 1024 * 1024
    }
    
    func pc_FILESIZEBITS() -> Int32 {
        return 17
    }
    
    private func mergeAttributes(_ existing: FSItemAttributes, request: FSItemSetAttributesRequest) {
        if request.isValid(FSItemAttribute.UID) {
            existing.uid = request.uid
        }
        
        if request.isValid(FSItemAttribute.GID) {
            existing.gid = request.gid
        }
        
        if request.isValid(FSItemAttribute.type) {
            existing.type = request.type
        }
        
        if request.isValid(FSItemAttribute.mode) {
            existing.mode = request.mode
        }
        
        if request.isValid(FSItemAttribute.linkCount) {
            existing.linkCount = request.linkCount
        }
        
        if request.isValid(FSItemAttribute.flags) {
            existing.flags = request.flags
        }
        
        if request.isValid(FSItemAttribute.size) {
            existing.size = request.size
        }
        
        if request.isValid(FSItemAttribute.allocSize) {
            existing.allocSize = request.allocSize
        }
        
        if request.isValid(FSItemAttribute.fileID) {
            existing.fileID = request.fileID
        }

        if request.isValid(FSItemAttribute.parentID) {
            existing.parentID = request.parentID
        }

        if request.isValid(FSItemAttribute.accessTime) {
            let timespec = timespec()
            request.accessTime = timespec
            existing.accessTime = timespec
        }
        
        if request.isValid(FSItemAttribute.changeTime) {
            let timespec = timespec()
            request.changeTime = timespec
            existing.changeTime = timespec
        }
        
        if request.isValid(FSItemAttribute.modifyTime) {
            let timespec = timespec()
            request.modifyTime = timespec
            existing.modifyTime = timespec
        }
        
        if request.isValid(FSItemAttribute.addedTime) {
            let timespec = timespec()
            request.addedTime = timespec
            existing.addedTime = timespec
        }
        
        if request.isValid(FSItemAttribute.birthTime) {
            let timespec = timespec()
            request.birthTime = timespec
            existing.birthTime = timespec
        }
        
        if request.isValid(FSItemAttribute.backupTime) {
            let timespec = timespec()
            request.backupTime = timespec
            existing.backupTime = timespec
        }
    }
}

extension MyVolume: FSVolume.OpenCloseOperations {
    func openItem(_ item: FSItem, modes mode: FSVolume.OpenModes) async throws {
        if let item = item as? MyItem {
            NSLog("🐛 open: \(item.name)")
        } else {
            NSLog("🐛 open: \(item)")
        }
    }

    func close(_ item: FSItem, keeping mode: FSVolume.OpenModes) async throws {
        if let item = item as? MyItem {
            NSLog("🐛 close: \(item.name)")
        } else {
            NSLog("🐛 close: \(item)")
        }
    }
}

extension MyVolume: FSVolume.XattrOperations {
    func xattr(named name: FSFileName, ofItem item: FSItem) async throws -> Data {
        NSLog("🐛 xattr: \(item) - \(name.string ?? "NA")")
        
        if let item = item as? MyItem {
            return item.xattrs[name] ?? Data()
        } else {
            return Data()
        }
    }
    
    func setXattr(named name: FSFileName, toData value: Data?, onItem item: FSItem, policy: FSVolume.SetXattrPolicy) async throws {
        NSLog("🐛 setXattrOf: \(item)")
        
        if let item = item as? MyItem {
            item.xattrs[name] = value
        }
    }
    
    func listXattrs(of item: FSItem) async throws -> [FSFileName] {
        NSLog("🐛 listXattrs: \(item)")
        
        if let item = item as? MyItem {
            return Array(item.xattrs.keys)
        } else {
            return []
        }
    }
}

extension MyVolume: FSVolume.ReadWriteOperations {
    func read(
        fromFile item: FSItem,
        offset: UInt64,
        length: Int,
        intoBuffer buffer: NSMutableData
    ) async throws -> Int {
        NSLog("🐛 read: \(item)")
        
        var bytesRead = 0
        
        if let item = item as? MyItem, let data = item.data {
            bytesRead = data.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
                let length = min(buffer.length, data.count)
                memcpy(buffer.mutableBytes, ptr.baseAddress, length)
                return length
            }
        }
        
        return bytesRead
    }
    
    func writeContents(
        _ contents: Data,
        toFile item: FSItem,
        atOffset offset: UInt64
    ) async throws -> Int {
        NSLog("🐛 write: \(item) - \(offset)")
        
        if let item = item as? MyItem {
            NSLog("🐛 - write: \(item.name)")
            item.data = contents
            item.attributes.size = UInt64(contents.count)
            item.attributes.allocSize = UInt64(contents.count)
        }
        
        return contents.count
    }
}
