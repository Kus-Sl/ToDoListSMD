//
//  ListViewController.swift
//  ToDoListSMD
//
//  Created by Вячеслав Кусакин on 07.08.2022.
//

import UIKit

final class ListViewController: UIViewController {
    override var navigationItem: UINavigationItem {
        let item = UINavigationItem(title: Constants.navigationItemTitle)
        return item
    }

    private lazy var tableView = UITableView()
    private lazy var doneItemsCountLabel = UILabel()
    private lazy var showOrHideDoneItemsButton = UIButton()
    private lazy var newTodoItemButton = UIButton()

    private lazy var viewModel: ListViewModelProtocol = ListViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .ColorAsset.backPrimary
        setupView()
        setupLayout()
        viewModel = ListViewModel()
    }

    private func setupView() {
        setupCompletedCounterLabel()
        setupShowCompletedButton()
        setupTableView()
        setupNewTodoItemButton()
        view.addSubview(newTodoItemButton)
        view.addSubview(doneItemsCountLabel)
        view.addSubview(showOrHideDoneItemsButton)
        view.addSubview(tableView)
        view.addSubview(newTodoItemButton)
    }

    private func setupCompletedCounterLabel() {
        doneItemsCountLabel.textColor = .ColorAsset.labelTertiary
        doneItemsCountLabel.font = .FontAsset.subhead
        doneItemsCountLabel.text = Constants.doneItemsCountLabelText + "\(viewModel.completedCount)"
    }

    private func setupShowCompletedButton() {
        showOrHideDoneItemsButton.setTitleColor(.ColorAsset.colorBlue, for: .normal)
        showOrHideDoneItemsButton.titleLabel?.font = .FontAsset.subheadline
        showOrHideDoneItemsButton.setTitle(Constants.showDoneItemsButtonTitle, for: .normal)
    }

    private func setupTableView() {
        tableView.layer.cornerRadius = Constants.radius
        tableView.separatorColor = .ColorAsset.supportSeparator
        tableView.separatorInset = UIEdgeInsets(
            top: Constants.separatorTopInset,
            left: Constants.separatorLeftInset,
            bottom: Constants.separatorBottomInset,
            right: Constants.separatorRightInset
        )
        tableView.dataSource = self
        tableView.delegate = self

        //NB: зарефачить
        tableView.register(ListCell.self, forCellReuseIdentifier: ListCell.cellReuseIdentifier())
    }

    private func setupNewTodoItemButton() {
        newTodoItemButton.backgroundColor = .clear
        newTodoItemButton.layer.shadowColor = UIColor.ColorAsset.colorBlue?.cgColor
        newTodoItemButton.layer.shadowOffset = Constants.newTodoItemShadowOffset
        newTodoItemButton.layer.shadowOpacity = Constants.newTodoItemShadowOpacity
        newTodoItemButton.layer.shadowRadius = Constants.newTodoItemShadowRadius
        newTodoItemButton.layer.cornerRadius = Constants.newTodoItemRadius
        newTodoItemButton.contentVerticalAlignment = .fill
        newTodoItemButton.contentHorizontalAlignment = .fill
        newTodoItemButton.setImage(.IconAsset.newTodoItemButtonIcon!.withTintColor(.ColorAsset.colorBlue!), for: .normal)
        newTodoItemButton.addTarget(self, action: #selector(createNewTodoItem), for: .touchUpInside)

        let mopView = UIView()
        mopView.backgroundColor = .ColorAsset.colorWhite
        mopView.isUserInteractionEnabled = false

        newTodoItemButton.insertSubview(mopView, belowSubview: newTodoItemButton.imageView!)
        mopView.translatesAutoresizingMaskIntoConstraints = false

        mopView.centerXAnchor.constraint(equalTo: newTodoItemButton.centerXAnchor).isActive = true
        mopView.centerYAnchor.constraint(equalTo: newTodoItemButton.centerYAnchor).isActive = true
        mopView.heightAnchor.constraint(equalToConstant: Constants.mopViewSide).isActive = true
        mopView.widthAnchor.constraint(equalToConstant: Constants.mopViewSide).isActive = true
    }

    private func setupLayout() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        doneItemsCountLabel.translatesAutoresizingMaskIntoConstraints = false
        showOrHideDoneItemsButton.translatesAutoresizingMaskIntoConstraints = false
        newTodoItemButton.translatesAutoresizingMaskIntoConstraints = false

        doneItemsCountLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        doneItemsCountLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.doneItemsCountLabelLeadingInset).isActive = true
        showOrHideDoneItemsButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: Constants.showOrHideDoneItemsButtonTrailingInset).isActive = true
        showOrHideDoneItemsButton.centerYAnchor.constraint(equalTo: doneItemsCountLabel.centerYAnchor).isActive = true
        showOrHideDoneItemsButton.heightAnchor.constraint(equalToConstant: Constants.showOrHideDoneItemsButtonHeight).isActive = true
        tableView.topAnchor.constraint(equalTo: doneItemsCountLabel.bottomAnchor, constant: Constants.tableViewTopInset).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.leadingInset).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: Constants.trailingInset).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true

        newTodoItemButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: Constants.newTodoItemBottomInset).isActive = true
        newTodoItemButton.widthAnchor.constraint(equalToConstant: Constants.newTodoItemSide).isActive = true
        newTodoItemButton.heightAnchor.constraint(equalToConstant: Constants.newTodoItemSide).isActive = true
        newTodoItemButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
}

// MARK: Actions
extension ListViewController {
    @objc private func createNewTodoItem() {

    }

    private func openDetailsScreen(for indexPath: IndexPath) {
        let detailScreen = DetailViewController()
        detailScreen.viewModel = viewModel.createDetailViewModel(for: indexPath)
        present(UINavigationController(rootViewController: detailScreen), animated: true)
    }

    private func deleteTodoItem(with indexPath: IndexPath) {

    }

    private func completeTodoItem(with indexPath: IndexPath) {

    }
}

// MARK: Table view data source
extension ListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.getNumberOfRows()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ListCell.cellReuseIdentifier(), for: indexPath) as! ListCell
        cell.configure(for: indexPath, with: viewModel)
        return cell
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
        static let doneItemsCountLabelLeadingInset: CGFloat = 32
        static let showOrHideDoneItemsButtonTrailingInset: CGFloat = -32
        static let showOrHideDoneItemsButtonHeight: CGFloat = 20
        static let tableViewTopInset: CGFloat = 12
        static let separatorTopInset: CGFloat = 0
        static let separatorBottomInset: CGFloat = 0
        static let separatorLeftInset: CGFloat = 52
        static let separatorRightInset: CGFloat = 0
        static let radius: CGFloat = 16
        static let navigationItemTitle = "Мои дела"
        static let showDoneItemsButtonTitle = "Показать"
        static let hideDoneItemsButtonTitle = "Показать"
        static let doneItemsCountLabelText = "Выполнено - "
        static let newTodoItemRadius: CGFloat = newTodoItemSide / 2
        static let newTodoItemShadowOffset = CGSize(width: 0, height: 7)
        static let newTodoItemShadowOpacity: Float = 0.5
        static let newTodoItemShadowRadius: CGFloat = 8
        static let newTodoItemSide: CGFloat = 46
        static let newTodoItemBottomInset: CGFloat = -54
        static let mopViewSide: CGFloat = 20
    }
}
