import RealmSwift

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

    public static var shared: DataManager {
        _shared = _shared ?? DataManager()
        return _shared!
    }
}
