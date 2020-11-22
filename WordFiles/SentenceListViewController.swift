import UIKit
import RealmSwift
import TagsPanelView

class SentenceListViewController : UITableViewController {
    var sentences: Results<SentenceEntry>!

    override func viewDidLoad() {
        sentences = DataManager.shared.sentenceEntries
        tableView.register(UINib(nibName: "SentenceCell", bundle: nil), forCellReuseIdentifier: "cell")
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sentences.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SentenceCell
        cell.prepareForReuse()
        cell.sentenceLabel.text = sentences[indexPath.row].sentence
        cell.tagsView.tagArray = sentences[indexPath.row].tags.map(\.name)
        cell.tagsView.tagTextColor = .black
        cell.tagsView.tagsBackgroundColorsArray = Array(repeating: UIColor(named: "tagBackground")!, count: cell.tagsView.tagArray.count)
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let entry = sentences[indexPath.row]
        let maxSize = CGSize(width: tableView.width - 16, height: .greatestFiniteMagnitude)
        let sentence = entry.sentence
        let sentenceHeight = (sentence as NSString)
                                .boundingRect(with: maxSize,
                                              options: [.usesLineFragmentOrigin],
                                              attributes: [.font: UIFont.systemFont(ofSize: 17)],
                                              context: nil)
                                .height
        let tagsHeight = TagsPanelView.generatePanelHeightThatFit(maxSize, tags: entry.tags.map(\.name), fontSize: 17)
        return sentenceHeight + tagsHeight + 32
    }

    @IBAction func newSentenceTapped() {
        performSegue(withIdentifier: "showSentenceEditor", sender: nil)
    }

    @IBAction func unwindFromSentenceEditor(_ segue: UIStoryboardSegue) {
        tableView.reloadData()
    }
}
