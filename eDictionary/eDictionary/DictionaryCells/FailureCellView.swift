//
//  FailureCellView.swift
//  eDictionary
//
//  Created by Nikhil Bhosale on 2024-06-03.
//

import SwiftUI

struct FailureCellView: View {
    var reload: () -> Void

    var body: some View {
        VStack(spacing: 15) {
            Text("A network error has unfortunately occurred.")
                .font(.headline)
                .foregroundStyle(.primary)
            HStack {
                Image(systemName: "gobackward")
                Text("Tap to reload")
            }
            .onTapGesture {
                reload()
            }
        }
        .padding()
        .background(Color(.systemGray4))
        .cornerRadius(10)
    }
}

#Preview {
    FailureCellView(reload: {})
}
