//
//  ContentView.swift
//  FSKitExp
//
//  Created by Khaos Tian on 6/13/24.
//

import SwiftUI

struct ContentView: View {
    
    @State
    private var viewModel = ViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.modules, id: \.self) { module in
                VStack(alignment: .leading) {
                    Text(module.bundleIdentifier)
                        .bold()
                    Text(module.url.absoluteString)
                    Text("\(module.isEnabled)")
                }
            }
        }
    }
}
