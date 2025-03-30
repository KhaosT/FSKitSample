//
//  MyFSVolume.swift
//  FSKitExp
//
//  Created by Khaos Tian on 3/30/25.
//

import Foundation
import FSKit
import os

final class MyFSVolume: FSVolume {
    
    private let resource: FSResource
    
    private let logger = Logger(subsystem: "FSKitExp", category: "MyFSVolume")
    
    private let root: MyFSItem = {
        let item = MyFSItem(name: FSFileName(string: "/"))
        item.attributes.parentID = .parentOfRoot
        item.attributes.fileID = .rootDirectory
        item.attributes.uid = 0
        item.attributes.gid = 0
        item.attributes.linkCount = 1
        item.attributes.type = .directory
        item.attributes.mode = UInt32(S_IFDIR | 0b111_000_000)
        item.attributes.allocSize = 1
        item.attributes.size = 1
        return item
    }()
    
    init(resource: FSResource) {
        self.resource = resource
        
        super.init(
            volumeID: FSVolume.Identifier(uuid: Constants.volumeIdentifier),
            volumeName: FSFileName(string: "Test1")
        )
    }
}

extension MyFSVolume: FSVolume.PathConfOperations {
    
    var maximumLinkCount: Int {
        return -1
    }
    
    var maximumNameLength: Int {
        return -1
    }
    
    var restrictsOwnershipChanges: Bool {
        return false
    }
    
    var truncatesLongNames: Bool {
        return false
    }
    
    var maximumXattrSize: Int {
        return Int.max
    }
    
    var maximumFileSize: UInt64 {
        return UInt64.max
    }
}

extension MyFSVolume: FSVolume.Operations {
    
    var supportedVolumeCapabilities: FSVolume.SupportedCapabilities {
        logger.debug("supportedVolumeCapabilities")
        
        let capabilities = FSVolume.SupportedCapabilities()
        capabilities.supportsHardLinks = true
        capabilities.supportsSymbolicLinks = true
        capabilities.supportsPersistentObjectIDs = true
        capabilities.doesNotSupportVolumeSizes = true
        capabilities.supportsHiddenFiles = true
        capabilities.supports64BitObjectIDs = true
        capabilities.caseFormat = .insensitiveCasePreserving
        return capabilities
    }
    
    var volumeStatistics: FSStatFSResult {
        logger.debug("volumeStatistics")

        let result = FSStatFSResult(fileSystemTypeName: "MyFS")
        
        result.blockSize = 1024000
        result.ioSize = 1024000
        result.totalBlocks = 1024000
        result.availableBlocks = 1024000
        result.freeBlocks = 1024000
        result.totalFiles = 1024000
        result.freeFiles = 1024000
        
        return result
    }
    
    
    func activate(options: FSTaskOptions) async throws -> FSItem {
        logger.debug("activate")
        return root
    }
    
    func deactivate(options: FSDeactivateOptions = []) async throws {
        logger.debug("deactivate")
    }
    
    func mount(options: FSTaskOptions) async throws {
        logger.debug("mount")
    }
    
    func unmount() async {
        logger.debug("unmount")
    }
    
    func synchronize(flags: FSSyncFlags) async throws {
        logger.debug("synchronize")
    }
    
    func attributes(
        _ desiredAttributes: FSItem.GetAttributesRequest,
        of item: FSItem
    ) async throws -> FSItem.Attributes {
        if let item = item as? MyFSItem {
            logger.debug("getItemAttributes1: \(item.name), \(desiredAttributes)")
            return item.attributes
        } else {
            logger.debug("getItemAttributes2: \(item), \(desiredAttributes)")
            throw fs_errorForPOSIXError(POSIXError.EIO.rawValue)
        }
    }
    
    func setAttributes(
        _ newAttributes: FSItem.SetAttributesRequest,
        on item: FSItem
    ) async throws -> FSItem.Attributes {
        logger.debug("setItemAttributes: \(item), \(newAttributes)")
        if let item = item as? MyFSItem {
            mergeAttributes(item.attributes, request: newAttributes)
            return item.attributes
        } else {
            throw fs_errorForPOSIXError(POSIXError.EIO.rawValue)
        }
    }
    
