import UIKit
import RealmSwift
import TagsPanelView
import SCLAlertView

class SentenceListViewController : UITableViewController {
    var sentences: Results<SentenceEntry>!
    var tagFilter: String?
    
    let searchController = UISearchController(searchResultsController: nil)
    var filteredSentences: Results<SentenceEntry>!

    var isSearchBarEmpty: Bool {
        searchController.searchBar.text?.isEmpty ?? true
    }

    var isFiltering: Bool {
        searchController.isActive && !isSearchBarEmpty
    }

    override func viewDidLoad() {
        sentences = tagFilter.flatMap { DataManager.shared.sentences(withTag: $0) } ?? DataManager.shared.sentenceEntries
        tableView.register(UINib(nibName: "SentenceCell", bundle: nil), forCellReuseIdentifier: "cell")
        if tagFilter == nil {
            navigationItem.rightBarButtonItems?.insert(editButtonItem, at: 0)
            tableView.allowsSelectionDuringEditing = true
        } else {
            navigationItem.leftBarButtonItems = []
            navigationItem.rightBarButtonItems = []
            tableView.allowsSelection = false
            title = "Sentences tagged '\(tagFilter!)'"
        }
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search..."
        navigationItem.searchController = searchController
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sentences.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SentenceCell
        cell.prepareForReuse()
        cell.sentenceLabel.text = sentences[indexPath.row].sentence
        cell.tagsView.tagArray = sentences[indexPath.row].tags.map(\.name)
        cell.tagsView.tagTextColor = .black
        cell.tagsView.tagsBackgroundColorsArray = Array(repeating: UIColor(named: "tagBackground")!, count: cell.tagsView.tagArray.count)
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let entry = sentences[indexPath.row]
        let maxSize = CGSize(width: tableView.width - 16, height: .greatestFiniteMagnitude)
        let sentence = entry.sentence
        let sentenceHeight = (sentence as NSString)
                                .boundingRect(with: maxSize,
                                              options: [.usesLineFragmentOrigin],
                                              attributes: [.font: UIFont.systemFont(ofSize: 17)],
                                              context: nil)
                                .height
        let tagsHeight = TagsPanelView.generatePanelHeightThatFit(maxSize, tags: entry.tags.map(\.name), fontSize: 17)
        return sentenceHeight + tagsHeight + 32
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        tagFilter == nil
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .delete
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        do {
            try DataManager.shared.deleteSentenceEntry(sentences[indexPath.row])
            tableView.deleteRows(at: [indexPath], with: .automatic)
        } catch {
            SCLAlertView().showError("Error", subTitle: "An unknown error occurred.", closeButtonTitle: "OK")
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isEditing {
            performSegue(withIdentifier: "showSentenceEditor", sender: sentences[indexPath.row])
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = (segue.destination as? UINavigationController)?.topViewController as? SentenceEditorViewController {
            vc.sentenceToEdit = sender as? SentenceEntry
        }
    }

    override func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        true
    }

    override func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        print(action)
        return true
    }

    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { elements in
            UIMenu(children: [
                UIAction(title: "Copy", image: UIImage(systemName: "doc.on.doc.fill")) { action in
                    UIPasteboard.general.string = self.sentences[indexPath.row].sentence
                }
            ])
        }
    }

    @IBAction func newSentenceTapped() {
        performSegue(withIdentifier: "showSentenceEditor", sender: nil)
    }

    @IBAction func unwindFromSentenceEditor(_ segue: UIStoryboardSegue) {
        tableView.reloadData()
    }

    @IBAction func tagsTapped() {
        performSegue(withIdentifier: "showTags", sender: nil)
    }
}
