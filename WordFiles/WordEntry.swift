import RealmSwift

class WordEntry : Object {
    @objc dynamic var title = ""
    @objc dynamic var explanation = ""
    @objc dynamic var example = ""
    
    let tags = List<WordTag>()
}

class WordTag : Object {
    @objc dynamic var name = ""
    let words = LinkingObjects(fromType: WordEntry.self, property: "tags")

    override class func primaryKey() -> String? {
        "name"
    }
}
