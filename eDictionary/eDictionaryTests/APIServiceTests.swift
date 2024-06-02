//
//  APIServiceTests.swift
//  eDictionaryTests
//
//  Created by Nikhil Bhosale on 2024-06-02.
//

import XCTest
@testable import eDictionary

final class APIServiceTests: XCTestCase {
    private var mockAPIRequest: MockAPIRequest!
    private var mockDispatcher: MockDispatcher!
    private var apiService: MockAPIService!

    override func setUpWithError() throws {
        mockAPIRequest = MockAPIRequest()
        mockDispatcher = MockDispatcher()
        apiService = MockAPIService(dispatcher: mockDispatcher)
    }

    override func tearDownWithError() throws {
        mockAPIRequest = nil
        mockDispatcher = nil
        apiService = nil
    }

    func testPerformRequest_whenHttpResponseIsNotPresent_shouldThrowInvalidHTTPURLResponseError() async {
        mockDispatcher.executeResponse = (nil, nil)

        do {
            _ = try await apiService.performRequest(mockAPIRequest)
            XCTFail()
        } catch let error as APIError {
            XCTAssertTrue(error == APIError.invalidHTTPURLResponse)
        } catch {
            XCTFail()
        }
    }

    func testPerformRequest_whenHttpResponseIsPresent_shouldAPIServiceResponseWithCorrectStatusCodeAndData() async {
        let data = Data()
        let urlResponse = HTTPURLResponse(url: URL(string: "test")!,
                                          statusCode: 200,
                                          httpVersion: nil,
                                          headerFields: nil)
        mockDispatcher.executeResponse = (data, urlResponse)
        do {
            let response = try await apiService.performRequest(mockAPIRequest)
            XCTAssertEqual(response.data, data)
        } catch {
            XCTFail()
        }
    }
}

private final class MockAPIRequest: APIRequest {
    var baseURLPath: String = ""
    var path: String = ""
    var method: eDictionary.HTTPMethod = .get
    var queryParameters: [String : String]?
}

private final class MockAPIService: APIServiceProtocol {
    var dispatcher: APIRequestDispatcherProtocol

    init(dispatcher: APIRequestDispatcherProtocol) {
        self.dispatcher = dispatcher
    }
}

final class MockDispatcher: APIRequestDispatcherProtocol {
    var executeResponse: (Data?, URLResponse?) = (nil, nil)
    func execute(apiRequest: APIRequest) async throws -> (Data?, URLResponse?) {
      return executeResponse
    }
}
