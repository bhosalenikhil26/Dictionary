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
    func removeWordFromDictionary(_ word: String)
}

final class WordsLoaderService {
    private let apiWordsLoaderService: APIWordsLoaderServiceProtocol
    private let persisterService: PersisterServiceProtocol?
    private var eDictionary: [Character: [String]] = [:]

    init(apiWordsLoaderService: APIWordsLoaderServiceProtocol, persisterService: PersisterServiceProtocol?) {
        self.apiWordsLoaderService = apiWordsLoaderService
        self.persisterService = persisterService
    }
}

extension WordsLoaderService: WordsLoaderServiceProtocol {
    func loadWords() async throws {
        if let persisterService {
            guard !persisterService.isDataPresent() else {
                eDictionary = persisterService.fetchWords()
                return
            }
        }

        do {
            let dictionaryData = try await apiWordsLoaderService.loadWords(from: dictionaryUrlString)
            guard let dictionaryText = String(data: dictionaryData, encoding: .utf8) else { throw WordsLoaderServiceError.stringConversionError }
            storeWordsInLocalPersister(dictionaryText)
        } catch {
            //Handle specific error if needed
            throw WordsLoaderServiceError.failedToLoadWords
        }
    }

    func removeWordFromDictionary(_ word: String) {
        persisterService?.removeWordFromDictionary(word)
    }
}

private extension WordsLoaderService {
    var dictionaryUrlString: String {
        "https://raw.githubusercontent.com/dwyl/english-words/master/words_alpha.txt"
    }

    func storeWordsInLocalPersister(_ dictionaryText: String) {
        let words = dictionaryText.split(separator: "\r\n").map(String.init)

        for word in words {
            if let firstLetter = word.first {
                if eDictionary[firstLetter] == nil {
                    eDictionary[firstLetter] = [word]
                } else {
                    eDictionary[firstLetter]?.append(word)
                }
            }
            if word.count > 1 {
                persisterService?.persistWord(word)
            }
        }
    }
}
