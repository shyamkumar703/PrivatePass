//
//  PasswordsViewController.swift
//  ChelsPass
//
//  Created by Shyam Kumar on 11/6/22.
//

import UIKit

fileprivate var cellId = "cell"

class PasswordsViewController: ViewController<PasswordsViewControllerViewModel> {
    var passwords = [PasswordTableViewCellViewModel]() {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }
    
    lazy var filteredPasswords = passwords
    var isSearching = false {
        didSet(old) {
            if isSearching != old {
                filteredPasswords = passwords
            }
        }
    }
    
    lazy var searchController: UISearchController = {
        let controller = UISearchController()
        controller.searchResultsUpdater = self
        controller.searchBar.placeholder = "Search passwords"
        return controller
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PasswordTableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func setupView() {
        viewModel?.viewDelegate = self
        
        navigationItem.searchController = searchController
        navigationItem.title = "Passwords"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "plus")?.withTintColor(.blue),
            style: .plain,
            target: self,
            action: #selector(addTapped)
        )
        
        view.addSubview(tableView)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    @objc func addTapped() {
        guard let vm = viewModel?.addVM else { return }
        let vc = UINavigationController(rootViewController: AddPasswordViewController.withViewModel(vm))
        present(vc, animated: true)
    }
}

extension PasswordsViewController: PasswordsViewControllerViewModelViewDelegate {
    func update(with passwords: [PasswordTableViewCellViewModel]) {
        self.passwords = passwords
    }
}

extension PasswordsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredPasswords.count : passwords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? PasswordTableViewCell {
            cell.viewModel = isSearching ? filteredPasswords[indexPath.item] : passwords[indexPath.item]
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let copyAction = UIAction(title: "Copy password", image: UIImage(systemName: "doc.on.doc")) { [weak self] _ in
                guard let self = self else { return }
                // copy
                UIPasteboard.general.string = self.isSearching ? self.filteredPasswords[indexPath.item].password.password : self.passwords[indexPath.item].password.password
            }
            
            let editAction = UIAction(title: "Edit", image: UIImage(systemName: "pencil")) { [weak self] _ in
                // edit
                guard let self = self else { return }
                let password = self.isSearching ? self.filteredPasswords[indexPath.item].password : self.passwords[indexPath.item].password
                guard let vm = self.viewModel?.addVM(for: password) else { return }
                DispatchQueue.main.async {
                    self.present(
                        UINavigationController(
                            rootViewController: AddPasswordViewController.withViewModel(vm)
                        ),
                        animated: true
                    )
                }
            }
            
            return UIMenu(title: "", children: [copyAction, editAction])
        }
    }
}

// MARK: - Search
extension PasswordsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        isSearching = searchController.isActive
        guard let query = searchController.searchBar.text else { return }
        if query.isEmpty {
            filteredPasswords = passwords
        } else {
            filteredPasswords = passwords.filter({ $0.password.website.contains(query) || $0.password.username.contains(query) || $0.password.password.contains(query) })
        }
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
}
