//
//  FSKitExpExtension.swift
//  FSKitExpExtension
//
//  Created by Khaos Tian on 3/30/25.
//

import Foundation
import FSKit

@main
struct FSKitExpExtension : UnaryFileSystemExtension {
    
    var fileSystem : FSUnaryFileSystem & FSUnaryFileSystemOperations {
        MyFS()
    }
}
