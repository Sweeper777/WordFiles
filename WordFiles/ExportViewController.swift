import UIKit
import Eureka

class ExportViewController : FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form +++ Section("include")
            <<< SwitchRow(tagWords) {
                row in
                row.title = "Words"
                row.value = true
            }
        
            <<< SwitchRow(tagSentence) {
                row in
                row.title = "Sentences"
                row.value = true
            }
        
    }
}

let tagWords = "words"
