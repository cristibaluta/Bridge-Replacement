//
//  SidebarView.swift
//  Imagin Bridge
//
//  Created by Cristian Baluta on 30.01.2026.
//

import SwiftUI

struct SidebarView: View {
    @ObservedObject var model: BrowserModel

    var body: some View {
        List(selection: $model.selectedFolder) {
            OutlineGroup(model.rootFolder, children: \.children) { folder in
                Label(folder.url.lastPathComponent, systemImage: "folder")
                    .tag(folder)
            }
        }
        .listStyle(.sidebar)
    }
    
}
