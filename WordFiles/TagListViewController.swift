import UIKit
import RealmSwift

protocol TagProtocol {
    var name: String { get }
}

extension WordTag : TagProtocol {}
extension SentenceTag : TagProtocol {}

protocol TagFilterableViewController : UIViewController {
    var tagFilter: String? { get set }
}

extension SentenceListViewController : TagFilterableViewController {}
extension WordListViewController : TagFilterableViewController {}

protocol TagListViewControllerDelegate : class {
    func tagListViewControllerWillDismiss(tagListVC: TagListViewController)
}

class TagListViewController : UITableViewController {

    weak var delegate: TagListViewControllerDelegate?

    var tags: LazyCollection<AnyCollection<TagProtocol>>!
    var secondarySegue = ""

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tags.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = tags[AnyIndex(indexPath.row)].name
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: secondarySegue, sender: tags[AnyIndex(indexPath.row)].name)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? TagFilterableViewController,
            let tag = sender as? String {
            vc.tagFilter = tag
        }
    }

    @IBAction func doneTapped() {
        delegate?.tagListViewControllerWillDismiss(tagListVC: self)
        dismiss(animated: true)
    }
}
