import UIKit
import TagsPanelView

class SentenceCell : UITableViewCell {
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
}
