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
        let includeWords = values[tagWords] as? Bool ?? false
        let includeSentences = values[tagSentence] as? Bool ?? false
        let exporter = AttributedStringExporter()
        let pdfConverter = AttributedTextToPDFConverter()
        if includeWords {
            pdfConverter.addNewPage(withText: exporter.exportWords())
        }
        if includeSentences {
            pdfConverter.addNewPage(withText: exporter.exportSentences())
        }
        let pdfDocument = PDFDocument(data: pdfConverter.pdfData())
        performSegue(withIdentifier: "showPDF", sender: pdfDocument)
    }
    
}

let tagWords = "words"
