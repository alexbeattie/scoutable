//
//  ProfileStatsGridView.swift
//  Scoutable
//
//  Created by Alex Beattie on 7/14/25.
//
import SwiftUI


struct ProfileStatsGridView: View {
    let player: Player
    
    var body: some View {
        HStack {
            StatBox(title: "UTR", value: String(format: "%.2f", player.utr))
            StatBox(title: "Stars", value: "\(player.stars)")
            StatBox(title: "Grad Year", value: "\(player.graduationYear)")
        }
    }
}
