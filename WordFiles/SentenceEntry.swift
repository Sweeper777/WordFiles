import RealmSwift

class SentenceEntry : Object {
    @objc dynamic var sentence = ""
    let tags = List<SentenceTag>()
    @objc dynamic var date = Date()
}

class SentenceTag : Object {
    @objc dynamic var name = ""
    let sentences = LinkingObjects(fromType: SentenceEntry.self, property: "tags")

    override class func primaryKey() -> String? {
        "name"
    }
}
