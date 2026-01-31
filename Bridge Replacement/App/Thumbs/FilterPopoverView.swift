//
//  FilterPopoverView.swift
//  Bridge Replacement
//
//  Created by Cristian Baluta on 01.02.2026.
//

import SwiftUI

struct FilterPopoverView: View {
    @Binding var selectedLabels: Set<String>
    
    // All available labels in the requested order
    private let availableLabels = ["No Label", "Select", "Second", "Approved", "Review", "To Do"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Filter by Labels")
                .font(.headline)
                .padding(.bottom, 4)
            
            ForEach(availableLabels, id: \.self) { label in
                Toggle(isOn: Binding(
                    get: { selectedLabels.contains(label) },
                    set: { isSelected in
                        if isSelected {
                            selectedLabels.insert(label)
                        } else {
                            selectedLabels.remove(label)
                        }
                    }
                )) {
                    Text(label)
                }
                .toggleStyle(CheckboxToggleStyle())
            }
        }
        .padding(16)
        .frame(minWidth: 100)
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
    FilterPopoverView(selectedLabels: .constant(Set(["Approved"])))
}
