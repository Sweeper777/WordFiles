import UIKit
import RealmSwift

class WordListViewController : UITableViewController {
    var words: Results<WordEntry>!

    override func viewDidLoad() {
        words = DataManager.shared.wordEntries

        navigationItem.rightBarButtonItems?.append(editButtonItem)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        words.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = words[indexPath.row].title
        return cell
    }

    @IBAction func addTapped() {
        performSegue(withIdentifier: "showWordEditor", sender: nil)
    }

    @IBAction func unwindFromWordEditor(_ segue: UIStoryboardSegue) {
        tableView.reloadData()
    }
}
