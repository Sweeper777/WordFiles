import UIKit
import RealmSwift
import SCLAlertView
import TagsPanelView

class WordListViewController : UITableViewController {
    var words: Results<WordEntry>!
    var tagFilter: String?

    let searchController = UISearchController(searchResultsController: nil)
    var filteredWords: Results<WordEntry>!
    
    @IBOutlet var sortButton: UIBarButtonItem!
    var sortByDate = false {
        didSet {
            sortButton.menu = generateSortMenu()
        }
    }

    var isSearchBarEmpty: Bool {
        searchController.searchBar.text?.isEmpty ?? true
    }

    var isFiltering: Bool {
        searchController.isActive && !isSearchBarEmpty
    }

    func generateSortMenu() -> UIMenu {
        UIMenu(children: [
            UIAction(title: "By Date", state: sortByDate ? .on : .off) { _ in
                self.words = DataManager.shared.words(sortedByDate: true)
                self.tableView.reloadData()
                self.sortByDate = true
            },
            UIAction(title: "By Word", state: !sortByDate ? .on : .off) { _ in
                self.words = DataManager.shared.wordEntries
                self.tableView.reloadData()
                self.sortByDate = false
            },
        ])
    }
    
    override func viewDidLoad() {
        words = tagFilter.flatMap { DataManager.shared.words(withTag: $0) } ?? DataManager.shared.wordEntries
        
        if tagFilter == nil {
            navigationItem.rightBarButtonItems?.append(editButtonItem)
            tableView.allowsSelectionDuringEditing = true
        } else {
            title = "Words tagged '\(tagFilter!)'"
            navigationItem.rightBarButtonItems = []
            navigationItem.leftBarButtonItems = []
        }

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search..."
        navigationItem.searchController = searchController
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false
        
        tableView.register(UINib(nibName: "TextWithTagCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        sortButton.menu = generateSortMenu()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isFiltering ? filteredWords.count : words.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TextWithTagCell
        let wordEntry = (isFiltering ? filteredWords : words)[indexPath.row]
        cell.prepareForReuse()
        cell.contentLabel?.text = wordEntry.title
        cell.tagsView.tagArray = wordEntry.tags.map(\.name)
        cell.tagsView.tagTextColor = .black
        cell.tagsView.tagsBackgroundColorsArray = Array(repeating: UIColor(named: "tagBackground")!, count: cell.tagsView.tagArray.count)
        cell.accessoryType = .disclosureIndicator
        if wordEntry.tags.isEmpty {
            cell.tagsViewHeightConstraint.constant = 0
        } else {
            let maxSize = CGSize(width: tableView.width - 16, height: .greatestFiniteMagnitude)
            cell.tagsViewHeightConstraint.constant =
                    TagsPanelView.generatePanelHeightThatFit(maxSize, tags: wordEntry.tags.map(\.name), fontSize: 17)
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        tagFilter == nil
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        do {
            try DataManager.shared.deleteWordEntry((isFiltering ? filteredWords : words)[indexPath.row])
            tableView.deleteRows(at: [indexPath], with: .automatic)
        } catch {
            SCLAlertView().showError("Error", subTitle: "An unknown error has occurred.", closeButtonTitle: "OK")
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            performSegue(withIdentifier: "showWordEditor", sender: (isFiltering ? filteredWords : words)[indexPath.row])
        } else {
            performSegue(withIdentifier: "showEntry", sender: (isFiltering ? filteredWords : words)[indexPath.row])
        }
    }

    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { elements in
            UIMenu(children: [
                UIAction(title: "Copy", image: UIImage(systemName: "doc.on.doc.fill")) { action in
                    UIPasteboard.general.string = (self.isFiltering ? self.filteredWords : self.words)[indexPath.row].title
                }
            ])
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = (segue.destination as? UINavigationController)?.topViewController as? WordEditorViewController,
            let entryToEdit = sender as? WordEntry {
            vc.entryToEdit = entryToEdit
        } else if let vc = segue.destination as? WordEntryViewController,
                  let entry = sender as? WordEntry {
            vc.entry = entry
        } else if let vc = (segue.destination as? UINavigationController)?.topViewController as? TagListViewController,
                  let tags = sender as? LazyCollection<AnyCollection<TagProtocol>> {
            vc.tags = tags
            vc.secondarySegue = "showWordsWithTag"
        }
    }

    @IBAction func addTapped() {
        performSegue(withIdentifier: "showWordEditor", sender: nil)
    }

    @IBAction func tagsTapped() {
        performSegue(withIdentifier: "showWordTags", sender: AnyCollection(DataManager.shared.wordTags.lazy.map { $0 as TagProtocol }).lazy)
    }
    
    @IBAction func unwindFromWordEditor(_ segue: UIStoryboardSegue) {
        tableView.reloadData()
    }
}

extension WordListViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        filteredWords = DataManager.shared.words(withTag: tagFilter,
                                                 matchingSearchTerm: searchText,
                                                 sortedByDate: sortByDate)
        tableView.reloadData()
    }


}
