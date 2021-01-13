import UIKit
import RealmSwift
import SCLAlertView
import TagsPanelView

class WordListViewController : UITableViewController {
    var words: Results<WordEntry>!

    let searchController = UISearchController(searchResultsController: nil)
    var filteredWords: Results<WordEntry>!

    var isSearchBarEmpty: Bool {
        searchController.searchBar.text?.isEmpty ?? true
    }

    var isFiltering: Bool {
        searchController.isActive && !isSearchBarEmpty
    }

    override func viewDidLoad() {
        words = DataManager.shared.wordEntries
        tableView.allowsSelectionDuringEditing = true
        navigationItem.rightBarButtonItems?.append(editButtonItem)

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search..."
        navigationItem.searchController = searchController
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false
        
        tableView.register(UINib(nibName: "TextWithTagCell", bundle: nil), forCellReuseIdentifier: "cell")
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
        cell.sentenceLabel?.text = wordEntry.title
        cell.tagsView.tagArray = wordEntry.tags.map(\.name)
        cell.tagsView.tagTextColor = .black
        cell.tagsView.tagsBackgroundColorsArray = Array(repeating: UIColor(named: "tagBackground")!, count: cell.tagsView.tagArray.count)
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let entry = (isFiltering ? filteredWords : words)[indexPath.row]
        let maxSize = CGSize(width: tableView.width - 16, height: .greatestFiniteMagnitude)
        let word = entry.title
        let wordHeight = (word as NSString)
                                .boundingRect(with: maxSize,
                                              options: [.usesLineFragmentOrigin],
                                              attributes: [.font: UIFont.systemFont(ofSize: 17)],
                                              context: nil)
                                .height
        let tagsHeight: CGFloat
        if entry.tags.isEmpty {
            tagsHeight = 0
        } else {
            tagsHeight = TagsPanelView.generatePanelHeightThatFit(maxSize, tags: entry.tags.map(\.name), fontSize: 17)
        }
        return wordHeight + tagsHeight + 32
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = (segue.destination as? UINavigationController)?.topViewController as? WordEditorViewController,
            let entryToEdit = sender as? WordEntry {
            vc.entryToEdit = entryToEdit
        } else if let vc = segue.destination as? EntryViewController,
                  let entry = sender as? WordEntry {
            vc.entry = entry
        }
    }

    @IBAction func addTapped() {
        performSegue(withIdentifier: "showWordEditor", sender: nil)
    }

    @IBAction func unwindFromWordEditor(_ segue: UIStoryboardSegue) {
        tableView.reloadData()
    }
}

extension WordListViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        filteredWords = DataManager.shared.words(matchingSearchTerm: searchText)
        tableView.reloadData()
    }


}
