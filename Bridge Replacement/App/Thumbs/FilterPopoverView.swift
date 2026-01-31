//
//  FilterPopoverView.swift
//  Bridge Replacement
//
//  Created by Cristian Baluta on 01.02.2026.
//

import SwiftUI

struct FilterPopoverView: View {
    @Binding var showApprovedOnly: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Filter by Labels")
                .font(.headline)
                .padding(.bottom, 4)
            
            Toggle(isOn: $showApprovedOnly) {
                Text("Approved")
            }
            .toggleStyle(CheckboxToggleStyle())
        }
        .padding(16)
        .frame(minWidth: 150)
    }
}

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image(systemName: configuration.isOn ? "checkmark.square" : "square")
                .foregroundColor(configuration.isOn ? .accentColor : .primary)
                .onTapGesture {
                    configuration.isOn.toggle()
                }
            
            configuration.label
        }
    }
}

#Preview {
    FilterPopoverView(showApprovedOnly: .constant(false))
}