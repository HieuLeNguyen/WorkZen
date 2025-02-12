import UIKit

final class DayTableViewController: UITableViewController {
    
    private let realmManager = RealmManager.shared
    private var tasks: [Task] = []
    private var groupedTasks: [TaskModel] = []
    
    weak var delegate: DayTableViewControllerDelegate?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        readTaskFromDB()
        // Theo dõi sử thay đổi của Realm
        observeRealmChanges()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if groupedTasks.isEmpty {
            tableView.backgroundView = SuggestUIView(frame: tableView.bounds)
        } else {
            tableView.backgroundView = nil
        }
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
    
    // MARK: - Read data from database
    /// Chỉ lấy ra tasks chưa thành công
    
    private func readTaskFromDB() {
        tasks = realmManager.getAll(Task.self).filter { !$0.isCompleted }
        groupTasksByDate()
        tableView.reloadData()
    }
    
    // Nhóm Tasks theo ngày và sắp xếp theo thời gian
    private func groupTasksByDate() {
        
        let groupedDict = Dictionary(grouping: tasks) { task -> String in
            task.time.toTitleFormat()
        }
        groupedTasks = groupedDict.map { key, value in
            /// Sắp xếp thời gian của mảng tasks (10:20)
            let sortedTasks = value.sorted { $0.time < $1.time }
            return TaskModel(title: key, tasks: sortedTasks)
        }
        /// Sắp xếp theo ngày (Date tăng dần)
        groupedTasks.sort {
            Date.fromTitle($0.title) < Date.fromTitle($1.title)
        }
    }
    
    private func observeRealmChanges() {
        realmManager.observeChanges(for: Task.self) { [weak self] in
            self?.tableView.reloadData()
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
        let task = groupedTasks[indexPath.section].tasks[indexPath.row]
        // swiftlint:disable force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: TaskCell.identifier,
                                                 for: indexPath) as! TaskCell
        // swiftlint:enable force_cast
        cell.config(title: task.name,
                    description: task.desc,
                    time: task.time.toTimeFormat(),
                    importance: task.importance,
                    color: task.color)
        return cell
    }
    
    override func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            
            // Action: Xoá
            let deleteAction = UIContextualAction(style: .destructive,
                                                  title: nil) { [weak self] (action, view, completionHandler) in
                
                guard let strongSelf = self else {
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
                    
                })
                
                strongSelf.present(alert, animated: true, completion: nil)
            }
            
            // Action: Hoàn thành
            let completeAction = UIContextualAction(style: .normal,
                                                    title: nil) { [weak self] (action, view, completionHandler) in
                
                guard let strongSelf = self else {
                    completionHandler(false)
                    return
                }
                completionHandler(true)
            }
            
            let clearBackgroundColor = UIColor.init(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.0)
            /// Style Button Delete
            deleteAction.image = UIImage(systemName: "trash.square.fill")?
                .withTintColor(.systemRed)
                .withRenderingMode(.alwaysOriginal)
            deleteAction.backgroundColor = clearBackgroundColor
            /// Style Button Complete
            completeAction.image = UIImage(systemName: "checkmark.square.fill")?
                .withTintColor(.systemGreen)
                .withRenderingMode(.alwaysOriginal)
            completeAction.backgroundColor = clearBackgroundColor
            
            let configuration = UISwipeActionsConfiguration(actions: [deleteAction, completeAction])
            configuration.performsFirstActionWithFullSwipe = false
            
            return configuration
        }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    // MARK: - Navigation
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Bỏ highlight cho dòng đã chọn
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let viewController = UIStoryboard.main.instantiateViewController(withIdentifier: "EditTaskViewController")
                as? EditTaskViewController else {
            return
        }
        
        let item = groupedTasks[indexPath.section].tasks[indexPath.row]
        viewController.task = item
        
        let navController = UINavigationController(rootViewController: viewController)
        navController.modalPresentationStyle = .formSheet
        
        present(navController, animated: true, completion: nil)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.dayTableViewDidScroll(scrollView)
    }
    
}

// MARK: - Delegate Proxy (Forwarding Delegate)
/// Error: Xử lý vấn đề Delegate chỉ hoạt động ở một nơi duy nhất
/// Desc: Nhận event 'scrollViewDidScroll' ở HomeVC, K nhận event 'trailingSwipeActionsConfigurationForRowAt'
protocol DayTableViewControllerDelegate: AnyObject {
    func dayTableViewDidScroll(_ scrollView: UIScrollView)
}

// FIXME: Khi ở item thứ 7 có lỗi scroll
