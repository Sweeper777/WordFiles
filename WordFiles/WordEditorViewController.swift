import Eureka
import SCLAlertView

class WordEditorViewController : FormViewController {
    var entryToEdit: WordEntry?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let entryTitle = entryToEdit?.title {
            title = "Editing '\(entryTitle)'"
        } else {
            title = "New Entry"
        }

        form +++ TextRow(tagTitle) { row in
            row.title = "Title"
            row.value = entryToEdit?.title
        }

        form +++ Section("explanation")
        <<< TextAreaRow(tagExplanation) { row in
            row.value = entryToEdit?.explanation
        }

        form +++ Section("example")
        <<< TextAreaRow(tagExample) { row in
            row.value = entryToEdit?.example
        }
    }

    func showError(_ msg: String) {
        SCLAlertView().showError("Error", subTitle: msg, closeButtonTitle: "OK")
    }

    @IBAction func doneTapped() {
        let values = form.values()
        let wordEntry = WordEntry()
        wordEntry.title = values[tagTitle] as? String ?? ""
        wordEntry.explanation = values[tagExplanation] as? String ?? ""
        wordEntry.example = values[tagExample] as? String ?? ""
        do {
            try DataManager.shared.addWordEntry(wordEntry)
            performSegue(withIdentifier: "unwindToWordList", sender: nil)
        } catch DataError.duplicateWord {
            showError("An entry with the same title already exists!")
        } catch DataError.noExplanation {
            showError("Please enter an explanation!")
        } catch DataError.emptyWord {
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