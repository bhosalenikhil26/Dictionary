//
//  DictionaryViewModel.swift
//  eDictionary
//
//  Created by Nikhil Bhosale on 2024-06-02.
//

import Foundation
import Combine

protocol DictionaryViewModelProtocol: ObservableObject {
    var loadingState: LoadingState { get }

    func refreshDictionary() async
    func search(for query: String) async
}

final class DictionaryViewModel {
    @Published var loadingState: LoadingState = .notLoaded

    private let wordsLoaderService: WordsLoaderServiceProtocol
    private var cancellable = Set<AnyCancellable>()
    private var cachedDictionary = [Character: [String]]()

    init(wordsLoaderService: WordsLoaderServiceProtocol) {
        self.wordsLoaderService = wordsLoaderService
        subscribeToLoadingState()
    }
}

private extension DictionaryViewModel {
    func subscribeToLoadingState() {
        wordsLoaderService.loadingStatePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                self?.loadingState = state
                if case let .loaded(eDictionary) = state {
                    self?.cachedDictionary = eDictionary
                }
            }.store(in: &cancellable)
    }

    @MainActor func updateLoadingState(_ state: LoadingState) async {
        loadingState = state
    }
}

extension DictionaryViewModel: DictionaryViewModelProtocol {
    func refreshDictionary() async {
        //TODO: Ask service to refetch dictionary.
    }

    func search(for query: String) async {
        guard !query.isEmpty else {
            await updateLoadingState(.loaded(eDictionary: cachedDictionary))
            return
        }
        var resultDictionary = [Character: [String]]()

        // Loop through each entry in the dictionary
        for (key, words) in cachedDictionary {
            // Filter words containing the query substring
            let filteredWords = words.filter { $0.contains(query.lowercased()) }
            if !filteredWords.isEmpty {
                resultDictionary[key] = filteredWords
            }
        }
        await updateLoadingState(.loaded(eDictionary: resultDictionary))
    }
}
