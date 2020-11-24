import UIKit
import RealmSwift

class TagListViewController : UITableViewController {

    var tags: Results<Tag>!

    override func viewDidLoad() {
        tags = DataManager.shared.tags
    }


}
