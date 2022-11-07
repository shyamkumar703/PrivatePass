//
//  PrimaryButton.swift
//  ChelsPass
//
//  Created by Shyam Kumar on 11/6/22.
//

import UIKit


class PrimaryButton: UIButton {
    enum State {
        case primary
        case secondary
    }
    
    var buttonState: State = .primary
    var isLoading: Bool = false {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.isUserInteractionEnabled = self.isLoading ? false : true
            }
        }
    }
    var isValid: Bool = true {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                let title = self.title(for: .normal) ?? ""
                if self.isValid {
                    self.animateToPrimaryState(title: title)
                    self.isUserInteractionEnabled = true
                } else {
                    self.animateToSecondaryState(title: title, backgroundColor: .gray)
                    self.isUserInteractionEnabled = false
                }
            }
        }
    }
    var titleBeforeLoading: String?
    let loadingIndicator: ProgressView = {
        let view = ProgressView(colors: [.white], lineWidth: 2)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .blue
        setTitleColor(.white, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func animateToSecondaryState(title: String, backgroundColor: UIColor) {
        guard buttonState == .primary else { return }
        buttonState = .secondary
        UIView.animate(withDuration: 0.2) {
            self.backgroundColor = backgroundColor
            self.setTitle(title, for: .normal)
        }
    }
    
    func animateToPrimaryState(title: String) {
        guard buttonState == .secondary else { return }
        buttonState = .primary
        UIView.animate(withDuration: 0.2) {
            self.backgroundColor = .blue
            self.setTitle(title, for: .normal)
        }
    }
    
    func startLoading() {
        guard !isLoading else { return }
        isLoading = true
        self.titleBeforeLoading = self.title(for: .normal)
        addLoadingIndicator()
        self.setTitle("", for: .normal)
        self.layoutIfNeeded()
    }
    
    func finishLoading() {
        guard let titleBeforeLoading = titleBeforeLoading,
              isLoading else { return }
        isLoading = false
        removeLoadingIndicator()
        self.setTitle(titleBeforeLoading, for: .normal)
        self.layoutIfNeeded()
    }
    
    private func addLoadingIndicator() {
        addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            loadingIndicator.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingIndicator.widthAnchor.constraint(equalTo: loadingIndicator.heightAnchor)
        ])
        loadingIndicator.isAnimating = true
    }
    
    private func removeLoadingIndicator() {
        loadingIndicator.isAnimating = false
        loadingIndicator.constraints.forEach({ loadingIndicator.removeConstraint($0) })
        loadingIndicator.removeFromSuperview()
    }
}
