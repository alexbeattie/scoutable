//
//  HomeFeedView.swift
//  Scoutable
//
//  Created by Alex Beattie on 7/14/25.
//

import SwiftUI
struct HomeFeedView: View {
    var body: some View {
        NavigationView {
            List(samplePosts) { post in
                PostView(post: post)
                    .listRowInsets(EdgeInsets()) // Make post view take full width
                    .padding(.vertical, 8)
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Home")
        }
    }
}
