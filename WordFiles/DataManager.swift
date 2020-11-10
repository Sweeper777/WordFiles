import RealmSwift
import SwiftyUtils

class DataManager {
    let wordEntries: Results<WordEntry>
    let realm: Realm!

    private init() {
        do {
            realm = try Realm()
            wordEntries = realm.objects(WordEntry.self)
        } catch let error {
            print(error)
            fatalError()
        }
    }

    private static var _shared: DataManager?

    static var shared: DataManager {
        _shared = _shared ?? DataManager()
        return _shared!
    }

    func addWordEntry(_ wordEntry: WordEntry) throws {
        try validWordEntry(wordEntry: wordEntry)
        try realm.write {
            realm.add(wordEntry)
        }
    }

    private func validWordEntry(wordEntry: WordEntry) throws {
        if wordEntry.title.trimmed().isEmpty {
            throw DataError.emptyWord
        } else if wordEntry.explanation.trimmed().isEmpty && wordEntry.example.trimmed().isEmpty{
            throw DataError.noExplanationOrExample
        } else if wordEntries.filter("title == %@", wordEntry.title).count > 0 {
            throw DataError.duplicateWord
        }
    }

    func deleteWordEntry(_ wordEntry: WordEntry) throws {
        try realm.write {
            realm.delete(wordEntry)
        }
    }

    func updateWordEntry(_ wordEntry: WordEntry, block: (WordEntry) -> Void) throws {
        try realm.write {
            block(wordEntry)
            try validWordEntry(wordEntry: wordEntry)
        }
    }

    func entriesFulfillingSearchTerm(_ searchTerm: String) -> Results<WordEntry> {
        wordEntries.filter("title CONTAINS[c] %@", searchTerm)
    }
}

enum DataError : Error {
    case duplicateWord
    case emptyWord
    case noExplanationOrExample
}