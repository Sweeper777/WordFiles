import UIKit
import Eureka
import SCLAlertView

class SentenceEditorViewController : FormViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.setEditing(true, animated: false)

        form +++ Section("sentence")
        <<< TextAreaRow(tagSentence) { row in
            row.value = ""
        }

        form +++ MultivaluedSection(multivaluedOptions: [.Delete, .Insert, .Reorder], header: "tags") {
            $0.addButtonProvider = { section in
                ButtonRow {
                    $0.title = "New Tag"
                }
            }
        }
    }
}

let tagSentence = "sentence"
let tagTags = "tags"