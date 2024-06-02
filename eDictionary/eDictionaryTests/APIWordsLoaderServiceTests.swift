//
//  APIWordsLoaderServiceTests.swift
//  eDictionaryTests
//
//  Created by Nikhil Bhosale on 2024-06-02.
//

import XCTest
@testable import eDictionary

final class APIWordsLoaderServiceTests: XCTestCase {
    private var apiService: APIWordsLoaderService!
    private var mockDispatcher: MockDispatcher!

    override func setUpWithError() throws {
        mockDispatcher = MockDispatcher()
        apiService = APIWordsLoaderService(dispatcher: mockDispatcher)
    }

    override func tearDownWithError() throws {
        mockDispatcher = nil
        apiService = nil
    }

    func testLoadWords_whenStatusCodeIsNotOk_shouldThrowStatusCodeNotHandledError() async {
        let data = Data()
        let urlResponse = HTTPURLResponse(url: URL(string: "test")!,
                                          statusCode: 400,
                                          httpVersion: nil,
                                          headerFields: nil)
        mockDispatcher.executeResponse = (data, urlResponse)

        do {
            let loadWordsData = try await apiService.loadWords(from: "urlToLoadWords")

        } catch let error as APIError {
            XCTAssertTrue(error == APIError.statusCodeNotHandled)
        } catch {
            XCTFail()
        }
    }

    func testLoadWords_whenDataIsEmpty_shouldEmptyDataError() async {
        let urlResponse = HTTPURLResponse(url: URL(string: "test")!,
                                          statusCode: 200,
                                          httpVersion: nil,
                                          headerFields: nil)
        mockDispatcher.executeResponse = (nil, urlResponse)

        do {
            let loadWordsData = try await apiService.loadWords(from: "urlToLoadWords")

        } catch let error as APIError {
            XCTAssertTrue(error == APIError.emptyData)
        } catch {
            XCTFail()
        }
    }

    func testLoadWords_whenStatusCodeIsOkAndDataIsPresent_shouldReturnData() async {
        let data = Data()
        let urlResponse = HTTPURLResponse(url: URL(string: "test")!,
                                          statusCode: 200,
                                          httpVersion: nil,
                                          headerFields: nil)
        mockDispatcher.executeResponse = (data, urlResponse)
        do {
            let loadWordsData = try await apiService.loadWords(from: "urlToLoadWords")
            XCTAssertEqual(loadWordsData, data)
        } catch {
            XCTFail()
        }
    }
}
