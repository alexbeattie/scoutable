//
//  ProfileHeaderView.swift
//  Scoutable
//
//  Created by Alex Beattie on 7/14/25.
//
import SwiftUI


// --- Helper Views for Profile ---

struct ProfileHeaderView: View {
    let player: Player
    
    var body: some View {
        VStack {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .padding(.top)
            
            Text("\(player.firstName) \(player.lastName)")
                .font(.title)
                .fontWeight(.bold)
            
            Text("\(player.sport) Athlete | Class of \(String(player.graduationYear))")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(player.location)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
