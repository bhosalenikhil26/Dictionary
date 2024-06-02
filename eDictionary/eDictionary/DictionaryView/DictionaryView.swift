//
//  ContentView.swift
//  eDictionary
//
//  Created by Nikhil Bhosale on 2024-06-01.
//

import SwiftUI

struct DictionaryView<ViewModel: DictionaryViewModelProtocol>: View {
    @StateObject var viewModel: ViewModel

    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Hello, world!")
            }
            .padding()
        }
        .navigationTitle("Dictionary")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                refreshButton()
            }
        }
    }
}

private extension DictionaryView {
    @ViewBuilder func refreshButton() -> some View {
        HStack {
            Spacer()
            Button {
                viewModel.refreshDictionary()
            } label: {
                Image(systemName: "gobackward")
            }
        }
    }

    func getViewModel() -> any DictionaryViewModelProtocol {
        DictionaryViewModel(wordsLoaderService:
                                WordsLoaderService(apiWordsLoaderService:
                                                    APIWordsLoaderService(dispatcher:
                                                                            APIRequestDispatcher()
                                                                         ),
                                                   persisterService: SQLitePersister()
                                                  )
        )
    }
}

#Preview {
    DictionaryView(viewModel: MockViewModel())
}

final class MockViewModel: DictionaryViewModelProtocol {
    var loadingState: LoadingState = .loaded

    func refreshDictionary() {}
}
