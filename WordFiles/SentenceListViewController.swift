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
    
    @IBOutlet var sortButton: UIBarButtonItem!
    var sortByDate = false {
        didSet {
            sortButton.menu = generateSortMenu()
        }
    }
    
    func generateSortMenu() -> UIMenu {
        UIMenu(children: [
            UIAction(title: "By Date", state: sortByDate ? .on : .off) { _ in
                self.sentences = DataManager.shared.sentences(sortedByDate: true)
                self.tableView.reloadData()
                self.sortByDate = true
            },
            UIAction(title: "By Sentence", state: !sortByDate ? .on : .off) { _ in
                self.sentences = DataManager.shared.sentenceEntries
                self.tableView.reloadData()
                self.sortByDate = false
            },
        ])
    }

    override func viewDidLoad() {
        sentences = tagFilter.flatMap { DataManager.shared.sentences(withTag: $0) } ?? DataManager.shared.sentenceEntries
        tableView.register(UINib(nibName: "TextWithTagCell", bundle: nil), forCellReuseIdentifier: "cell")
        if tagFilter != nil {
            navigationItem.leftBarButtonItems = []
            navigationItem.rightBarButtonItems = []
            tableView.allowsSelection = false
            title = "Sentences tagged '\(tagFilter!)'"
        }
        navigationItem.rightBarButtonItems?.insert(editButtonItem, at: 0)
        tableView.allowsSelectionDuringEditing = true
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search..."
        navigationItem.searchController = searchController
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false
        
        sortButton.menu = generateSortMenu()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        (isFiltering ? filteredSentences : sentences).count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TextWithTagCell
        let sentenceEntry = (isFiltering ? filteredSentences : sentences)[indexPath.row]
        cell.prepareForReuse()
        cell.contentLabel.text = sentenceEntry.sentence
        cell.tagsView.tagArray = sentenceEntry.tags.map(\.name)
        cell.tagsView.tagTextColor = .black
        cell.tagsView.tagsBackgroundColorsArray = Array(repeating: UIColor(named: "tagBackground")!, count: cell.tagsView.tagArray.count)
        if sentenceEntry.tags.isEmpty {
            cell.tagsViewHeightConstraint.constant = 0
        } else {
            let maxSize = CGSize(width: tableView.width - 16, height: .greatestFiniteMagnitude)
            cell.tagsViewHeightConstraint.constant =
                    TagsPanelView.generatePanelHeightThatFit(maxSize, tags: sentenceEntry.tags.map(\.name), fontSize: 17)
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .delete
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        do {
            try DataManager.shared.deleteSentenceEntry((isFiltering ? filteredSentences : sentences)[indexPath.row])
            tableView.deleteRows(at: [indexPath], with: .automatic)
        } catch {
            SCLAlertView().showError("Error", subTitle: "An unknown error occurred.", closeButtonTitle: "OK")
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isEditing {
            performSegue(withIdentifier: "showSentenceEditor", sender: (isFiltering ? filteredSentences : sentences)[indexPath.row])
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = (segue.destination as? UINavigationController)?.topViewController as? SentenceEditorViewController {
            vc.sentenceToEdit = sender as? SentenceEntry
        } else if let vc = (segue.destination as? UINavigationController)?.topViewController as? TagListViewController,
            let tags = sender as? LazyCollection<AnyCollection<TagProtocol>> {
            vc.tags = tags
            vc.secondarySegue = "showSentencesWithTag"
            vc.delegate = self
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
                    UIPasteboard.general.string = (self.isFiltering ? self.filteredSentences : self.sentences)[indexPath.row].sentence
                }
            ])
        }
    }

    @IBAction func newSentenceTapped() {
        performSegue(withIdentifier: "showSentenceEditor", sender: nil)
    }

    @IBAction func unwindFromSentenceEditor(_ segue: UIStoryboardSegue) {
        if let tagFilter = tagFilter,
           DataManager.shared.realm.object(ofType: SentenceTag.self, forPrimaryKey: tagFilter) == nil {
            navigationController?.popViewController(animated: true)
            return
        }
        tableView.reloadData()
    }

    @IBAction func tagsTapped() {
        performSegue(withIdentifier: "showTags", sender: AnyCollection(DataManager.shared.sentenceTags.lazy.map { $0 as TagProtocol }).lazy)
    }
}

extension SentenceListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        filteredSentences = DataManager.shared.sentences(withTag: tagFilter,
                                                         matchingSearchTerm: searchText,
                                                         sortedByDate: sortByDate)
        tableView.reloadData()
    }
}

extension SentenceListViewController: TagListViewControllerDelegate {
    func tagListViewControllerWillDismiss(tagListVC: TagListViewController) {
        tableView.reloadData()
    }
}