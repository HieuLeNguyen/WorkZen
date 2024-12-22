//
//  HomeViewController.swift
//  WorkZen
//
//  Created by Nguyễn Văn Hiếu on 15/12/24.
//

import UIKit

class HomeViewController: UIViewController {
    // MARK: - Views
    private let tableView = UITableView()
    private let customView1 = UIView()
    private let customView2 = UIView()
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateViewMode(to: "Day")
        setupNavigation()
        
    }
    
    // MARK: -  Navigation
    private func setupNavigation() {
        let menuItems = [
            UIAction(title: "Day", image: UIImage(systemName: "calendar")) { action in
                self.updateViewMode(to: "Day")
            },
            UIAction(title: "Week", image: UIImage(systemName: "calendar.badge.clock")) { action in
                self.updateViewMode(to: "Week")
            },
            UIAction(title: "Month", image: UIImage(systemName: "calendar.badge.plus")) { action in
                self.updateViewMode(to: "Month")
            }
        ]
        
        let menu = UIMenu(title: "Select display mode", children: menuItems)
        
        // Thêm add vào rightBarButtonItem
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose,
                                                            target: self,
                                                            action: #selector(createNewTask))
    }
    
    // MARK: - Setup Views
    private func setupViews() {
        // TableView setup
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        // Custom View setup
        customView1.backgroundColor = .systemBlue
        customView2.backgroundColor = .systemRed
        
        // Add views but hide them initially
        view.addSubview(tableView)
        view.addSubview(customView1)
        view.addSubview(customView2)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        customView1.translatesAutoresizingMaskIntoConstraints = false
        customView2.translatesAutoresizingMaskIntoConstraints = false
        
        // Constraints
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            customView1.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            customView1.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customView1.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customView1.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            customView2.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            customView2.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customView2.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customView2.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        // Hide all views initially
        tableView.isHidden = true
        customView1.isHidden = true
        customView2.isHidden = true
    }
    
    // MARK: - Add New Item
    @objc private func createNewTask() {
        
    }
    
    // MARK: - Update View Mode
    private func updateViewMode(to mode: String) {
        let allViews = [tableView, customView1, customView2] // Tất cả các chế độ

        // Ẩn tất cả các chế độ
        allViews.forEach { $0.isHidden = true }
        
        switch mode {
        case "Day":
            tableView.isHidden = false
        case "Week":
            customView1.isHidden = false
        case "Month":
            customView2.isHidden = false
        default:
            break
        }
        
        navigationItem.title = "display mode: \(mode)"
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "Task \(indexPath.row + 1)"
        return cell
    }
    
}

