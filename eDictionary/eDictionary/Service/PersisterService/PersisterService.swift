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
    func removeWordFromDictionary(_ word: String)
    func removePersistedData()
    func fetchWords() -> [Character: [String]]
    func isDataPresent() -> Bool
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
        for letter in String.alphabet {
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

    func isTableNonEmpty(for letter: Character) -> Bool {
        guard let database else { return false }

        let tableName = "words_\(letter)"
        let wordsTable = Table(tableName)

        do {
            let count = try database.scalar(wordsTable.count)
            return count > 0
        } catch {
            print("Failed to check rows in table \(tableName): \(error)")
            return false
        }
    }

    func getWordsFromTable(for letter: Character) -> [String] {
        guard let database else { return [] }
        let tableName = "words_\(letter)"
        let wordsTable = Table(tableName)
        let word = Expression<String>("word")

        do {
            let query = wordsTable.select(word)
            let fetchedWords = try database.prepare(query).map { row in
                return row[word]
            }
            return Array(fetchedWords.dropFirst())
        } catch {
            print("Failed to fetch words starting with \(letter): \(error)")
            return []
        }
    }

    func deleteWord(_ word: String) {
        guard let database, let firstLetter = word.first else { return }
        let tableName = "words_\(firstLetter)"
        let wordsTable = Table(tableName)
        let word = Expression<String>("word")

        let deleteQuery = wordsTable.filter(word == word).delete()
        do {
            try database.run(deleteQuery)
            print("Deleted word \(word) from table \(tableName).")
        } catch {
            print("Failed to delete word \(word) from table \(tableName): \(error)")
        }
    }

    func dropTable(for letter: Character) {
        guard let database else { return }

        let tableName = "words_\(letter)"
        let dropTableQuery = "DROP TABLE IF EXISTS \(tableName)"

        do {
            try database.run(dropTableQuery)
            print("Dropped table \(tableName).")
        } catch {
            print("Failed to drop table \(tableName): \(error)")
        }
    }
}

extension SQLitePersister: PersisterServiceProtocol {
    func persistWord(_ wordString: String) {
        guard let database, let firstLetter = wordString.first else { return }

        let tableName = "words_\(firstLetter)"
        let wordsTable = Table(tableName)
        let word = Expression<String>("word")

        let insert = wordsTable.insert(word <- wordString)
        do {
            try database.run(insert)
        } catch {
            print("Insertion failed for \(wordString): \(error)")
        }
    }

    func removeWordFromDictionary(_ word: String) {
        deleteWord(word)
    }

    func removePersistedData() {
        for letter in String.alphabet {
            dropTable(for: letter)
        }
    }

    func fetchWords() -> [Character: [String]] {
        var eDictionary = [Character: [String]]()

        for letter in String.alphabet {
            eDictionary[letter] = getWordsFromTable(for: letter)
        }
        return eDictionary
    }

    func isDataPresent() -> Bool {
        for letter in String.alphabet {
            if isTableNonEmpty(for: letter) {
                return true
            }
        }
        return false
    }
}

extension String {
    static let alphabet = "abcdefghijklmnopqrstuvwxyz"
}
