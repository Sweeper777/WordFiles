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
            $0.multivaluedRowToInsertAt = { index in
                TextRow {
                    $0.placeholder = "Tag Name"
                }.cellSetup { (cell, row) in
                    cell.textField.autocapitalizationType = .none
                }
            }
            $0.tag = tagTags
        }
    }

    func showError(_ msg: String) {
        SCLAlertView().showError("Error", subTitle: msg, closeButtonTitle: "OK")
    }

    @IBAction func doneTapped() {
    }

    @IBAction func cancelTapped() {
        dismiss(animated: true)
    }
}

let tagSentence = "sentence"
let tagTags = "tags"