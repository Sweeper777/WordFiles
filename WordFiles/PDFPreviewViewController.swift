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
        let shareSheet = UIActivityViewController(activityItems: [url], applicationActivities: [Foo()])
        shareSheet.popoverPresentationController?.barButtonItem = shareButton
        present(shareSheet, animated: true, completion: nil)
    }
}

class Foo: UIActivity {
    override var activityTitle: String? { "Foo" }
    override var activityType: UIActivity.ActivityType? { UIActivity.ActivityType("Foo") }
    override var activityImage: UIImage? { UIImage(systemName: "doc.on.doc.fill") }
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        true
    }
    override class var activityCategory: UIActivity.Category { .share }
    override func prepare(withActivityItems activityItems: [Any]) {
        print("Preparing Foo!")
    }
    override func perform() {
        print("Performed Foo!")
    }
}
