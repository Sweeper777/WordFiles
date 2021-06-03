import UIKit
import TagsPanelView

class TextWithTagCell : UITableViewCell {
    @IBOutlet var contentLabel: UILabel!
    @IBOutlet var stackView: UIStackView!
    var tagsView: TagsPanelView!
    var tagsViewHeightConstraint: NSLayoutConstraint!

    override func prepareForReuse() {
        super.prepareForReuse()
        stackView.arrangedSubviews[safe: 1]?.removeFromSuperview()
        tagsView = TagsPanelView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        tagsView.translatesAutoresizingMaskIntoConstraints = false
        tagsView.backgroundColor = .clear
        tagsView.contentMode = .left
        tagsViewHeightConstraint = tagsView.heightAnchor.constraint(equalToConstant: 100)
        tagsViewHeightConstraint.isActive = true
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
