import Eureka
import SCLAlertView
import SuggestionRow

class WordEditorViewController : FormViewController {
    var entryToEdit: WordEntry?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let entryTitle = entryToEdit?.title {
            title = "Editing '\(entryTitle)'"
        } else {
            title = "New Word"
        }
        
        tableView.setEditing(true, animated: false)

        form +++ TextRow(tagTitle) { row in
            row.title = "Title"
            row.value = entryToEdit?.title
        }.cellSetup {
            cell, row in
            cell.textField.autocapitalizationType = .none
        }

        form +++ Section("explanation")
        <<< TextAreaRow(tagExplanation) { row in
            row.value = entryToEdit?.explanation
        }

        form +++ Section("example")
        <<< TextAreaRow(tagExample) { row in
            row.value = entryToEdit?.example
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
                        DataManager.shared.wordTags.filter("name CONTAINS[c] %@", input).map(\.name)
                    }
                }.cellSetup { (cell, row) in
                    cell.textField.autocapitalizationType = .none
                }
            }
            $0.tag = tagTags

            for tag in (entryToEdit?.tags).map(Array.init) ?? [] {
                $0 <<< SuggestionAccessoryRow<String> {
                    $0.placeholder = "Tag Name"
                    $0.filterFunction = {
                        input in
                        DataManager.shared.sentenceTags.filter("name CONTAINS[c] %@", input).map(\.name)
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
        if let entryToUpdate = entryToEdit {
            updateEntry(entryToUpdate)
        } else {
            saveNewEntry()
        }
    }
    
    private func wordEntryFromFormValues() -> WordEntry {
        let values = form.values()
        let tags = (values[tagTags] as? [Any] ?? []).compactMap { $0 as? String }
        let wordEntry = WordEntry()
        wordEntry.title = values[tagTitle] as? String ?? ""
        wordEntry.explanation = values[tagExplanation] as? String ?? ""
        wordEntry.example = values[tagExample] as? String ?? ""
        for tag in tags {
            let tagObject = WordTag()
            tagObject.name = tag
            wordEntry.tags.append(tagObject)
        }
        return wordEntry
    }

    private func saveNewEntry() {
        let wordEntry = wordEntryFromFormValues()
        do {
            try DataManager.shared.addWordEntry(wordEntry)
            performSegue(withIdentifier: "unwindToWordList", sender: nil)
        } catch WordError.duplicateWord {
            showError("An entry with the same title already exists!")
        } catch WordError.noExplanationOrExample {
            showError("Please enter an explanation or example!")
        } catch WordError.emptyWord {
            showError("Please enter a title for this entry!")
        } catch {
            showError("An unknown error has occurred!")
            print(error)
        }
    }

    private func updateEntry(_ entryToUpdate: WordEntry) {
        let wordEntry = wordEntryFromFormValues()
        do {
            try DataManager.shared.updateWordEntry(oldWordEntry: entryToUpdate, newWordEntry: wordEntry)
            performSegue(withIdentifier: "unwindToWordList", sender: nil)
        } catch WordError.duplicateWord {
            showError("An entry with the same title already exists!")
        } catch WordError.noExplanationOrExample {
            showError("Please enter an explanation!")
        } catch WordError.emptyWord {
            showError("Please enter a title for this entry!")
        } catch {
            showError("An unknown error has occurred!")
            print(error)
        }
    }

    @IBAction func cancelTapped() {
        dismiss(animated: true)
    }
}

let tagTitle = "title"
let tagExplanation = "explanation"
let tagExample = "example"
