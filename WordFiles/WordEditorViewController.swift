import Eureka
import SCLAlertView

class WordEditorViewController : FormViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        form +++ TextRow(tagTitle) { row in
            row.title = "Title"
            row.value = ""
        }

}

let tagTitle = "title"
let tagExplanation = "explanation"
let tagExample = "example"