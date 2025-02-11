import UIKit

final class HomeViewController: UIViewController {
    
    private let rm = RealmManager.shared
    private var tasks: [Task] = []
    
    private var currentVC: UIViewController?
    
    private var childViewController: DayTableViewController?
    
    // MARK: - Outlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var topStackView: UIStackView!
    @IBOutlet weak var filterButton: UIButton!
    
    func observeRealmChanges() {
        rm.observeChanges(for: Task.self) { [weak self] in
            self?.childViewController?.tableView.reloadData()
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        /// Theo dõi sử thay đổi của Realm
        observeRealmChanges()
        /// Bật hiển thị chuyển đổi các VC
        switchToViewController(DayTableViewController())
        /// Thiết lập nav
        setupNav()
        // Thiết lập cho nút Filter
        //        setupFilterButton()
    }
    
    private func readTaskFromDB() {
//        let allData = rw.getObjects(Task.self)
        let allData = rm.getAll(Task.self)
        print("All Data :- \(String(describing: allData))")
        
        if (allData.count == 0) {
//            Hiện lable
//            ẩn table
        } else {
//            Ẩn label
//            hiện table
        }
        
        for data in allData {
            tasks.append(data)
        }
        
        childViewController?.tableView.reloadData()
    }
}

extension HomeViewController {
    
    // MARK: -  Navigation of Home

    private func setupNav() {
        let leftMenuButton = UIBarButtonItem(image: UIImage(systemName: "list.bullet"))
        leftMenuButton.menu = UIMenu(title: "Select display mode", children: [
            UIAction(title: "Day", handler: { [weak self] _ in
                self?.switchToViewController(DayTableViewController())
            }),
            UIAction(title: "Week", handler: { [weak self] _ in
                self?.switchToViewController(WeekViewController())
            }),
            UIAction(title: "Month", handler: { [weak self] _ in
                self?.switchToViewController(MonthViewController())
            })
        ])
        
        navigationItem.leftBarButtonItem = leftMenuButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose,
                                                            target: self,
                                                            action: #selector(createNewTask))
    }
    
    private func switchToViewController(_ newVC: UIViewController) {
        /// Xoá VC cũ
        currentVC?.willMove(toParent: nil)
        currentVC?.view.removeFromSuperview()
        currentVC?.removeFromParent()
        /// Thêm VC mới
        addChild(newVC)
        containerView.addSubview(newVC.view)
        newVC.view.frame = containerView.bounds
        newVC.didMove(toParent: self)
        
        currentVC = newVC
    }
    
    // MARK: - Add New Task
    @objc
    private func createNewTask() {
        guard let vc = sb.instantiateViewController(withIdentifier: "CreateTaskViewController") as? CreateTaskViewController else {
            return
        }
        
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        nav.navigationBar.prefersLargeTitles = true
        
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
        }
        
        present(nav, animated: true)
    }
    
    
    // MARK: - Setup: Filter Button
    //    private func setupFilterButton() {
    //        // Tạo các item
    //        let allAction = UIAction(title: TaskCategory.all.rawValue,
    //                                 state: currentCategory == .all ? .on : .off,
    //                                 handler: { _ in
    //            self.currentCategory = .all
    //            self.updateActionStates()
    //        })
    //
    //        let workAction = UIAction(title: TaskCategory.work.rawValue,
    //                                  state: currentCategory == .work ? .on : .off,
    //                                  handler: { _ in
    //            self.currentCategory = .work
    //            self.updateActionStates()
    //        })
    //
    //        let personalAction = UIAction(title: TaskCategory.personal.rawValue,
    //                                      state: currentCategory == .personal ? .on : .off,
    //                                      handler: { _ in
    //            self.currentCategory = .personal
    //            self.updateActionStates()
    //        })
    //
    //        let studyAction = UIAction(title: TaskCategory.study.rawValue,
    //                                   state: currentCategory == .study ? .on : .off,
    //                                   handler: { _ in
    //            self.currentCategory = .study
    //            self.updateActionStates()
    //        })
    //
    //        let menu = UIMenu(options: .displayInline, children: [
    //            allAction,
    //            workAction,
    //            personalAction,
    //            studyAction
    //        ])
    //
    //        // Thêm vào menu vào menu của Filter button
    //        filterButton.menu = menu
    //        filterButton.showsMenuAsPrimaryAction = true
    //    }

}

// MARK: - UITableViewDelegate - Ẩn / Hiện Navi Khi cuộn

extension HomeViewController: DayTableViewControllerDelegate {
    
    func dayTableViewDidScroll(_ scrollView: UIScrollView) {
        self.scrollViewDidScroll(scrollView)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let translation = scrollView.panGestureRecognizer.translation(in: scrollView).y
        
        if let tabBar = self.tabBarController?.tabBar {
            if translation < 0 {
                // Trượt xuống -> Ẩn NavigationBar & TabBar với hiệu ứng
                self.navigationController?.setNavigationBarHidden(true, animated: true)
                
                UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
                    tabBar.transform = CGAffineTransform(translationX: 0, y: tabBar.frame.height)
                    tabBar.alpha = 0
                }, completion: { _ in
                    tabBar.isHidden = true
                })
                
            } else {
                // Trượt lên -> Hiện NavigationBar & TabBar với hiệu ứng
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                
                tabBar.isHidden = false
                
                UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
                    tabBar.transform = .identity
                    tabBar.alpha = 1
                })
            }
        }
    }
}

