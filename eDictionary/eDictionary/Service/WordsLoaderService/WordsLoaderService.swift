//
//  WordsLoaderService.swift
//  eDictionary
//
//  Created by Nikhil Bhosale on 2024-06-02.
//

import Foundation

enum WordsLoaderServiceError: Error {
    case stringConversionError
    case failedToLoadWords
}

protocol WordsLoaderServiceProtocol {
    func loadWords() async throws
}

final class WordsLoaderService {
    private let apiWordsLoaderService: APIWordsLoaderServiceProtocol

    init(apiWordsLoaderService: APIWordsLoaderServiceProtocol) {
        self.apiWordsLoaderService = apiWordsLoaderService
    }
}

extension WordsLoaderService: WordsLoaderServiceProtocol {
    func loadWords() async throws {
        do {
            let dictionaryData = try await apiWordsLoaderService.loadWords(from: dictionaryUrlString)
            guard let dictionaryText = String(data: dictionaryData, encoding: .utf8) else { throw WordsLoaderServiceError.stringConversionError }
            print(dictionaryText)
            //Store dictionary in database.
        } catch {
            //Handle specific error if needed
            throw WordsLoaderServiceError.failedToLoadWords
        }
    }
}

private extension WordsLoaderService {
    var dictionaryUrlString: String {
        "https://raw.githubusercontent.com/dwyl/english-words/master/words_alpha.txt"
    }
}
