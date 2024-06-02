//
//  PersisterService.swift
//  eDictionary
//
//  Created by Nikhil Bhosale on 2024-06-02.
//

import Foundation
import SQLite

protocol PersisterServiceProtocol {
    func persistWord(_ wordString: String)
    func deleteWord(_ word: String)
    func removePersistedData()
    func fetchWords(startingWith letter: Character) -> [String]
}

enum PersisterError: Error {
    case failedToConnectToDatabase
    case failedToCreateTable
}

final class SQLitePersister {
    private var database: Connection?

    init?() {
        do {
            try setupDatabase()
            try createTablesForAllAlphabets()
        } catch {
            return nil
        }
    }
}

private extension SQLitePersister {
    func setupDatabase() throws {
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("eDictionary").appendingPathExtension("sqlite3")
            database = try Connection(fileUrl.path)
        } catch {
            print("Failed to connect to the database: \(error)")
            throw PersisterError.failedToConnectToDatabase
        }
    }

    func createTablesForAllAlphabets() throws {
        let alphabet = "abcdefghijklmnopqrstuvwxyz"

        for letter in alphabet {
            try createTable(for: letter)
        }
    }

    func createTable(for letter: Character) throws {
        guard let database else {
            throw PersisterError.failedToConnectToDatabase
        }

        let tableName = "words_\(letter)"
        let wordsTable = Table(tableName)
        let id = Expression<Int64>("id")
        let word = Expression<String>("word")

        do {
            try database.run(wordsTable.create(ifNotExists: true) { table in
                table.column(id, primaryKey: true)
                table.column(word, unique: true)
            })
        } catch {
            print("Failed to create table for \(letter): \(error)")
            throw PersisterError.failedToCreateTable
        }
    }
}

extension SQLitePersister: PersisterServiceProtocol {
    func persistWord(_ wordString: String) {
        guard let database, let firstLetter = wordString.first else { return }

        let tableName = "words_\(firstLetter.lowercased())"
        let wordsTable = Table(tableName)
        let word = Expression<String>("word")

        let insert = wordsTable.insert(word <- wordString)
        do {
            try database.run(insert)
        } catch {
            print("Insertion failed for \(wordString): \(error)")
        }
    }

    func deleteWord(_ word: String) {}
    func removePersistedData() {}
    func fetchWords(startingWith letter: Character) -> [String] { [] }
}
