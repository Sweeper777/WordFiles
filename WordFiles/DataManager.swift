import RealmSwift
import SwiftyUtils

class DataManager {
    let wordEntries: Results<WordEntry>
    let sentenceEntries: Results<SentenceEntry>
    let tags: Results<Tag>
    let realm: Realm!

    private init() {
        do {
            realm = try Realm()
            wordEntries = realm.objects(WordEntry.self).sorted(byKeyPath: "title")
            sentenceEntries = realm.objects(SentenceEntry.self).sorted(byKeyPath: "sentence")
            tags = realm.objects(Tag.self).sorted(byKeyPath: "name")
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
        try validateWordEntry(wordEntry)
        try realm.write {
            realm.add(wordEntry)
        }
    }


    func validateSentenceEntry(_ sentenceEntry: SentenceEntry) throws {
        if sentenceEntry.sentence.trimmed().isEmpty {
            throw SentenceError.emptySentence
        } else if sentenceEntries.filter("sentence == %@", sentenceEntry.sentence).count > 0 {
            throw SentenceError.duplicateSentence
        } else {
            let tags = sentenceEntry.tags.map(\.name)
            if Set(tags).count != tags.count {
                throw SentenceError.duplicateTags
            }
        }
    }

    private func validateWordEntry(_ wordEntry: WordEntry) throws {
        if wordEntry.title.trimmed().isEmpty {
            throw WordError.emptyWord
        } else if wordEntry.explanation.trimmed().isEmpty && wordEntry.example.trimmed().isEmpty{
            throw WordError.noExplanationOrExample
        } else if wordEntries.filter("title == %@", wordEntry.title).count > 0 {
            throw WordError.duplicateWord
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
            try validateWordEntry(wordEntry)
        }
    }

    func entriesFulfillingSearchTerm(_ searchTerm: String) -> Results<WordEntry> {
        wordEntries.filter("title CONTAINS[c] %@", searchTerm)
    }
}

enum WordError: Error {
    case duplicateWord
    case emptyWord
    case noExplanationOrExample
}

enum SentenceError: Error {
    case duplicateSentence
    case emptySentence
    case duplicateTags
}