//
//  FilterView.swift
//  Scoutable
//
//  Created by Alex Beattie on 7/14/25.
//

import SwiftUI
// MARK: - Filter View
struct FilterView: View {
    @ObservedObject var filters: FilterState
    @Environment(\.dismiss) var dismiss
    
    let gradYears = ["All", "2024", "2025", "2026", "2027", "2028"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("UTR Range")) {
                    let minUTRText = String(format: "%.1f", filters.minUTR)
                    let maxUTRText = String(format: "%.1f", filters.maxUTR)
                    Text("Between \(minUTRText) and \(maxUTRText)")
                    
                    // A simple way to create a range slider
                    VStack {
                        Slider(value: $filters.minUTR, in: 1...filters.maxUTR, step: 0.1)
                        Slider(value: $filters.maxUTR, in: filters.minUTR...16, step: 0.1)
                    }
                }
                
                Section(header: Text("Graduation Year")) {
                    Picker("Select Year", selection: $filters.selectedGraduationYear) {
                        ForEach(gradYears, id: \.self) { year in
                            Text(year).tag(year)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        filters.resetFilters()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

