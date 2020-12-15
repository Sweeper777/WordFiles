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
            print(realm.configuration.fileURL!)
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

    func addSentenceEntry(_ sentenceEntry: SentenceEntry) throws {
        try validateSentenceEntry(sentenceEntry)
        let newSentenceEntry = SentenceEntry()
        newSentenceEntry.sentence = sentenceEntry.sentence
        for tag in sentenceEntry.tags {
            if let existingTag = realm.object(ofType: Tag.self, forPrimaryKey: tag.name) {
                newSentenceEntry.tags.append(existingTag)
            } else {
                let newTag = Tag()
                newTag.name = tag.name
                newSentenceEntry.tags.append(newTag)
            }
        }
        try realm.write {
            realm.add(newSentenceEntry)
        }
    }

    private func validateSentenceEntry(_ sentenceEntry: SentenceEntry) throws {
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

    func deleteSentenceEntry(_ sentenceEntry: SentenceEntry) throws {
        try realm.write {
            let tags = Array(sentenceEntry.tags)
            realm.delete(sentenceEntry)
            for tag in tags {
                if tag.sentences.count == 0 {
                    realm.delete(tag)
                }
            }
        }
    }

    func updateWordEntry(oldWordEntry: WordEntry, newWordEntry: WordEntry) throws {
        try realm.write {
            do {
                try validateWordEntry(newWordEntry)
            } catch WordError.duplicateWord {
                if oldWordEntry.title != newWordEntry.title {
                    throw WordError.duplicateWord
                }
            }
            oldWordEntry.title = newWordEntry.title
            oldWordEntry.example = newWordEntry.example
            oldWordEntry.explanation = newWordEntry.explanation
        }
    }

    func updateSentenceEntry(_ sentenceEntry: SentenceEntry, to newSentenceEntry: SentenceEntry) throws {
        do {
            try validateSentenceEntry(newSentenceEntry)
        } catch SentenceError.duplicateSentence {
            if newSentenceEntry.sentence != sentenceEntry.sentence {
                throw SentenceError.duplicateSentence
            }
        }

        let oldTags = Array(sentenceEntry.tags)
        try realm.write {
            sentenceEntry.sentence = newSentenceEntry.sentence
            sentenceEntry.tags.removeAll()
            for tag in newSentenceEntry.tags {
                if let existingTag = realm.object(ofType: Tag.self, forPrimaryKey: tag.name) {
                    sentenceEntry.tags.append(existingTag)
                } else {
                    let newTag = Tag()
                    newTag.name = tag.name
                    sentenceEntry.tags.append(newTag)
                }
            }
            for oldTag in oldTags {
                if oldTag.sentences.count == 0 {
                    realm.delete(oldTag)
                }
            }
        }
    }

    func wordsMatchingSearchTerm(_ searchTerm: String) -> Results<WordEntry> {
        wordEntries.filter("title CONTAINS[c] %@", searchTerm)
    }

    func sentences(withTag tag: String? = nil, matchingSearchTerm searchTerm: String? = nil) -> Results<SentenceEntry>? {
        switch (tag, searchTerm) {
        case (let tag?, let searchTerm?):
            return realm.object(ofType: Tag.self, forPrimaryKey: tag)?.sentences.filter("sentence CONTAINS[c] %@", searchTerm)
        case (let tag?, nil):
            return realm.object(ofType: Tag.self, forPrimaryKey: tag)?.sentences.filter(NSPredicate(value: true))
        case (nil, let searchTerm?):
            return sentenceEntries.filter("sentence CONTAINS[c] %@", searchTerm)
        case (nil, nil):
            return sentenceEntries
        }
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
