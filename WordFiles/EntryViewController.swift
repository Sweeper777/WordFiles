import Eureka

class EntryViewController: FormViewController {
    var entry: WordEntry!
    private var exampleRowIndexPath: IndexPath?
    private var explanationRowIndexPath: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()

        form +++ LabelRow {
            row in
            row.title = entry.title
        }

        if entry.explanation.trimmed().isNotEmpty {
            form +++ Section("explanation")
            <<< LabelRow("explanationRow") {
                row in
                row.title = entry.explanation
            }.cellUpdate { [weak self] (cell, row) in
                cell.textLabel?.numberOfLines = 0
                self?.explanationRowIndexPath = row.indexPath
            }
        }

        if entry.example.trimmed().isNotEmpty {
            form +++ Section("example")
            <<< SwitchRow(tagExampleShown) { row in
                row.value = false
                row.hidden = true
            }
            <<< ButtonRow {
                row in
                row.title = "Toggle Example"
            }.onCellSelection { (cell, row) in
                if let exampleShown = cell.formViewController()?.form.rowBy(tag: tagExampleShown) as? RowOf<Bool> {
                    exampleShown.value?.toggle()
                }
            }
            <<< LabelRow("exampleRow") {
                row in
                row.title = entry.example
                row.hidden = .function([tagExampleShown], { form in
                    !((form.rowBy(tag: tagExampleShown) as? RowOf<Bool>)?.value ?? false)
                })
            }.cellUpdate { [weak self] (cell, row) in
                cell.textLabel?.numberOfLines = 0
                self?.exampleRowIndexPath = row.indexPath
            }
        }
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let string: String?
        if indexPath == explanationRowIndexPath {
            string = form.rowBy(tag: "explanationRow")?.title
        } else if indexPath == exampleRowIndexPath {
            string = form.rowBy(tag: "exampleRow")?.title
        } else {
            string = nil
        }
        return string.map { stringToCopy in
            UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { elements in
                UIMenu(children: [
                    UIAction(title: "Copy", image: UIImage(systemName: "doc.on.doc.fill")) { action in
                        UIPasteboard.general.string = stringToCopy
                    }
                ])
            }
        }
    }
}

let tagExampleShown = "exampleShown"
