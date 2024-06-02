//
//  APIServiceResponseTests.swift
//  eDictionaryTests
//
//  Created by Nikhil Bhosale on 2024-06-02.
//

import XCTest
@testable import eDictionary

final class APIServiceResponseTests: XCTestCase {

    override func setUpWithError() throws {
        try? super.setUpWithError()
    }

    override func tearDownWithError() throws {
        try? super.tearDownWithError()
    }

    func testParse_whenDataIsPlainString_shouldReturnAppropriateString() {
        let response = APIServiceResponse(statusCode: .ok, data: plainStringData)
        do {
            let decodedObject: String = try response.parse()
            XCTAssertEqual(decodedObject, "test")
        } catch {
            XCTFail()
        }
    }

    func testParse_whenDataIsJsonObject_shouldReturnProperDecodedObject() {
        let response = APIServiceResponse(statusCode: .ok, data: jsonObject)
        do {
            let decodedObject: JsonObject = try response.parse()
            XCTAssertEqual(decodedObject.data.availability, "available")
        } catch {
            XCTFail()
        }
    }

    func testParse_whenDataIsJsonObjectWithSnakeCaseKeys_shouldReturnProperDecodedObject() {
        let response = APIServiceResponse(statusCode: .ok, data: jsonObjectWithSnakeCase)
        do {
            let decodedObject: JsonObjectWithSnakeCase = try response.parse(with: .convertFromSnakeCase)
            XCTAssertEqual(decodedObject.data, "data")
            XCTAssertEqual(decodedObject.maxUses, 0)
        } catch {
            XCTFail()
        }
    }

    func testParse_whenDataIsDecodedToWrongObject_shouldThrowError() {
        let response = APIServiceResponse(statusCode: .ok, data: jsonObjectWithSnakeCase)
        do {
            let _: JsonObjectWithSnakeCase = try response.parse()
            XCTFail()
        } catch {}
    }

    private var plainStringData: Data {
        "test".data(using: .utf8)!
    }

    var jsonObject: Data {
        """
        {
        "data": {
            "availability": "available"
        }
      }
    """.data(using: .utf8)!
    }

    var jsonObjectWithSnakeCase: Data {
        """
        {
         "data": "data",
         "max_uses": 0
        }
        """.data(using: .utf8)!
    }
}

private struct JsonObject: Decodable {
    let data: JsonObject.Data

    struct Data: Decodable {
        let availability: String
    }
}

private struct JsonObjectWithSnakeCase: Decodable {
    let data: String
    let maxUses: Int
}
