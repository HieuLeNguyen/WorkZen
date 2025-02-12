import UIKit

final class HomeViewController: UIViewController {
    
    private let realmManager = RealmManager.shared
    private var tasks: [Task] = []
    
    private var currentVC: UIViewController?
    
    private var childViewController: DayTableViewController?
    
    // MARK: - Outlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var topStackView: UIStackView!
    @IBOutlet weak var filterButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Bật hiển thị chuyển đổi các VC
        switchToViewController(DayTableViewController())
        // Thiết lập nav
        setupNav()
        hideKeyboardWhenTappedAround()
    }
    
    private func readTaskFromDB() {
        let allData = realmManager.getAll(Task.self)
        for data in allData {
            tasks.append(data)
        }
    }
}

extension HomeViewController {
    
    // MARK: - Navigation of Home
    
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
        // Xoá VC cũ
        currentVC?.willMove(toParent: nil)
        currentVC?.view.removeFromSuperview()
        currentVC?.removeFromParent()
        // Thêm VC mới
        addChild(newVC)
        containerView.addSubview(newVC.view)
        newVC.view.frame = containerView.bounds
        newVC.didMove(toParent: self)
        
        currentVC = newVC
    }
    
    // MARK: - Add New Task
    
    @objc
    private func createNewTask() {
        // swiftlint:disable:next line_length
        guard let viewController = UIStoryboard.main.instantiateViewController(withIdentifier: "CreateTaskViewController")
                as? CreateTaskViewController else {
            return
        }
        
        let nav = UINavigationController(rootViewController: viewController)
        nav.modalPresentationStyle = .pageSheet
        nav.navigationBar.prefersLargeTitles = true
        
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
        }
        
        present(nav, animated: true)
    }
    
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

