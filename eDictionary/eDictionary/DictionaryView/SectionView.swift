//
//  SectionView.swift
//  eDictionary
//
//  Created by Nikhil Bhosale on 2024-06-04.
//

import SwiftUI

struct SectionView: View {
    let title: String
    let items: [String]

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title.capitalized)
                    .font(.headline)
                Spacer()
            }
            .padding()
            LazyVStack{
                ForEach(items, id: \.self) { item in
                    HStack {
                        Text(item)
                            .padding(.vertical, 10)
                            .padding(.horizontal)
                        Spacer()
                    }
                    .overlay(
                        Divider(), alignment: .bottom
                    )
                }
            }
            .background(Color(.secondarySystemBackground))
        }
    }
}

#Preview {
    SectionView(title: "A", items: ["aa", "Abc", "abcd"])
}
