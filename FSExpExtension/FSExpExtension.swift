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
    
    let filesystem: MyFS = .shared
}

final class MyFS: FSUnaryFileSystem, FSUnaryFileSystemOperations, FSManageableResourceSimpleMaintenanceOps {
    
    static let shared = MyFS()
    
    override init() {
        super.init()
        
        containerState = .ready
        NSLog("🐛 Meow")
    }
    
    func load(
        _ resource: FSResource,
        options: FSTaskOptionsBundle,
        replyHandler reply: @escaping (FSVolume?, (any Error)?) -> Void
    ) {
        NSLog("🐛 Load: \(resource), options: \(options)")
        
        let volume = MyVolume()
        
        reply(volume, nil)
    }
    
    func didFinishLoading() {
        NSLog("🐛 DidFinishLoading")
    }
    
    enum FSError: Error {
        case internalError
    }
}

extension MyFS: FSBlockDeviceOperations {
    
    func probeResource(
        _ resource: FSResource,
        replyHandler reply: @escaping (FSMatchResult, String?, FSContainerIdentifier?, (any Error)?) -> Void
    ) {
        NSLog("🐛 Probe Resource: \(resource)")
        
        let id = FSContainerIdentifier(uuid: UUID(uuidString: "51D4A02B-AC65-4D61-95FF-EA8F939E79C8")!)
        
        reply(
            .usable,
            "TestVol",
            id,
            nil
        )
    }
}
