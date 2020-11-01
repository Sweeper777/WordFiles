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
        if wordEntry.title.trimmed().isEmpty {
            throw DataError.emptyWord
        } else if wordEntry.explanation.trimmed().isEmpty {
            throw DataError.noExplanation
        }
        try realm.write {
            realm.add(wordEntry)
        }
    }
}

enum DataError : Error {
    case duplicateWord
    case emptyWord
    case noExplanation
}