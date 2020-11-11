import UIKit
import RealmSwift

class SentenceListViewController : UITableViewController {
    var sentences: Results<SentenceEntry>!

    override func viewDidLoad() {
        sentences = DataManager.shared.sentenceEntries
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
