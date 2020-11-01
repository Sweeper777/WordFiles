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

let tagTitle = "title"
let tagExplanation = "explanation"
let tagExample = "example"