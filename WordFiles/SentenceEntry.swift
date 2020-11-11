import RealmSwift

class SentenceEntry : Object {
    @objc dynamic var sentence = ""
    let tags = List<Tag>()
}

class Tag : Object {
    @objc dynamic var name = ""
    let sentences = LinkingObjects(fromType: SentenceEntry.self, property: "tags")

    override class func primaryKey() -> String? {
        "name"
    }
}
