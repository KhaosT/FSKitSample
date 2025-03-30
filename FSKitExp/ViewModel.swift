//
//  ViewModel.swift
//  FSKitExp
//
//  Created by Khaos Tian on 6/13/24.
//

import Foundation
import FSKit
import Observation

@Observable
@MainActor
final class ViewModel {
    
    private var client: FSClient?
    private(set) var modules: [FSModuleIdentity] = []
    
    init() {
        client = FSClient.shared
        client?.fetchInstalledExtensions { modules, errors in
            if let modules {
                self.modules = modules
            }
        }
    }
}
