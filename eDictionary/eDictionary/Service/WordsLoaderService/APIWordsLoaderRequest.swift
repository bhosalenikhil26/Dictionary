//
//  APIWordsLoaderRequest.swift
//  eDictionary
//
//  Created by Nikhil Bhosale on 2024-06-02.
//

import Foundation

enum APIWordsLoaderRequest: APIRequest {
    case loadWords(url: String)

    var baseURLPath: String {
        switch self {
        case .loadWords: return ""
        }
    }

    var path: String {
        switch self {
        case .loadWords(let url): return url
        }
    }

    var method: HTTPMethod {
        switch self {
        case .loadWords: return .get
        }
    }

    var queryParameters: [String: String]? {
        switch self {
        case .loadWords: return nil
        }
    }
}
