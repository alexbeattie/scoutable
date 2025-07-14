//
//  OnboardingButton.swift
//  Scoutable
//
//  Created by Alex Beattie on 7/14/25.
//
import SwiftUI

/// A helper view for the buttons on the onboarding screen.
struct OnboardingButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .foregroundColor(.primary)
            .cornerRadius(12)
            .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
        }
    }
}
