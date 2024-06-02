//
//  eDictionaryApp.swift
//  eDictionary
//
//  Created by Nikhil Bhosale on 2024-06-01.
//

import SwiftUI

@main
struct eDictionaryApp: App {
    var body: some Scene {
        WindowGroup {
            DictionaryView(viewModel: getDictionaryViewModel())
        }
    }

    private func getDictionaryViewModel() -> some DictionaryViewModelProtocol {
        DictionaryViewModel(
            wordsLoaderService:
                WordsLoaderService(
                    apiWordsLoaderService:
                        APIWordsLoaderService(
                            dispatcher:
                                APIRequestDispatcher()
                        ),
                    persisterService: SQLitePersister()
                )
        )

    }
}
