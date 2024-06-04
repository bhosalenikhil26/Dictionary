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
                switch viewModel.loadingState {
                case .notLoaded:
                    EmptyView()
                case .loading:
                    LoadingCellView()
                case .loaded(let eDictionary):
                    getList(for: eDictionary)
                case .failed:
                    FailureCellView {
                        Task {
                            await viewModel.refreshDictionary()
                        }
                    }
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Dictionary")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    refreshButton()
                }
            }
        }
    }
}

private extension DictionaryView {
    func refreshButton() -> some View {
        HStack {
            Spacer()
            Button {
                Task {
                    await viewModel.refreshDictionary()
                }
            } label: {
                Image(systemName: "gobackward")
            }
        }
    }

    func getList(for dictionary: [Character: [String]]) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, pinnedViews: .sectionHeaders) {
                ForEach(dictionary.keys.sorted(), id: \.self) { key in
                    if let words = dictionary[key] {
                        SectionView(title: String(key).capitalized, items: words)
                    } else {
                        EmptyView()
                    }
                }
            }
        }
    }

    func sectionHeader(for alphabet: Character) -> some View {
        Text(String(alphabet).capitalized)
            .frame(maxWidth: .infinity, alignment: .leading)
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
    var loadingState: LoadingState = .loaded(
        eDictionary: [
            "a": ["abc", "acd", "amb"],
            "b": ["bca", "bcd", "bam"]
        ]
    )

    func refreshDictionary() {}
}