//
//  PopoverViewController.swift
//  ProjectManager
//
//  Created by 이시원 on 2022/07/13.
//

import UIKit
import SnapKit
import RxSwift

protocol TodoMoveViewControllerDependencies: AnyObject {
    func dismissMoveViewController()
}

final class TodoMoveViewController: UIViewController {
    private let viewModel: TodoMoveViewModel
    private weak var coordinator: TodoMoveViewControllerDependencies?
    private let bag = DisposeBag()
    
    private let firstButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .preferredFont(forTextStyle: .title2)
        button.backgroundColor = .systemBackground
        button.setTitleColor(UIColor.systemBlue, for: .normal)
        return button
    }()
    
    private let secondButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .preferredFont(forTextStyle: .title2)
        button.backgroundColor = .systemBackground
        button.setTitleColor(UIColor.systemBlue, for: .normal)
        return button
    }()
    
    private lazy var buttomStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [firstButton, secondButton])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    init(viewModel: TodoMoveViewModel, coordinator: TodoMoveViewControllerDependencies) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        bind()
    }
}

//MARK: - View Setting
extension TodoMoveViewController {
    private func configureView() {
        view.backgroundColor = .systemGray5
        view.addSubview(buttomStackView)
        buttomStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(24)
        }
    }
}

//MARK: - ViewModel Bind
extension TodoMoveViewController {
    private func bind() {
        viewModel.buttonTitle
            .bind { [weak self] (firstTitle, secondTitle) in
                self?.firstButton.setTitle(firstTitle, for: .normal)
                self?.secondButton.setTitle(secondTitle, for: .normal)
            }.disposed(by: bag)
        
        firstButton.rx.tap
            .bind { [weak self] in
                self?.coordinator?.dismissMoveViewController()
                self?.viewModel.firstButtonDidTap()
            }.disposed(by: bag)
        
        secondButton.rx.tap
            .bind { [weak self] in
                self?.coordinator?.dismissMoveViewController()
                self?.viewModel.secondButtonDidTap()
            }.disposed(by: bag)
    }
}
