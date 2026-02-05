//
//  FolderSelectionPopoverView.swift
//  Imagin Bridge
//
//  Created by Cristian Baluta on 31.01.2026.
//

import SwiftUI

struct FolderSelectionPopoverView: View {
    @EnvironmentObject var filesModel: FilesModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        SidebarView(onDoubleClick: nil)
            .environmentObject(filesModel)
    }
}
