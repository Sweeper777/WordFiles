import Eureka

class EntryViewController: FormViewController {
    var entry: WordEntry!

    override func viewDidLoad() {
        super.viewDidLoad()

        form +++ LabelRow {
            row in
            row.title = entry.title
        }

        if entry.explanation.trimmed().isNotEmpty {
            form +++ Section("explanation")
                    <<< TextAreaRow {
                row in
                row.value = entry.explanation
            }.cellUpdate { (cell, row) in
                cell.textView.isEditable = false
                cell.textView.spellCheckingType = .no
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
            <<< TextAreaRow {
                row in
                row.value = entry.example
                row.hidden = .function([tagExampleShown], { form in
                    !((form.rowBy(tag: tagExampleShown) as? RowOf<Bool>)?.value ?? false)
                })
            }.cellUpdate { (cell, row) in
                cell.textView.isEditable = false
                cell.textView.spellCheckingType = .no
            }
        }
    }
}

let tagExampleShown = "exampleShown"