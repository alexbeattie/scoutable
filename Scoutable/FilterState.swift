//
//  FilterState.swift
//  Scoutable
//
//  Created by Alex Beattie on 7/14/25.
//

import SwiftUI
// MARK: - Filter State
/// An observable object to hold the state of the active filters.
class FilterState: ObservableObject {
    @Published var minUTR: Double = 1.0
    @Published var maxUTR: Double = 16.0
    @Published var selectedGradYear: Int? = nil
    
    // A computed property to check if any filters are active.
    var isFiltering: Bool {
        minUTR > 1.0 || maxUTR < 16.0 || selectedGradYear != nil
    }
    
    func reset() {
        minUTR = 1.0
        maxUTR = 16.0
        selectedGradYear = nil
    }
}

