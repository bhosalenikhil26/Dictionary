//
//  APIWordsLoaderService.swift
//  eDictionary
//
//  Created by Nikhil Bhosale on 2024-06-02.
//

import Foundation

protocol APIWordsLoaderServiceProtocol {
    func loadWords(from url: String) async throws -> Data
}

final class APIWordsLoaderService: APIServiceProtocol {
    var dispatcher: APIRequestDispatcherProtocol

    init(dispatcher: APIRequestDispatcherProtocol) {
        self.dispatcher = dispatcher
    }
}

extension APIWordsLoaderService: APIWordsLoaderServiceProtocol {
    func loadWords(from url: String) async throws -> Data {
        let apiRequest = APIWordsLoaderRequest.loadWords(url: url)

        let result = try await performRequest(apiRequest)
        guard result.statusCode != .ok else {
            guard let data = result.data else { throw APIError.emptyData }
            return data
        }

        throw APIError.statusCodeNotHandled
    }
}
