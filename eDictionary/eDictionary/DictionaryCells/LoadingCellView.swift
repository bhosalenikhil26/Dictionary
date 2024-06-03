//
//  LoadingCellView.swift
//  eDictionary
//
//  Created by Nikhil Bhosale on 2024-06-03.
//

import SwiftUI

struct LoadingCellView: View {
    var body: some View {
        HStack {
            Spacer()
            ActivityIndicator()
            Spacer()
        }
        .padding()
        .background(Color(.systemGray4))
        .cornerRadius(10)
    }
}

struct ActivityIndicator: UIViewRepresentable {
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.startAnimating()
        return indicator
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {}
}

struct ContentView: View {
    var body: some View {
        VStack {
            LoadingCellView()
                .padding()
            // Other content
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
