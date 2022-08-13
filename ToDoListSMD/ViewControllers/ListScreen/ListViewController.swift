//
//  ListViewController.swift
//  ToDoListSMD
//
//  Created by Вячеслав Кусакин on 07.08.2022.
//

import UIKit
import CocoaLumberjack

final class ListViewController: UIViewController {
    override var navigationItem: UINavigationItem {
        UINavigationItem(title: Constants.navigationItemTitle)
    }

    private lazy var tableView = UITableView()
    private lazy var tableViewHeaderView = UIView()
    private lazy var completedItemsCountLabel = UILabel()
    private lazy var completedItemsButton = UIButton()
    private lazy var newTodoItemButton = UIButton()

    private lazy var viewModel: ListViewModelProtocol = ListViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ColorAsset.backPrimary
        setupView()
        setupLayout()

        viewModel.bindViewControllerWithModel { _ in
            self.tableView.reloadData()
            self.completedItemsCountLabel.text = Constants.completedItemsCountLabelText + "\(self.viewModel.getCompletedTodoItemsCount())"
        }
    }

    private func setupView() {
        setupTableView()
        setupTableViewHeaderView()
        setupCompletedItemsCountLabel()
        setupCompletedItemsButton()
        setupNewTodoItemButton()

        view.addSubview(tableView)
        tableViewHeaderView.addSubview(completedItemsCountLabel)
        tableViewHeaderView.addSubview(completedItemsButton)
        view.addSubview(newTodoItemButton)
    }

    private func setupTableView() {
        tableView.backgroundColor = .clear
        tableView.separatorColor = .ColorAsset.supportSeparator
        tableView.separatorInset = UIEdgeInsets(
            top: Constants.separatorTopInset,
            left: Constants.separatorLeftInset,
            bottom: Constants.separatorBottomInset,
            right: Constants.separatorRightInset
        )
        tableView.dataSource = self
        tableView.delegate = self

        // NB: зарефачить
        tableView.register(ListCell.self, forCellReuseIdentifier: ListCell.cellReuseIdentifier())
    }

    private func setupTableViewHeaderView() {
        tableViewHeaderView.frame = Constants.tableViewHeaderViewFrame
        tableView.tableHeaderView = tableViewHeaderView
    }

    private func setupCompletedItemsCountLabel() {
        completedItemsCountLabel.textColor = .ColorAsset.labelTertiary
        completedItemsCountLabel.font = .FontAsset.subhead
        completedItemsCountLabel.text = Constants.completedItemsCountLabelText + "\(viewModel.getCompletedTodoItemsCount())"
    }

    private func setupCompletedItemsButton() {
        completedItemsButton.setTitleColor(.ColorAsset.colorBlue, for: .normal)
        completedItemsButton.titleLabel?.font = .FontAsset.subheadline
        completedItemsButton.setTitle(Constants.hideCompletedItemsButtonTitle, for: .normal)
        completedItemsButton.setTitle(Constants.showCompletedItemsButtonTitle, for: .selected)
        completedItemsButton.addTarget(self, action: #selector(completedItemsButtonTapped), for: .touchUpInside)
    }

    private func setupNewTodoItemButton() {
        newTodoItemButton.backgroundColor = .clear
        newTodoItemButton.layer.shadowColor = UIColor.ColorAsset.colorBlue.cgColor
        newTodoItemButton.layer.shadowOffset = Constants.newTodoItemButtonShadowOffset
        newTodoItemButton.layer.shadowOpacity = Constants.newTodoItemButtonShadowOpacity
        newTodoItemButton.layer.shadowRadius = Constants.newTodoItemButtonShadowRadius
        newTodoItemButton.layer.cornerRadius = Constants.newTodoItemButtonRadius
        newTodoItemButton.contentVerticalAlignment = .fill
        newTodoItemButton.contentHorizontalAlignment = .fill
        newTodoItemButton.setImage(.IconAsset.newTodoItemButtonIcon.withTintColor(.ColorAsset.colorBlue), for: .normal)
        newTodoItemButton.addTarget(self, action: #selector(newTodoItemButtonTapped), for: .touchUpInside)

        let mockView = UIView()
        mockView.backgroundColor = .ColorAsset.colorWhite
        mockView.isUserInteractionEnabled = false

        newTodoItemButton.insertSubview(mockView, belowSubview: newTodoItemButton.imageView ?? UIImageView())
        mockView.translatesAutoresizingMaskIntoConstraints = false

        mockView.centerXAnchor.constraint(equalTo: newTodoItemButton.centerXAnchor).isActive = true
        mockView.centerYAnchor.constraint(equalTo: newTodoItemButton.centerYAnchor).isActive = true
        mockView.heightAnchor.constraint(equalToConstant: Constants.moсkViewSide).isActive = true
        mockView.widthAnchor.constraint(equalToConstant: Constants.moсkViewSide).isActive = true
    }

    private func setupLayout() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        completedItemsCountLabel.translatesAutoresizingMaskIntoConstraints = false
        completedItemsButton.translatesAutoresizingMaskIntoConstraints = false
        newTodoItemButton.translatesAutoresizingMaskIntoConstraints = false

        completedItemsCountLabel.topAnchor.constraint(equalTo: tableViewHeaderView.topAnchor).isActive = true
        completedItemsCountLabel.leadingAnchor.constraint(equalTo: tableViewHeaderView.leadingAnchor, constant: Constants.completedItemsCountLabelLeadingInset).isActive = true
        completedItemsButton.trailingAnchor.constraint(equalTo: tableViewHeaderView.trailingAnchor, constant: Constants.completedItemsButtonTrailingInset).isActive = true
        completedItemsButton.centerYAnchor.constraint(equalTo: completedItemsCountLabel.centerYAnchor).isActive = true
        completedItemsButton.heightAnchor.constraint(equalToConstant: Constants.completedItemsButtonHeight).isActive = true

        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.tableViewTopInset).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.leadingInset).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: Constants.trailingInset).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        newTodoItemButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: Constants.newTodoItemButtonBottomInset).isActive = true
        newTodoItemButton.widthAnchor.constraint(equalToConstant: Constants.newTodoItemButtonSide).isActive = true
        newTodoItemButton.heightAnchor.constraint(equalToConstant: Constants.newTodoItemButtonSide).isActive = true
        newTodoItemButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
}

