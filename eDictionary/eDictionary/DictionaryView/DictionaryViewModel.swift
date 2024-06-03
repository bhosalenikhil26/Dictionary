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
}

final class DictionaryViewModel {
    @Published var loadingState: LoadingState = .notLoaded

    private let wordsLoaderService: WordsLoaderServiceProtocol
    private var cancellable = Set<AnyCancellable>()

    init(wordsLoaderService: WordsLoaderServiceProtocol) {
        self.wordsLoaderService = wordsLoaderService
        subscribeToLoadingState()
    }
}

private extension DictionaryViewModel {
    func subscribeToLoadingState() {
        wordsLoaderService.loadingStatePublisher
            .receive(on: RunLoop.main)
            .assign(to: &$loadingState)
    }
}

extension DictionaryViewModel: DictionaryViewModelProtocol {
    func refreshDictionary() async {
        //TODO: Ask service to refetch dictionary.
    }
}
