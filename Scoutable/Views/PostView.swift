//
//  PostView.swift
//  Scoutable
//
//  Created by Alex Beattie on 7/14/25.
//

import SwiftUI
struct PostView: View {
    let post: Post
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "person.crop.circle.fill")
                    .font(.largeTitle)
                VStack(alignment: .leading) {
                    Text(post.authorName).fontWeight(.semibold)
                    Text(post.authorTitle).font(.caption).foregroundColor(.secondary)
                }
                Spacer()
                Text(post.timestamp).font(.caption).foregroundColor(.secondary)
            }
            
            Text(post.content)
                .font(.body)
            
            HStack {
                Button(action: {}) {
                    Label("Like", systemImage: "hand.thumbsup")
                }
                Spacer()
                Button(action: {}) {
                    Label("Comment", systemImage: "text.bubble")
                }
                Spacer()
                Button(action: {}) {
                    Label("Share", systemImage: "arrowshape.turn.up.right")
                }
            }
            .foregroundColor(.secondary)
            .padding(.top, 4)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
    }
}
