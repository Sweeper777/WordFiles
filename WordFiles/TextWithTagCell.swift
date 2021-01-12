import UIKit
import TagsPanelView

class TextWithTagCell : UITableViewCell {
    @IBOutlet var sentenceLabel: UILabel!
    @IBOutlet var stackView: UIStackView!
    var tagsView: TagsPanelView!

    override func prepareForReuse() {
        super.prepareForReuse()
        stackView.arrangedSubviews[safe: 1]?.removeFromSuperview()
        tagsView = TagsPanelView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        tagsView.backgroundColor = .clear
        tagsView.contentMode = .left
        stackView.addArrangedSubview(tagsView)
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        true
    }

    override func copy(_ sender: Any?) {
        print(sender ?? "nil")
    }

    override var canBecomeFirstResponder: Bool {
        true
    }
}
