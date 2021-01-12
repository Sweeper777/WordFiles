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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = (isFiltering ? filteredWords : words)[indexPath.row].title
        cell.accessoryType = .disclosureIndicator
        return cell
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
        filteredWords = DataManager.shared.wordsMatchingSearchTerm(searchText)
        tableView.reloadData()
    }


}
