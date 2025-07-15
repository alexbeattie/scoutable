//
//  ProfileHeaderView.swift
//  Scoutable
//
//  Created by Alex Beattie on 7/14/25.
//
import SwiftUI


// --- Helper Views for Profile ---

// --- Helper Views for Profile ---
struct ProfileHeaderView: View {
    let name: String
    let title: String
    
    var body: some View {
        VStack {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .padding(.top)
            
            Text(name)
                .font(.title)
                .fontWeight(.bold)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
