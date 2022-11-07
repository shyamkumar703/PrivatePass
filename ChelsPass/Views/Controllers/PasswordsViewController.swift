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
    
    func setupView() {
        viewModel?.viewDelegate = self
        
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
        return passwords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? PasswordTableViewCell {
            cell.viewModel = passwords[indexPath.item]
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let copyAction = UIAction(title: "Copy password", image: UIImage(systemName: "doc.on.doc")) { [weak self] _ in
                guard let self = self else { return }
                // copy
                UIPasteboard.general.string = self.passwords[indexPath.item].password.password
            }
            
            let editAction = UIAction(title: "Edit", image: UIImage(systemName: "pencil")) { [weak self] _ in
                // edit
            }
            
            let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash.fill"), attributes: .destructive) { [weak self] _ in
                // delete
            }
            
            return UIMenu(title: "", children: [copyAction, editAction, deleteAction])
        }
    }
}
