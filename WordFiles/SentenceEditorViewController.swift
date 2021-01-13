import UIKit
import Eureka
import SCLAlertView
import SuggestionRow

class SentenceEditorViewController : FormViewController {
    var sentenceToEdit: SentenceEntry?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let _ = sentenceToEdit?.sentence {
            title = "Editing Sentence"
        } else {
            title = "New Sentence"
        }

        tableView.setEditing(true, animated: false)

        form +++ Section("sentence")
        <<< TextAreaRow(tagSentence) { row in
            row.value = sentenceToEdit?.sentence ?? ""
        }

        form +++ MultivaluedSection(multivaluedOptions: [.Delete, .Insert, .Reorder], header: "tags") {
            $0.addButtonProvider = { section in
                ButtonRow {
                    $0.title = "New Tag"
                }
            }
            $0.multivaluedRowToInsertAt = { index in
                SuggestionAccessoryRow<String> {
                    $0.placeholder = "Tag Name"
                    $0.filterFunction = {
                        input in
                        DataManager.shared.tags.filter("name CONTAINS[c] %@", input).map(\.name)
                    }
                }.cellSetup { (cell, row) in
                    cell.textField.autocapitalizationType = .none
                }
            }
            $0.tag = tagTags

            for tag in (sentenceToEdit?.tags).map(Array.init) ?? [] {
                $0 <<< SuggestionAccessoryRow<String> {
                    $0.placeholder = "Tag Name"
                    $0.filterFunction = {
                        input in
                        DataManager.shared.tags.filter("name CONTAINS[c] %@", input).map(\.name)
                    }
                    $0.value = tag.name
                }.cellSetup { (cell, row) in
                    cell.textField.autocapitalizationType = .none
                }
            }
        }
    }

    func showError(_ msg: String) {
        SCLAlertView().showError("Error", subTitle: msg, closeButtonTitle: "OK")
    }

    @IBAction func doneTapped() {
        let values = form.values()
        let sentence = values[tagSentence] as? String ?? ""
        let tags = (values[tagTags] as? [Any] ?? []).compactMap { $0 as? String }
        let sentenceEntry = SentenceEntry()
        sentenceEntry.sentence = sentence
        for tag in tags {
            let tagObject = SentenceTag()
            tagObject.name = tag
            sentenceEntry.tags.append(tagObject)
        }
        do {
            if let sentenceToEdit = self.sentenceToEdit {
                try DataManager.shared.updateSentenceEntry(sentenceToEdit, to: sentenceEntry)
            } else {
                try DataManager.shared.addSentenceEntry(sentenceEntry)
            }
            performSegue(withIdentifier: "unwindToSentenceList", sender: nil)
        } catch SentenceError.emptySentence {
            showError("Please enter a sentence!")
        } catch SentenceError.duplicateSentence {
            showError("You have already added this sentence!")
        } catch SentenceError.duplicateTags {
            showError("You cannot add the same tag multiple times!")
        } catch {
            showError("An unknown error occurred!")
        }
    }

    @IBAction func cancelTapped() {
        dismiss(animated: true)
    }
}

let tagSentence = "sentence"
let tagTags = "tags"
