//
//  FSExpExtension.swift
//  FSExpExtension
//
//  Created by Khaos Tian on 6/13/24.
//

import ExtensionFoundation
import Foundation
import FSKit

@main
final class MyFSExtension: UnaryFilesystemExtension {

    var filesystem: MyFS {
        NSLog("🐛 Called filesystem")

        return .shared
    }
}

final class MyFS: FSUnaryFileSystem {

    static let shared = MyFS()
    
    override init() {
        super.init()
        
        containerState = .active
        NSLog("🐛 Meow")
    }
    
    enum FSError: Error {
        case internalError
    }
}

extension MyFS: FSUnaryFileSystemOperations {

    func load(
        _ resource: FSResource,
        options: [String]
    ) async throws -> FSVolume {
        NSLog("🐛 Load: \(resource), options: \(options)")

        let volume = MyVolume()

        return volume
    }

    func didFinishLoading() {
        NSLog("🐛 DidFinishLoading")
    }
}

extension MyFS: FSManageableResourceMaintenanceOperations {

    func checkFileSystem(
        parameters: [String],
        connection: FSMessageConnection,
        taskID: UUID
    ) async throws -> Progress? {
        NSLog("🐛 Check")

        let progress = Progress(totalUnitCount: 1)
        progress.completedUnitCount = 1
        return progress
    }
    
    func formatFileSystem(
        parameters: [String],
        connection: FSMessageConnection,
        taskID: UUID
    ) async throws -> Progress? {
        NSLog("🐛 Format")

        let progress = Progress(totalUnitCount: 1)
        progress.completedUnitCount = 1
        return progress
    }
    
}

extension MyFS: FSBlockDeviceOperations {

    func probeResource(
        _ resource: FSResource,
        replyHandler: @escaping (FSProbeResult?, (any Error)?) -> Void
    ) {
        NSLog("🐛 Probe Resource: \(resource)")

        let id = FSContainerIdentifier(uuid: UUID(uuidString: "51D4A02B-AC65-4D61-95FF-EA8F939E79C8")!)
        
        replyHandler(
            FSProbeResult(result: .usable,
                          name: "TestVol",
                          containerID: id),
            nil
        )
    }
}
