import Eureka
import SCLAlertView

class WordEditorViewController : FormViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        form +++ TextRow(tagTitle) { row in
            row.title = "Title"
            row.value = ""
        }

        form +++ Section("explanation")
        <<< TextAreaRow(tagExplanation) { row in
            row.value = ""
        }

        form +++ Section("example")
        <<< TextAreaRow(tagExample) { row in
            row.value = ""
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

let tagTitle = "title"
let tagExplanation = "explanation"
let tagExample = "example"