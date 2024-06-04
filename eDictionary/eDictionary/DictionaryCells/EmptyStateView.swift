//
//  EmptyStateView.swift
//  eDictionary
//
//  Created by Nikhil Bhosale on 2024-06-04.
//

import SwiftUI

struct EmptyStateView: View {
    let searchText: String

    var body: some View {
        VStack {
            Spacer()
            Image(.emptyState)
            if searchText.isEmpty {
                Text("Dictionary is empty. Please try reload!!")
            } else {
                Text("Sorry!! Nothing matches the search")
            }
            Spacer()
        }

    }
}

#Preview {
    VStack {
        EmptyStateView(searchText: "")
        EmptyStateView(searchText: "test")
    }
}
