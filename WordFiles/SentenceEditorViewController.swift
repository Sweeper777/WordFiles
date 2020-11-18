import UIKit
import Eureka
import SCLAlertView

class SentenceEditorViewController : FormViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.setEditing(true, animated: false)

    }
}

let tagSentence = "sentence"
let tagTags = "tags"