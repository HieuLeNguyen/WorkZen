import UIKit

final class DayTableViewController: UITableViewController {
    
    private let rm = RealmManager.shared
    private var tasks: [Task] = []
    private var groupedTasks: [TaskModel] = []
    
    weak var delegate: DayTableViewControllerDelegate?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        readTaskFromDB()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if groupedTasks.isEmpty {
            tableView.backgroundView = SuggestUIView(frame: tableView.bounds)
        } else {
            tableView.backgroundView = nil
        }
    }
    
    private func readTaskFromDB() {
        tasks = rm.getAll(Task.self).filter { !$0.isCompleted }
        groupTasksByDate()
        tableView.reloadData()
    }
    
    /// Định dạng Date() -> 9 Sunday
    private func formatDateToTitle(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "d EEEE"
        return dateFormatter.string(from: date)
    }
    
    /// Định dạng Date() -> 10:20
    private func formatDateToTime(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: date)
    }
    
    /// Chuyển từ "9 Sunday" ->  Date
    private func parseDate(from title: String) -> Date {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "d EEEE"
        
        return formatter.date(from: title) ?? Date.distantPast
    }
    
    /// Nhóm Tasks theo ngày và sắp xếp theo thời gian
    private func groupTasksByDate() {
        let groupedDict = Dictionary(grouping: tasks) { task -> String in
            formatDateToTitle(task.time)
        }
        
        groupedTasks = groupedDict.map { key, value in
            // Sắp xếp thời gian của mảng tasks (10:20)
            let sortedTasks = value.sorted { $0.time < $1.time }
            return TaskModel(title: key, tasks: sortedTasks)
        }
        
        // Sắp xếp theo ngày (Date tăng dần)
        groupedTasks.sort {
            parseDate(from: $0.title) < parseDate(from: $1.title)
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return groupedTasks.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return groupedTasks[section].title
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupedTasks[section].tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TaskCell.identifier,
                                                 for: indexPath) as! TaskCell
        let task = groupedTasks[indexPath.section].tasks[indexPath.row]
        cell.config(title: task.name,
                    description: task.desc,
                    time: formatDateToTime(task.time),
                    importance: task.importance,
                    color: task.color)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] (action, view, completionHandler) in
            guard let self = self else {
                completionHandler(false)
                return
            }
            
            let alert = UIAlertController(title: "Confirm Delete",
                                          message: "Are you sure you want to delete this item?",
                                          preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                completionHandler(false)
            })
            
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
                // Thực hiện hành động xóa
                //                self.vm.deleteTask(task: self.incompleteTasks[indexPath.row], taskIndex: indexPath.row) {
                //                    print("Deleted task")
                //                }
                //                tableView.deleteRows(at: [indexPath], with: .automatic)
                //                completionHandler(true)
            })
            
            self.present(alert, animated: true, completion: nil)
        }
        /// Style Button Delete
        deleteAction.image = UIImage(systemName: "trash.square.fill")?
            .withTintColor(.systemRed)
            .withRenderingMode(.alwaysOriginal)
        deleteAction.backgroundColor = UIColor.init(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.0)
        
        // Action Hoàn thành
        let completeAction = UIContextualAction(style: .normal, title: nil) { [weak self] (action, view, completionHandler) in
            guard let self = self else {
                return
            }
            //            let task = incompleteTasks[indexPath.row]
            //            self.vm.updateTaskStatus(task: task, isCompleted: true) {
            //                tableView.reloadData()
            //            }
            completionHandler(true)
        }
        /// Style Button Complete
        completeAction.image = UIImage(systemName: "checkmark.square.fill")?
            .withTintColor(.systemGreen)
            .withRenderingMode(.alwaysOriginal)
        completeAction.backgroundColor = UIColor.init(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.0)
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, completeAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    // MARK: - Navigation
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = sb.instantiateViewController(withIdentifier: "EditTaskViewController")
                as? EditTaskViewController
        else {
            return
        }
        //        vc.task = incompleteTasks[indexPath.row]
        //        vc.onSave = { [weak self] updatedTask in
        //            guard let strongSelf = self else { return }
        //            strongSelf.vm.editTask(task: strongSelf.incompleteTasks[indexPath.row], updateTask: updatedTask) {
        //                strongSelf.tableView.reloadData()
        //            }
        //        }
        let item = groupedTasks[indexPath.section].tasks[indexPath.row]
        vc.task = item
        vc.onSave = { [weak self] updatedTask in
            guard let strongSelf = self else { return }
//            strongSelf.rm.update {
//                <#code#>
//            } completion: { <#Result<Void, any Error>#> in
//                <#code#>
//            }

            strongSelf.tableView.reloadData()
        }
        
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .formSheet
        present(navController, animated: true, completion: nil)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.dayTableViewDidScroll(scrollView)
    }
    
    // MARK: - Setups Table View
    
    private func setupTableView() {
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(TaskCell.nib(),
                           forCellReuseIdentifier: TaskCell.identifier)
        tableView.separatorStyle = .none
        // Loại bỏ animation 'didSelecte' khi chuyển qua 1 view khác
        self.clearsSelectionOnViewWillAppear = true
    }
}

// MARK: - Delegate Proxy (Forwarding Delegate)
/// Error: Xử lý vấn đề Delegate chỉ hoạt động ở một nơi duy nhất
/// Desc: Nhận event 'scrollViewDidScroll' ở HomeVC, K nhận event 'trailingSwipeActionsConfigurationForRowAt'
protocol DayTableViewControllerDelegate: AnyObject {
    func dayTableViewDidScroll(_ scrollView: UIScrollView)
}

// FIXME: - Khi ở item thứ 7 có lỗi scroll
