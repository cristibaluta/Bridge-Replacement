//
//  SortPopoverView.swift
//  Bridge Replacement
//
//  Created by Cristian Baluta on 01.02.2026.
//

import SwiftUI

struct SortPopoverView: View {
    @Binding var sortOption: ThumbGridView.SortOption
    @Binding var sortAscending: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sort Photos")
                .font(.headline)
                .padding(.bottom, 4)
            
            // Sort by options
            VStack(alignment: .leading, spacing: 8) {
                ForEach(ThumbGridView.SortOption.allCases, id: \.self) { option in
                    Button(action: {
                        sortOption = option
                    }) {
                        HStack {
                            Image(systemName: sortOption == option ? "circle.fill" : "circle")
                                .foregroundColor(sortOption == option ? .blue : .gray)
                            Text(option.rawValue)
                            Spacer()
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            Divider()
            
            // Sort direction
            VStack(alignment: .leading, spacing: 8) {
                Text("Order")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Button(action: {
                    sortAscending = true
                }) {
                    HStack {
                        Image(systemName: sortAscending ? "circle.fill" : "circle")
                            .foregroundColor(sortAscending ? .blue : .gray)
                        Text("Ascending (A-Z, Oldest first)")
                        Spacer()
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    sortAscending = false
                }) {
                    HStack {
                        Image(systemName: !sortAscending ? "circle.fill" : "circle")
                            .foregroundColor(!sortAscending ? .blue : .gray)
                        Text("Descending (Z-A, Newest first)")
                        Spacer()
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(16)
        .frame(minWidth: 250)
    }
}

#Preview {
    SortPopoverView(
        sortOption: .constant(.name),
        sortAscending: .constant(true)
    )
}