    func lookupItem(
        named name: FSFileName,
        inDirectory directory: FSItem
    ) async throws -> (FSItem, FSFileName) {
        logger.debug("lookupName: \(String(describing: name.string)), \(directory)")
        
        guard let directory = directory as? MyFSItem else {
            throw fs_errorForPOSIXError(POSIXError.ENOENT.rawValue)
        }
        
        if let item = directory.children[name] {
            return (item, name)
        } else {
            throw fs_errorForPOSIXError(POSIXError.ENOENT.rawValue)
        }
    }
    
    func reclaimItem(_ item: FSItem) async throws {
        logger.debug("reclaimItem: \(item)")
    }
    
    func readSymbolicLink(
        _ item: FSItem
    ) async throws -> FSFileName {
        logger.debug("readSymbolicLink: \(item)")
        throw fs_errorForPOSIXError(POSIXError.EIO.rawValue)
    }
    
    func createItem(
        named name: FSFileName,
        type: FSItem.ItemType,
        inDirectory directory: FSItem,
        attributes newAttributes: FSItem.SetAttributesRequest
    ) async throws -> (FSItem, FSFileName) {
        logger.debug("createItem: \(String(describing: name.string)) - \(newAttributes.mode)")
        
        guard let directory = directory as? MyFSItem else {
            throw fs_errorForPOSIXError(POSIXError.EIO.rawValue)
        }
        
        let item = MyFSItem(name: name)
        mergeAttributes(item.attributes, request: newAttributes)
        item.attributes.parentID = directory.attributes.fileID
        item.attributes.type = type
        directory.addItem(item)
        
        return (item, name)
    }
    
    func createSymbolicLink(
        named name: FSFileName,
        inDirectory directory: FSItem,
        attributes newAttributes: FSItem.SetAttributesRequest,
        linkContents contents: FSFileName
    ) async throws -> (FSItem, FSFileName) {
        logger.debug("createSymbolicLink: \(name)")
        throw fs_errorForPOSIXError(POSIXError.EIO.rawValue)
    }
    
    func createLink(
        to item: FSItem,
        named name: FSFileName,
        inDirectory directory: FSItem
    ) async throws -> FSFileName {
        logger.debug("createLink: \(name)")
        throw fs_errorForPOSIXError(POSIXError.EIO.rawValue)
    }
    
    func removeItem(
        _ item: FSItem,
        named name: FSFileName,
        fromDirectory directory: FSItem
    ) async throws {
        logger.debug("remove: \(name)")
        if let item = item as? MyFSItem, let directory = directory as? MyFSItem {
            directory.removeItem(item)
        } else {
            throw fs_errorForPOSIXError(POSIXError.EIO.rawValue)
        }
    }
    
    func renameItem(
        _ item: FSItem,
        inDirectory sourceDirectory: FSItem,
        named sourceName: FSFileName,
        to destinationName: FSFileName,
        inDirectory destinationDirectory: FSItem,
        overItem: FSItem?
    ) async throws -> FSFileName {
        logger.debug("rename: \(item)")
        throw fs_errorForPOSIXError(POSIXError.EIO.rawValue)
    }
    
    func enumerateDirectory(
        _ directory: FSItem,
        startingAt cookie: FSDirectoryCookie,
        verifier: FSDirectoryVerifier,
        attributes: FSItem.GetAttributesRequest?,
        packer: FSDirectoryEntryPacker
    ) async throws -> FSDirectoryVerifier {
        logger.debug("enumerateDirectory: \(directory)")

        guard let directory = directory as? MyFSItem else {
            throw fs_errorForPOSIXError(POSIXError.ENOENT.rawValue)
        }
        
        logger.debug("- enumerateDirectory - \(directory.name)")
        
        for (idx, item) in directory.children.values.enumerated() {
            let isLast = (idx == directory.children.count - 1)
            
            let v = packer.packEntry(
                name: item.name,
                itemType: item.attributes.type,
                itemID: item.attributes.fileID,
                nextCookie: FSDirectoryCookie(UInt64(idx)),
                attributes: attributes != nil ? item.attributes : nil
            )
            
            logger.debug("-- V: \(v) - \(item.name)")
        }

        return FSDirectoryVerifier(0)
    }
    
