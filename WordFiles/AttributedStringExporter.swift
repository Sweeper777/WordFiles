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
    
    private var wordEntryAttributes: [NSAttributedString.Key: Any] {
        [
            .font: bigFont,
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
    
    func exportWords() -> NSMutableAttributedString {
        let words = DataManager.shared.wordEntries
        let str = NSMutableAttributedString()
        str.append(NSAttributedString(string: "Words\n\n", attributes: titleAttributes))
        for word in words {
            str.append(NSAttributedString(string: "\n" + word.title + "\n\n", attributes: wordEntryAttributes))
            if word.explanation.trimmed().isNotEmpty {
                str.append(NSAttributedString(string: "Explanation: \n", attributes: headingsAttributes))
                str.append(NSAttributedString(string: word.explanation + "\n\n", attributes: bodyAttributes))
            }
            if word.example.trimmed().isNotEmpty {
                str.append(NSAttributedString(string: "Example: \n", attributes: headingsAttributes))
                str.append(NSAttributedString(string: word.example + "\n\n", attributes: bodyAttributes))
            }
        }
        return str
    }
    
    private func exportSentences(_ sentences: Results<SentenceEntry>) -> NSMutableAttributedString {
        let str = NSMutableAttributedString()
        for sentence in sentences {
            str.append(NSAttributedString(string: "Tags: ", attributes: headingsAttributes))
            if sentence.tags.isEmpty {
                str.append(NSAttributedString(string: "None", attributes: bodyAttributes))
            } else {
                for tag in sentence.tags {
                    str.append(NSAttributedString(string: tag.name, attributes: tagsAttributes))
                    str.append(NSAttributedString(string: " ", attributes: bodyAttributes))
                }
            }
            str.append(NSAttributedString(string: "\n\(sentence.sentence)\n\n", attributes: bodyAttributes))
        }
        return str
    }
    
    func attributedStringFromAppData() -> NSAttributedString {
        let sentences = DataManager.shared.sentenceEntries
        let words = DataManager.shared.wordEntries
        let str = NSMutableAttributedString()
        if options.contains(.includeWords) {
            str.append(exportWords(words))
        }
        if options.contains(.includeWords) && options.contains(.includeSentences) {
            str.append(NSAttributedString(string: "\n-------\n\n", attributes: bodyAttributes))
        }
        if options.contains(.includeSentences) {
            str.append(exportSentences(sentences))
        }
        return str
    }
}
