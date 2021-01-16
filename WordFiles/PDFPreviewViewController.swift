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
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("WordFiles.pdf")
        document.write(to: url)
        let shareSheet = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        shareSheet.popoverPresentationController?.barButtonItem = shareButton
        present(shareSheet, animated: true, completion: nil)
    }
}
