import UIKit

final class CreateTaskViewController: UIViewController {
    
    private let rm = RealmManager.shared
    private var task: Task = Task()
    private var selectedTag: TaskCategory?
    private var selectedImportance: ImportanceLevel?
    private var selectedColor: TaskColor?
    
    // MARK: - Outlets
    @IBOutlet weak var taskNameField: UITextField!
    @IBOutlet weak var taskDescField: UITextField!
    @IBOutlet weak var chooseDatePicker: UIDatePicker!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var importanceButton: UIButton!
    @IBOutlet weak var colorButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        chooseDatePicker.contentHorizontalAlignment = .leading
        navigationItem.title = "Create New Task📋"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save,
                                                               target: self,
                                                               action: #selector(didSaveTask))
        
        taskNameField.delegate = self
        taskDescField.delegate = self
        taskNameField.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tagButton.menu = tagButtonTapped()
        importanceButton.menu = importanceButtonTapped()
        colorButton.menu = colorButtonTapped()
    }
    
    // MARK: - Create / Save Task
    @objc
    private func didSaveTask() {
        guard let taskName = taskNameField.text, !taskName.isEmpty else {
            showAlert()
            return
        }
        
        let newTask = Task(
            name: taskName,
            description: taskDescField.text ?? "No description available",
            importance: selectedImportance ?? .low,
            time: chooseDatePicker.date,
            color: selectedColor ?? .lightBlue,
            category: selectedTag ?? .personal
        )

        rm.create(newTask) { result in
            switch result {
            case .success:
                print("Task saved successfully")
                self.dismiss(animated: true, completion: nil)
            case .failure(let error):
                print("Error saving task: \(error)")
            }
        }
    }
    
    private func showAlert() {
        let alert = UIAlertController(title: "Woops!",
                                      message: "Please enter a task name",
                                      preferredStyle: .alert)
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

// MARK: - UITextFieldDelegate

extension CreateTaskViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == taskNameField {
            taskDescField.becomeFirstResponder()
        } else if textField == taskDescField {
            textField.resignFirstResponder()
            didSaveTask()
        }
        return true
    }
}
