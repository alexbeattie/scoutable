//
//  InfoRow.swift
//  Scoutable
//
//  Created by Alex Beattie on 7/14/25.
//
import SwiftUI


struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .fontWeight(.semibold)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 2)
    }
}

