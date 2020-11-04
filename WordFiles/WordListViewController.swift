import UIKit
import RealmSwift
import SCLAlertView

class WordListViewController : UITableViewController {
    var words: Results<WordEntry>!

    override func viewDidLoad() {
        words = DataManager.shared.wordEntries
        tableView.allowsSelectionDuringEditing = true
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

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        do {
            try DataManager.shared.deleteWordEntry(words[indexPath.row])
            tableView.deleteRows(at: [indexPath], with: .automatic)
        } catch {
            SCLAlertView().showError("Error", subTitle: "An unknown error has occurred.", closeButtonTitle: "OK")
        }
    }

    @IBAction func addTapped() {
        performSegue(withIdentifier: "showWordEditor", sender: nil)
    }

    @IBAction func unwindFromWordEditor(_ segue: UIStoryboardSegue) {
        tableView.reloadData()
    }
}
