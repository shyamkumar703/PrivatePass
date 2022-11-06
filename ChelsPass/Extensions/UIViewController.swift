//
//  UIViewController.swift
//  ChelsPass
//
//  Created by Shyam Kumar on 11/6/22.
//

import Foundation
import UIKit

protocol ViewModel {
    var dependencies: AllDependencies { get }
}

class ViewController<VM: ViewModel>: UIViewController {
    var viewModel: VM?
    var bottomButtonConstraint: NSLayoutConstraint? {
        didSet {
            bottomButtonConstraintInitialConstant = bottomButtonConstraint?.constant
        }
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    private var bottomButtonConstraintInitialConstant: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
//        navigationController?.setNavigationBarHidden(true, animated: false)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    static func withViewModel(_ viewModel: VM) -> ViewController<VM> {
        let viewController = self.self.init()
        viewController.viewModel = viewModel
        return viewController
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            guard let bottomButtonConstraint = bottomButtonConstraint else { return }
            bottomButtonConstraint.constant = bottomButtonConstraint.constant - keyboardSize.height + view.safeAreaInsets.bottom - 8
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        guard let bottomButtonConstraint = bottomButtonConstraint,
              let bottomButtonConstraintInitialConstant = bottomButtonConstraintInitialConstant else { return }
        bottomButtonConstraint.constant = bottomButtonConstraintInitialConstant
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func viewTapped() {
        view.endEditing(true)
    }
    
    func presentErrorAlert(title: String, subtitle: String) {
        DispatchQueue.main.async { [weak self] in
            let controller = UIAlertController(
                title: title,
                message: subtitle,
                preferredStyle: .alert
            )
            controller.addAction(
                UIAlertAction(
                    title: "Ok",
                    style: .default,
                    handler: { [weak self] _ in
                        controller.dismiss(animated: true)
                        self?.errorDismissedByUser()
                    }
                )
            )
            self?.present(controller, animated: true) { [weak self] in
                self?.presentedErrorAlert()
            }
        }
    }
    
    func presentedErrorAlert() {
    }
    
    func errorDismissedByUser() {}
}
