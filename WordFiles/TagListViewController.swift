import UIKit
import RealmSwift

class TagListViewController : UITableViewController {

    var tags: Results<Tag>!

    override func viewDidLoad() {
        tags = DataManager.shared.tags
    }

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

}
