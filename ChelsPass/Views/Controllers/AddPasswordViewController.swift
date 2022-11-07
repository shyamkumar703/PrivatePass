//
//  AddPasswordViewController.swift
//  ChelsPass
//
//  Created by Shyam Kumar on 11/6/22.
//

import UIKit

class AddPasswordViewController: ViewController<AddPasswordViewControllerViewModel> {
    
    lazy var infoStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .fill
        stack.axis = .vertical
        stack.spacing = 8
        stack.alpha = 0
        
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(valueField)
        return stack
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = viewModel?.title
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .thin)
        label.textColor = .black
        return label
    }()
    
    lazy var valueField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.tintColor = .blue
        field.font = .systemFont(ofSize: 20, weight: .regular)
        field.text = viewModel?.textFieldStarterText
        field.textAlignment = .center
        field.textColor = .blue
        field.delegate = self
        return field
    }()
    
    lazy var buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .fill
        stack.axis = .vertical
        stack.spacing = 8
        stack.alpha = 0
        
        stack.addArrangedSubview(primaryButton)
        if viewModel?.secondaryButtonText != nil {
            stack.addArrangedSubview(secondaryButton)
        }
        return stack
    }()
    
    lazy var primaryButton: PrimaryButton = {
        let button = PrimaryButton()
        button.setTitle(viewModel?.primaryButtonText, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isValid = (valueField.text?.count ?? 0) != 0
        button.addTarget(self, action: #selector(primaryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var secondaryButton: SecondaryButton = {
        let button = SecondaryButton()
        button.title = viewModel?.secondaryButtonText
        button.addTarget(self, action: #selector(secondaryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.viewDelegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        animateViewOut()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateViewIn()
    }
    
    func setupView() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        viewModel?.viewDelegate = self
        
        view.addSubview(infoStack)
        view.addSubview(buttonStack)
    }
    
    func setupConstraints() {
        bottomButtonConstraint = buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        guard let bottomButtonConstraint = bottomButtonConstraint else { return }
        
        NSLayoutConstraint.activate([
            infoStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            infoStack.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: UIScreen.main.bounds.height * 0.33),
            infoStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            
            buttonStack.leadingAnchor.constraint(equalTo: infoStack.leadingAnchor),
            buttonStack.trailingAnchor.constraint(equalTo: infoStack.trailingAnchor),
            bottomButtonConstraint,
            
            primaryButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func animateViewIn() {
        UIView.animate(
            withDuration: 0.2,
            animations: { [weak self] in
                self?.infoStack.alpha = 1
                self?.buttonStack.alpha = 1
            },
            completion: { [weak self] _ in
                self?.valueField.becomeFirstResponder()
            }
        )
    }
    
    func animateViewOut() {
        valueField.resignFirstResponder()
        UIView.animate(
            withDuration: 0.2,
            animations: { [weak self] in
                self?.infoStack.alpha = 0
                self?.buttonStack.alpha = 0
            }
        )
    }
}

extension AddPasswordViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
           let range = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: range, with: string)
            if updatedText.count == 0 {
                primaryButton.isValid = false
            } else {
                primaryButton.isValid = true
            }
        }
        return true
    }
}

// MARK: - Button actions
extension AddPasswordViewController {
    @objc func primaryButtonTapped() {
        guard let text = valueField.text,
              text.count != 0 else {
            return
        }
        viewModel?.nextTapped(with: text)
    }
    
    @objc func secondaryButtonTapped() {
        viewModel?.backTapped()
    }
}

// MARK: - View delegate methods
extension AddPasswordViewController: AddPasswordViewControllerViewModelViewDelegate {
    func startLoading() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.primaryButton.startLoading()
        }
    }
    
    func stopLoadingAndDismiss() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.primaryButton.finishLoading()
            self.dismiss(animated: true)
        }
    }
    
    func pushNext() {
        guard let viewModel = viewModel else { return }
        let vc = AddPasswordViewController.withViewModel(viewModel)
        navigationController?.pushViewController(
            vc,
            animated: true
        )
    }
    
    func popBack() {
        navigationController?.popViewController(animated: true)
    }
}

