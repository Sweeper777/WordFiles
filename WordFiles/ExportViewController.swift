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
        
        form +++ ButtonRow() {
            row in
            row.title = "Export to PDF"
        }.onCellSelection({ (cell, row) in
            let attributedString = AttributedStringExporter(options: [.includeSentences, .includeWords]).attributedStringFromAppData()
            let data = AttributedTextToPDFConverter().pdfWithText(attributedString)
            do {
                let url = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("test.pdf")
                try data.write(to: url, options: .atomic)
                print("Written PDF file to \(url)")
            } catch {
                print(error)
            }
        })
    }
}

let tagWords = "words"
