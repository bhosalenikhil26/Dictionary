//
//  DictionaryViewModel.swift
//  eDictionary
//
//  Created by Nikhil Bhosale on 2024-06-02.
//

import Foundation

protocol DictionaryViewModelProtocol: ObservableObject {
    var loadingState: LoadingState { get }

    func refreshDictionary()
}

final class DictionaryViewModel {
    @Published var loadingState: LoadingState = .loading

    private let wordsLoaderService: WordsLoaderServiceProtocol

    init(wordsLoaderService: WordsLoaderServiceProtocol) {
        self.wordsLoaderService = wordsLoaderService
    }
}

extension DictionaryViewModel: DictionaryViewModelProtocol {
    func refreshDictionary() {
        //TODO: Ask service to refetch dictionary.
    }
}

enum LoadingState {
    case loading
    case loaded
    case failed
}


