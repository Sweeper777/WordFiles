import UIKit
import PDFKit

class PDFPreviewViewController : UIViewController {
    var document: PDFDocument!
    @IBOutlet var shareButton: UIBarButtonItem!

    override func viewDidLoad() {
        let pdfView = PDFView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        self.view = pdfView
        pdfView.document = document
        pdfView.autoScales = true
        title = "Preview"
    }
    
    @IBAction func shareClick() {
        
    }
}
