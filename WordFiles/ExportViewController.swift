import UIKit
import Eureka
import SwiftyUtils
import PDFKit

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
            self.exportClick()
        })
    }
    
    func exportClick() {
        let values = form.values()
        let bools = [values[tagWords] as? Bool ?? false, values[tagSentence] as? Bool ?? false]
        let rawValue = (0..<2).map { bools[$0] ? 1 << $0 : 0 }.reduce(0, +)
        let option = AttributedStringExporter.Options(rawValue: rawValue)
        let attrStr = AttributedStringExporter(options: option).attributedStringFromAppData()
        let data = AttributedTextToPDFConverter().pdfWithText(attrStr)
        let pdfDocument = PDFDocument(data: data)
        performSegue(withIdentifier: "showPDF", sender: pdfDocument)
    }
    
}

let tagWords = "words"