// MARK: Actions
extension ListViewController {
    @objc private func newTodoItemButtonTapped() {
        openDetailsScreen(for: nil)
    }

    @objc private func completedItemsButtonTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        viewModel.isFilteredWithoutCompletedItems = sender.isSelected
        tableView.reloadData()
    }

    private func openDetailsScreen(for indexPath: IndexPath?) {
        let detailScreen = DetailViewController()
        detailScreen.viewModel = viewModel.createDetailViewModel(for: indexPath)
        present(UINavigationController(rootViewController: detailScreen), animated: true)
    }

    private func deleteTodoItem(with indexPath: IndexPath) {
        viewModel.deleteTodoItem(with: indexPath)
    }

    private func completeTodoItem(with indexPath: IndexPath) {
        viewModel.completeTodoItem(with: indexPath)
    }
}

// MARK: Table view data source
extension ListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.getNumberOfRows()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ListCell.cellReuseIdentifier(), for: indexPath) as? ListCell else { return UITableViewCell() }
        cell.configure(with: viewModel.getTodoItem(for: indexPath))
        cornerRadius(for: cell, with: indexPath)
        return cell
    }

    // NB: заречафить + разобраться со сбросом углов при свайпе
    func cornerRadius(for cell: UITableViewCell, with indexPath: IndexPath) {
        let isFirstCell = indexPath.row == 0
        let isLastCell = indexPath.row == tableView.numberOfRows(inSection: Constants.firstIndex) - 1

        cell.clipsToBounds = true
        if isFirstCell && isLastCell {
            cell.layer.cornerRadius = Constants.tableViewRadius
            cell.layer.maskedCorners = [
                .layerMinXMinYCorner,
                .layerMaxXMinYCorner,
                .layerMaxXMaxYCorner,
                .layerMinXMaxYCorner
            ]
        } else if isFirstCell {
            cell.layer.cornerRadius = Constants.tableViewRadius
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if isLastCell {
            cell.layer.cornerRadius = Constants.tableViewRadius
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            cell.layer.cornerRadius = .zero
            cell.layer.maskedCorners = []
        }
    }
}

// MARK: Table view delegate
extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        openDetailsScreen(for: indexPath)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { _, _, _ in
            self.deleteTodoItem(with: indexPath)
        }

        let openDetailAction = UIContextualAction(style: .normal, title: nil) { _, _, isDone in
            self.openDetailsScreen(for: indexPath)
            isDone(true)
        }

        deleteAction.image = .IconAsset.deleteActionIcon
        openDetailAction.image = .IconAsset.openDetailActionIcon
        openDetailAction.backgroundColor = .ColorAsset.colorGray
        return UISwipeActionsConfiguration(actions: [deleteAction, openDetailAction])
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let completeAction = UIContextualAction(style: .normal, title: nil) { _, _, isDone in
            self.completeTodoItem(with: indexPath)
            isDone(true)
        }

        completeAction.backgroundColor = .ColorAsset.colorGreen
        completeAction.image = .IconAsset.completeActionIcon
        return UISwipeActionsConfiguration(actions: [completeAction])
    }
}

// MARK: Constants
extension ListViewController {
    private enum Constants {
        static let leadingInset: CGFloat = 16
        static let trailingInset: CGFloat = -16
        static let completedItemsCountLabelLeadingInset: CGFloat = 16
        static let completedItemsButtonTrailingInset: CGFloat = -16
        static let completedItemsButtonHeight: CGFloat = 20
        static let tableViewTopInset: CGFloat = 12
        static let separatorTopInset: CGFloat = 0
        static let separatorBottomInset: CGFloat = 0
        static let separatorLeftInset: CGFloat = 52
        static let separatorRightInset: CGFloat = 0
        static let tableViewRadius: CGFloat = 16
        static let tableViewHeaderViewFrame = CGRect(x: 0, y: 0, width: 0, height: 32)
        static let navigationItemTitle = "Мои дела"
        static let showCompletedItemsButtonTitle = "Показать"
        static let hideCompletedItemsButtonTitle = "Cкрыть"
        static let completedItemsCountLabelText = "Выполнено - "
        static let newTodoItemButtonRadius: CGFloat = newTodoItemButtonSide / 2
        static let newTodoItemButtonShadowOffset = CGSize(width: 0, height: 7)
        static let newTodoItemButtonShadowOpacity: Float = 0.5
        static let newTodoItemButtonShadowRadius: CGFloat = 8
        static let newTodoItemButtonSide: CGFloat = 46
        static let newTodoItemButtonBottomInset: CGFloat = -54
        static let moсkViewSide: CGFloat = 20
        static let firstIndex = 0
    }
}
