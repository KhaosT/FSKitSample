//
//  MyFS.swift
//  FSKitExp
//
//  Created by Khaos Tian on 3/30/25.
//

import Foundation
import FSKit
import os

final class MyFS: FSUnaryFileSystem, FSUnaryFileSystemOperations {
    
    private let logger = Logger(subsystem: "FSKitExp", category: "MyFS")
    
    func probeResource(
        resource: FSResource,
        replyHandler: @escaping (FSProbeResult?, (any Error)?) -> Void
    ) {
        logger.debug("probeResource: \(resource, privacy: .public)")
        
        replyHandler(
            FSProbeResult.usable(
                name: "Test1",
                containerID: FSContainerIdentifier(uuid: Constants.containerIdentifier)
            ),
            nil
        )
    }
    
    func loadResource(
        resource: FSResource,
        options: FSTaskOptions,
        replyHandler: @escaping (FSVolume?, (any Error)?) -> Void
    ) {
        containerStatus = .ready
        logger.debug("loadResource: \(resource, privacy: .public)")
        replyHandler(
            MyFSVolume(resource: resource),
            nil
        )
    }
    
    func unloadResource(
        resource: FSResource,
        options: FSTaskOptions,
        replyHandler reply: @escaping ((any Error)?) -> Void
    ) {
        logger.debug("unloadResource: \(resource, privacy: .public)")
        reply(nil)
    }
    
    func didFinishLoading() {
        logger.debug("didFinishLoading")
    }
}
