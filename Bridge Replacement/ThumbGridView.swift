//
//  ThumbGridView.swift
//  Imagin Bridge
//
//  Created by Cristian Baluta on 30.01.2026.
//

import SwiftUI

struct ThumbGridView: View {
    let photos: [PhotoItem]
    @ObservedObject var model: BrowserModel

    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(photos) { photo in
                    ThumbCell(path: photo.path, isSelected: model.selectedPhoto?.id == photo.id)
                        .frame(width: 100, height: 150)
                        .onTapGesture {
                            model.selectedPhoto = photo
                        }
                }
            }
            .padding()
        }
        .frame(width: 300+60)
    }
}
