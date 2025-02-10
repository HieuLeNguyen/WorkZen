import UIKit

final class EditTaskViewController: UIViewController {

    private let rm = RealmManager.shared
    var task: Task?
    var onSave: ((Task) -> Void)?
    private var selectedTag: TaskCategory?
    private var selectedImportance: ImportanceLevel?
    private var selectedColor: TaskColor?
    
    // MARK: - Outlets
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var descField: UITextField!
    @IBOutlet weak var chooseDatePicker: UIDatePicker!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var importanceButton: UIButton!
    @IBOutlet weak var colorButton: UIButton!
    @IBOutlet weak var isCompletionSwitch: UISwitch!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        chooseDatePicker.contentHorizontalAlignment = .leading
        navigationItem.title = "Edit Task✏️"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save,
                                                            target: self,
                                                            action: #selector(saveButton))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                           target: self,
                                                           action: #selector(dismissModal))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tagButton.menu = tagButtonTapped()
        importanceButton.menu = importanceButtonTapped()
        colorButton.menu = colorButtonTapped()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let myTask = task {
            titleField.text = myTask.name
            descField.text = myTask.desc
            chooseDatePicker.date = myTask.time
        } else {
            print("Nullll")
        }
    }
    
    // MARK: - Save Button
    
    @objc
    private func saveButton() {
        guard let title = titleField.text, !title.isEmpty else {
            showAlert(title: "Error", message: "Please enter task title")
            return
        }

        let newTask = Task(
            name: title,
            description: descField.text ?? "No description available",
            importance: selectedImportance ?? .low,
            time: chooseDatePicker.date,
            color: selectedColor ?? .lightBlue,
            category: selectedTag ?? .personal
        )
        onSave?(newTask)
        dismissModal()
    }
    // MARK: - Delete Button
    
    @IBAction func didTapDeleteButton(_ sender: Any) {
        if let task = task {
            rm.delete(task) { result in
                switch result {
                case .success:
                    print("Edit success")
                    self.dismissModal()
                case .failure(let error):
                    debugPrint("Error Edit: \(error)")
                }
            }
        }
        
    }
    
    // MARK: - Dismiss Modal
    
    @objc
    private func dismissModal() {
        dismiss(animated: true)
    }
    
    // MARK: - Alert Error
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Configation Button Menu
    
    private func tagButtonTapped() -> UIMenu {
        let menuItem1 = UIAction(title: "Work", image: UIImage(systemName: "folder")) { [weak self] _ in
            self?.selectedTag = .work
        }
        let menuItem2 = UIAction(title: "Personal", image: UIImage(systemName: "person")) { [weak self]  _ in
            self?.selectedTag = .personal
        }
        let menuItem3 = UIAction(title: "Study", image: UIImage(systemName: "book")) { [weak self]  _ in
            self?.selectedTag = .study
        }
        return UIMenu(title: "", children: [menuItem1, menuItem2, menuItem3])
    }
    
    private func importanceButtonTapped() -> UIMenu {
        let imgFlagFill = UIImage(systemName: "flag.fill")?.withRenderingMode(.alwaysOriginal)
        let menuItem1 = UIAction(title: "Low", image: imgFlagFill?.withTintColor(.systemCyan)
        ) { [weak self] _ in
            self?.selectedImportance = .low
        }
        let menuItem2 = UIAction(title: "Medium", image: imgFlagFill?.withTintColor(.systemOrange)
        ) { [weak self]  _ in
            self?.selectedImportance = .medium
        }
        let menuItem3 = UIAction(title: "Hight", image: imgFlagFill?.withTintColor(.systemRed)
        ) { [weak self]  _ in
            self?.selectedImportance = .high
        }
        return UIMenu(title: "Importance Level", children: [menuItem1, menuItem2, menuItem3])
    }
    
    private func colorButtonTapped() -> UIMenu {
        let imgSquareFill = UIImage(systemName: "square.fill")?.withRenderingMode(.alwaysOriginal)
        let menuItem1 = UIAction(title: "Light blue",
                                 image: imgSquareFill?.withTintColor(.lightBlue)
        ) { [weak self] _ in
            self?.selectedColor = .lightBlue
        }
        let menuItem2 = UIAction(title: "Light red",
                                 image: imgSquareFill?.withTintColor(.lightRed)
        ) { [weak self] _ in
            self?.selectedColor = .lightRed
        }
        let menuItem3 = UIAction(title: "Light green",
                                 image: imgSquareFill?.withTintColor(.lightGreen)
        ) { [weak self] _ in
            self?.selectedColor = .lightGreen
        }
        let menuItem4 = UIAction(title: "Light yellow",
                                 image: imgSquareFill?.withTintColor(.lightYellow)
        ) { [weak self] _ in
            self?.selectedColor = .lightYellow
        }
        return UIMenu(title: "Color options for tasks", children: [menuItem1, menuItem2, menuItem3, menuItem4])
    }

}
