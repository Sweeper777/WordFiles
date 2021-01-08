import UIKit
import RealmSwift

struct AttributedStringExporter {
    struct Options: OptionSet {
        let rawValue: Int
        
        static let includeWords = Options(rawValue: 1 << 0)
        static let includeSentences = Options(rawValue: 1 << 1)
    }
    
    let options: Options
    
    private let alignLeft: NSParagraphStyle = {
        let mutableParaStyle = NSMutableParagraphStyle()
        mutableParaStyle.alignment = .left
        return mutableParaStyle
    }()
    
    private let alignCenter: NSParagraphStyle = {
        let mutableParaStyle = NSMutableParagraphStyle()
        mutableParaStyle.alignment = .center
        return mutableParaStyle
    }()
    
    private let boldFont = UIFont.monospacedSystemFont(ofSize: 11, weight: .bold)
    private let bigFont = UIFont.monospacedSystemFont(ofSize: 16, weight: .bold)
    private let regularFont = UIFont.monospacedSystemFont(ofSize: 11, weight: .regular)
    
    private var titleAttributes: [NSAttributedString.Key: Any] {
        [
            .font: bigFont,
            .paragraphStyle: alignCenter
        ]
    }
    
    private var headingsAttributes: [NSAttributedString.Key: Any] {
        [
            .font: boldFont,
            .paragraphStyle: alignLeft
        ]
    }
    
    private var bodyAttributes: [NSAttributedString.Key: Any] {
        [
            .font: regularFont,
            .paragraphStyle: alignLeft
        ]
    }
    
    private var tagsAttributes: [NSAttributedString.Key: Any] {
        [
            .font: regularFont,
            .paragraphStyle: alignLeft,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
    }
    
}
