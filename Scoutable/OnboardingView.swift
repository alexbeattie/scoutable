//
//  OnboardingView.swift
//  Scoutable
//
//  Created by Alex Beattie on 7/14/25.
//
import SwiftUI


// MARK: - Onboarding Flow (OnboardingView.swift)
/// A view that mimics the "Sign Up As" screen from the mockups.
// MARK: - Onboarding Flow (OnboardingView.swift)
/// A view that mimics the "Sign Up As" screen from the mockups.
struct OnboardingView: View {
    @Binding var userTypeSelected: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                Text("Scoutable")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Redefining how athletes, coaches, and media connect.")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Spacer()
                
                Text("Sign Up As:")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                // User Type Selection Buttons
                VStack(spacing: 15) {
                    OnboardingButton(title: "Player", icon: "figure.tennis") { userTypeSelected = true }
                    OnboardingButton(title: "Coach", icon: "figure.cooldown") { userTypeSelected = true }
                    OnboardingButton(title: "Showcase / Media", icon: "video.fill") { userTypeSelected = true }
                }
                .padding()
                
                Spacer()
                Spacer()
            }
            .navigationBarHidden(true)
            .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(userTypeSelected: .constant(false))
    }
}
