import UIKit
import RealmSwift

struct AttributedStringExporter {
    struct Options: OptionSet {
        let rawValue: Int
        
        static let includeWords = Options(rawValue: 1 << 0)
        static let includeSentences = Options(rawValue: 1 << 1)
    }
    
    let options: Options
    
}
