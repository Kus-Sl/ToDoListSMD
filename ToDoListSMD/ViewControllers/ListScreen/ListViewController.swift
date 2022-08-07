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
    private lazy var completedCounterLabel = UILabel()
    private lazy var showCompletedButton = UIButton()

    private lazy var viewModel: ListViewModelProtocol = ListViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.colorAsset.backPrimary
        setupView()
        setupLayout()
        viewModel = ListViewModel()
    }

    private func setupView() {
        setupCompletedCounterLabel()
        setupShowCompletedButton()
        setupTableView()
        view.addSubview(completedCounterLabel)
        view.addSubview(showCompletedButton)
        view.addSubview(tableView)
    }

    private func setupCompletedCounterLabel() {
        completedCounterLabel.textColor = UIColor.colorAsset.labelTertiary
        completedCounterLabel.font = UIFont.FontAsset.subhead
        completedCounterLabel.text = "Выполнено - \(viewModel.completedCount)"
    }

    private func setupShowCompletedButton() {
        showCompletedButton.setTitleColor(UIColor.colorAsset.colorBlue, for: .normal)
        showCompletedButton.titleLabel?.font = UIFont.FontAsset.subheadline
        showCompletedButton.setTitle("Показать", for: .normal)
    }

    private func setupTableView() {
        tableView.layer.cornerRadius = Constants.radius
        tableView.separatorColor = UIColor.colorAsset.supportSeparator
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

    private func setupLayout() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        completedCounterLabel.translatesAutoresizingMaskIntoConstraints = false
        showCompletedButton.translatesAutoresizingMaskIntoConstraints = false

        completedCounterLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        completedCounterLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.completedCounterLabelLeadingInset).isActive = true
        showCompletedButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: Constants.showCompletedButtonTrailingInset).isActive = true
        showCompletedButton.centerYAnchor.constraint(equalTo: completedCounterLabel.centerYAnchor).isActive = true
        showCompletedButton.heightAnchor.constraint(equalToConstant: Constants.showCompletedButtonHeight).isActive = true
        tableView.topAnchor.constraint(equalTo: completedCounterLabel.bottomAnchor, constant: Constants.tableViewTopInset).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.leadingInset).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: Constants.trailingInset).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
}

// MARK: Actions
extension ListViewController {
    //    private func deleteTaskList(with indexPath: IndexPath) {
    //        let deletingTaskList = taskLists[indexPath.row]
    //
    //        StorageManager.shared.delete(taskList: deletingTaskList)
    //        taskLists.remove(at: indexPath.row)
    //        tasksListTableView.deleteRows(at: [indexPath], with: .automatic)
    //    }
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
        let detailScreen = DetailViewController()
        detailScreen.viewModel = viewModel.createDetailViewModel(for: indexPath)
        present(UINavigationController(rootViewController: detailScreen), animated: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { _, _, _ in

        }

        let openDetailAction = UIContextualAction(style: .normal, title: nil) { _, _, isDone in
            isDone(true)
        }

        deleteAction.image = .IconAsset.deleteActionIcon
        openDetailAction.image = .IconAsset.openDetailActionIcon
        openDetailAction.backgroundColor = UIColor.colorAsset.colorGray

        return UISwipeActionsConfiguration(actions: [deleteAction, openDetailAction])
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let completeAction = UIContextualAction(style: .normal, title: nil) { _, _, isDone in
            isDone(true)
        }

        completeAction.backgroundColor = UIColor.colorAsset.colorGreen
        completeAction.image = .IconAsset.completeActionIcon
        return UISwipeActionsConfiguration(actions: [completeAction])
    }
}

// MARK: Constants
extension ListViewController {
    private enum Constants {
        static let leadingInset: CGFloat = 16
        static let trailingInset: CGFloat = -16
        static let completedCounterLabelLeadingInset: CGFloat = 32
        static let showCompletedButtonTrailingInset: CGFloat = -32
        static let showCompletedButtonHeight: CGFloat = 20
        static let tableViewTopInset: CGFloat = 12
        static let separatorTopInset: CGFloat = 0
        static let separatorBottomInset: CGFloat = 0
        static let separatorLeftInset: CGFloat = 52
        static let separatorRightInset: CGFloat = 0
        static let radius: CGFloat = 16
        static let navigationItemTitle = "Мои дела"
    }
}
