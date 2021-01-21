import UIKit
import RealmSwift

protocol TagProtocol {
    var name: String { get }
}



class TagListViewController : UITableViewController {


    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tags.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = tags[indexPath.row].name
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showSentencesWithTag", sender: tags[indexPath.row].name)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SentenceListViewController,
            let tag = sender as? String {
            vc.tagFilter = tag
        }
    }

    @IBAction func doneTapped() {
        dismiss(animated: true)
    }
}