    private func mergeAttributes(_ existing: FSItem.Attributes, request: FSItem.SetAttributesRequest) {
        if request.isValid(FSItem.Attribute.uid) {
            existing.uid = request.uid
        }
        
        if request.isValid(FSItem.Attribute.gid) {
            existing.gid = request.gid
        }
        
        if request.isValid(FSItem.Attribute.type) {
            existing.type = request.type
        }
        
        if request.isValid(FSItem.Attribute.mode) {
            existing.mode = request.mode
        }
        
        if request.isValid(FSItem.Attribute.linkCount) {
            existing.linkCount = request.linkCount
        }
        
        if request.isValid(FSItem.Attribute.flags) {
            existing.flags = request.flags
        }
        
        if request.isValid(FSItem.Attribute.size) {
            existing.size = request.size
        }
        
        if request.isValid(FSItem.Attribute.allocSize) {
            existing.allocSize = request.allocSize
        }
        
        if request.isValid(FSItem.Attribute.fileID) {
            existing.fileID = request.fileID
        }

        if request.isValid(FSItem.Attribute.parentID) {
            existing.parentID = request.parentID
        }

        if request.isValid(FSItem.Attribute.accessTime) {
            let timespec = timespec()
            request.accessTime = timespec
            existing.accessTime = timespec
        }
        
        if request.isValid(FSItem.Attribute.changeTime) {
            let timespec = timespec()
            request.changeTime = timespec
            existing.changeTime = timespec
        }
        
        if request.isValid(FSItem.Attribute.modifyTime) {
            let timespec = timespec()
            request.modifyTime = timespec
            existing.modifyTime = timespec
        }
        
        if request.isValid(FSItem.Attribute.addedTime) {
            let timespec = timespec()
            request.addedTime = timespec
            existing.addedTime = timespec
        }
        
        if request.isValid(FSItem.Attribute.birthTime) {
            let timespec = timespec()
            request.birthTime = timespec
            existing.birthTime = timespec
        }
        
        if request.isValid(FSItem.Attribute.backupTime) {
            let timespec = timespec()
            request.backupTime = timespec
            existing.backupTime = timespec
        }
    }
}

extension MyFSVolume: FSVolume.OpenCloseOperations {
    
    func openItem(_ item: FSItem, modes: FSVolume.OpenModes) async throws {
        if let item = item as? MyFSItem {
            logger.debug("open: \(item.name)")
        } else {
            logger.debug("open: \(item)")
        }
    }
    
    func closeItem(_ item: FSItem, modes: FSVolume.OpenModes) async throws {
        if let item = item as? MyFSItem {
            logger.debug("close: \(item.name)")
        } else {
            logger.debug("close: \(item)")
        }
    }
}

extension MyFSVolume: FSVolume.XattrOperations {

    func xattr(named name: FSFileName, of item: FSItem) async throws -> Data {
        logger.debug("xattr: \(item) - \(name.string ?? "NA")")
        
        if let item = item as? MyFSItem {
            return item.xattrs[name] ?? Data()
        } else {
            return Data()
        }
    }
    
    func setXattr(named name: FSFileName, to value: Data?, on item: FSItem, policy: FSVolume.SetXattrPolicy) async throws {
        logger.debug("setXattrOf: \(item)")
        
        if let item = item as? MyFSItem {
            item.xattrs[name] = value
        }
    }
    
    func xattrs(of item: FSItem) async throws -> [FSFileName] {
        logger.debug("listXattrs: \(item)")
        
        if let item = item as? MyFSItem {
            return Array(item.xattrs.keys)
        } else {
            return []
        }
    }
}

extension MyFSVolume: FSVolume.ReadWriteOperations {

    func read(from item: FSItem, at offset: off_t, length: Int, into buffer: FSMutableFileDataBuffer) async throws -> Int {
        logger.debug("read: \(item)")
        
        var bytesRead = 0
        
        if let item = item as? MyFSItem, let data = item.data {
            bytesRead = data.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
                let length = min(buffer.length, data.count)
                _ = buffer.withUnsafeMutableBytes { dst in
                    memcpy(dst.baseAddress, ptr.baseAddress, length)
                }
                return length
            }
        }
        
        return bytesRead
    }
    
    func write(contents: Data, to item: FSItem, at offset: off_t) async throws -> Int {
        logger.debug("write: \(item) - \(offset)")
        
        if let item = item as? MyFSItem {
            logger.debug("- write: \(item.name)")
            item.data = contents
            item.attributes.size = UInt64(contents.count)
            item.attributes.allocSize = UInt64(contents.count)
        }
        
        return contents.count
    }
}
