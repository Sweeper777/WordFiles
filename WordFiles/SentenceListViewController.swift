import UIKit
import RealmSwift
import TagsPanelView

class SentenceListViewController : UITableViewController {
//    var sentences: Results<SentenceEntry>!
    var sentences = {
        () -> [SentenceEntry] in
        let sentence1 = SentenceEntry()
        sentence1.sentence = "If builders built buildings the way programmers wrote programs, then the first woodpecker that came along, would destroy civilisation."
        let tag1 = Tag()
        tag1.name = "quotes"
        let tag2 = Tag()
        tag2.name = "programmers"
        sentence1.tags.append(objectsIn: [tag1, tag2])
        let sentence2 = SentenceEntry()
        sentence2.sentence = "All models are wrong. Some are useful"
        let tag3 = Tag()
        tag3.name = "statistics"
        let tag4 = Tag()
        tag4.name = "models"
        let tag5 = Tag()
        tag5.name = "truth"
        sentence2.tags.append(objectsIn: [tag3, tag4, tag5])
        return [sentence1, sentence2]
    }()

    override func viewDidLoad() {
//        sentences = DataManager.shared.sentenceEntries
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sentences.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = sentences[indexPath.row].sentence
        return cell
    }
}
